part of "modrinth.dart";

enum ModrinthEndpoint<QueryInfo extends PassInfo, ReturnType>{
  searchProject<SearchInfo, ProjectsList>("search", parser: ObjectParser(ProjectsList.fromJson)),

  readProject<SlugOrId, dynamic>("project"),
  readVersion<PassInfo, dynamic>("version"),
  readCollection<PassInfo, dynamic>("collections"),
  
  listProjectVersions<VersionSearch, List<Version>>("project", parser: ListParser(Version.fromJsonList));

  final String endpoint;
  final String? specification;
  final bool needsPAT;
  final HTTPMethod method;
  final ParserHelper<dynamic, ReturnType>? parser;

  const ModrinthEndpoint(this.endpoint, {this.parser, this.method = HTTPMethod.get, this.specification, this.needsPAT = false});
}

/// Return type is the type that will actually be returned by the sendRequest method
/// Parsing type is the type that the parser function will receive as an input.
/// ParserType is the type of the parser function itself
abstract class ParserHelper<ParsingType, ParserReturnType> {
  ParsingType makeParsingType(dynamic jsonResponse);
  ParserReturnType _parse(ParsingType parsedData);
  ParserReturnType parse(dynamic jsonResponse) {
    return _parse(makeParsingType(jsonResponse));
  }
  const ParserHelper();
}

class ObjectParser<ParserReturnType> extends ParserHelper<Map<String, dynamic>, ParserReturnType> {

  final ParserReturnType Function(Map<String, dynamic> parsedData) parser;

  @override
  Map<String, dynamic> makeParsingType(dynamic jsonResponse) {
    if (jsonResponse is Map<String, dynamic>) {
      return jsonResponse;
    } else {
      throw Exception("Expected a Map<String, dynamic> but got ${jsonResponse.runtimeType}");
    }
  }

  @override
  ParserReturnType _parse(Map<String, dynamic> parsedData) {
    return parser(parsedData);
  }

  const ObjectParser(this.parser); 
}

class ListParser<ParserReturnType> extends ParserHelper<List<dynamic>, ParserReturnType> {

  final ParserReturnType Function(List<dynamic> parsedData) parser;

  @override
  List<dynamic> makeParsingType(dynamic jsonResponse) {
    if (jsonResponse is List<dynamic>) {
      return jsonResponse;
    } else {
      throw Exception("Expected a List<dynamic> but got ${jsonResponse.runtimeType}");
    }
  }

  @override
  ParserReturnType _parse(List<dynamic> parsedData) {
    return parser(parsedData);
  }

  const ListParser(this.parser); 
}
