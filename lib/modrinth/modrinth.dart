import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mc_get/modrinth/facets.dart';
import 'package:mc_get/modrinth/output_types/modrinth_api_error.dart';
import 'package:mc_get/modrinth/output_types/projects_list.dart';
import 'package:mc_get/modrinth/output_types/version.dart';

part 'modrinth.send_types.dart';
part 'modrinth.endpoints.dart';

class ModrinthV2 {
  static const String baseUrl = 'api.modrinth.com';
  static const String apiVersion = 'v2';
  final String userAgent;
  final String? personalAccessToken;
  final JsonDecoder _jsonDecoder = const JsonDecoder();

  ModrinthV2(String githubName, String githubRepo, String version, String email, {this.personalAccessToken}) : userAgent = "$githubName/$githubRepo/$version ($email)";

  Future<ReturnType?> sendRequest<Info extends PassInfo, ReturnType>(ModrinthEndpoint<Info, ReturnType> endpoint, Info info) async {

    if(endpoint.needsPAT && personalAccessToken == null) {
      throw Exception("This endpoint requires a Personal Access Token (PAT), but no such token was provided during the initialization of the ModrinthV2 instance.");
    }

    if(endpoint.parser == null && (ReturnType == Map || ReturnType == List)){
      throw Exception("The endpoint ${endpoint.endpoint} does not have a parser defined, but the return type is $ReturnType. Please provide a parser for this endpoint.");
    }

    final Uri uri = Uri.https(
      ModrinthV2.baseUrl,
      "$apiVersion/${endpoint.endpoint}${info.additionalPath != null ? "/${info.additionalPath}" : ""}", //version number / endpoint path (/ additional path if present)
      info.queryParameters,
    );

    final Map<String, String> headers = {
      'User-Agent': userAgent,
      if (endpoint.needsPAT) 'Authorization': personalAccessToken!,
    };
    final http.Response response = await _push(uri, endpoint, headers: headers);

    if(response.statusCode == 200) {
      if(ReturnType == dynamic){
        return response.body as ReturnType;
      }
      else if(ReturnType == String){
        return response.body as ReturnType;
      }
      else{
        dynamic jsonResponse = _jsonDecoder.convert(response.body);
        if (endpoint.parser != null) {
          try {
            return endpoint.parser!.parse(jsonResponse);
          } catch (e, stackTrace) {
            throw Exception("Failed to parse response for endpoint ${endpoint.endpoint}: $e\nStack trace: $stackTrace\nResponse body: ${response.body}");
          }
        }

        if (jsonResponse is ReturnType) {
          return jsonResponse;
        }

        throw Exception("The endpoint ${endpoint.endpoint} does not have a parser and decoded response type ${jsonResponse.runtimeType} cannot be assigned to $ReturnType.");
      }

    } else if (response.statusCode == 404) {
      throw ModrinthApiException(
        message: "Resource not found",
        endpoint: endpoint,
        httpStatus: 404,
        passInfo: info
      );
    } else {
      Map<String, dynamic> jsonResponse = _jsonDecoder.convert(response.body);
      ApiErrorResponse errorResponse = ApiErrorResponse.fromJson(jsonResponse);
      throw ModrinthApiError(
        message: errorResponse.error,
        endpoint: endpoint,
        httpStatus: response.statusCode,
        response: errorResponse,
        passInfo: info
      );
    }
  }

  Future<http.Response> _push(Uri uri, ModrinthEndpoint endpoint, {Map<String, String>? headers}) {

    switch(endpoint.method) {
      case HTTPMethod.get:
        return http.get(uri, headers: headers);
      case HTTPMethod.post:
        return http.post(uri, headers: headers);
    }
  }
}

