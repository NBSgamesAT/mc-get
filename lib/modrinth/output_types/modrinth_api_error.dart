import "package:json_annotation/json_annotation.dart";
import "package:mc_get/modrinth/modrinth.dart";

part "modrinth_api_error.g.dart";

@JsonSerializable()
class ApiErrorResponse {

  String error;
  String description;
  ApiErrorResponse(this.error, this.description);

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) => _$ApiErrorResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ApiErrorResponseToJson(this);
}

class ModrinthApiError extends Error {

  String message;
  int httpStatus;
  ModrinthEndpoint endpoint;
  PassInfo? passInfo;
  ApiErrorResponse response;

  ModrinthApiError({
    required this.message,
    required this.httpStatus,
    required this.endpoint,
    required this.response,
    this.passInfo
  });
}

class ModrinthApiException implements Exception {

  String message;
  int httpStatus;
  ModrinthEndpoint endpoint;
  PassInfo? passInfo;

  ModrinthApiException({
    required this.message,
    required this.httpStatus,
    required this.endpoint,
    this.passInfo
  });
}