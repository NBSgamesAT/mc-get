part of "modrinth.dart";

// ---
enum HTTPMethod {
  get,
  post
}

abstract class PassInfo {
  HTTPMethod get method;
  Map<String, dynamic>? get queryParameters;
  String? get additionalPath;
}

class SearchInfo extends PassInfo{
  String? query;
  List<List<Facet>>? facets;
  String? index;
  int? offset;
  int? limit;
  
  @override HTTPMethod get method => HTTPMethod.get;
  @override String? get additionalPath => null;

  @override
  Map<String, dynamic>? get queryParameters => {
    if (query != null) "query": query,
    if (facets != null) "facets": Facet.getCompleteFacetSearchString(facets),
    if (index != null) "index": index,
    if (offset != null) "offset": offset.toString(),
    if (limit != null) "limit": limit.toString(),
  };

  SearchInfo({this.query, this.facets, this.index, this.offset, this.limit});
}

/// Represents the information needed to make a request for a specific project.
/// CAN **ALSO** BE USED FOR THE ID OF THE PROJECT
class SlugOrId extends PassInfo {
  String slug;
  SlugOrId(this.slug);

  @override HTTPMethod get method => HTTPMethod.get;
  @override Map<String, dynamic>? get queryParameters => null;
  @override String? get additionalPath => slug;
}

/// For requesting all versions of a project that match the given criteria. The slug is the slug of said project.
class VersionSearch extends PassInfo {
  String slug;
  List<String>? loaders;
  List<String>? gameVersions;
  bool? featured;
  bool includeChangeLog;
  VersionSearch(this.slug, { this.loaders, this.gameVersions, this.featured, this.includeChangeLog = false });

  @override HTTPMethod get method => HTTPMethod.get;
  @override Map<String, dynamic>? get queryParameters => {
    if (loaders != null) "loaders": jsonEncode(loaders),
    if (gameVersions != null) "game_versions": jsonEncode(gameVersions),
    "featured": ?featured?.toString(),
    "include_changelog": includeChangeLog.toString(),
  };
  @override String? get additionalPath => "$slug/version";
}