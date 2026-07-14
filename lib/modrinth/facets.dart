
import 'dart:convert';

class Facet {
  final FacetValues facet;
  final CompareFacet compare;
  final String value;

  const Facet(this.facet, this.compare, this.value);

  @override
  String toString() {
    return "${facet.name}${compare.symbol}$value";
  }
  static String? getCompleteFacetSearchString(List<List<Facet>>? facets) {
    if (facets == null) return null;
    List<List<String>> facetStrings = facets.map((facetList) => facetList.map((facet) => facet.toString()).toList()).toList();
    JsonEncoder encoder = const JsonEncoder();
    return encoder.convert(facetStrings);
  }
}


enum FacetValues {
  projectType,
  allProjectTypes,
  categories,
  versions,
  clientSide,
  serverSide,
  openSource,
  title,
  author,
  follows,
  projectId,
  license,
  downloads,
  createdTimestamp,
  modifiedTimestamp;

  String get name {
    switch (this) {
      case FacetValues.projectType:
        return "project_type";
      case FacetValues.allProjectTypes:
        return "all_project_types";
      case FacetValues.categories:
        return "categories";
      case FacetValues.versions:
        return "versions";
      case FacetValues.clientSide:
        return "client_side";
      case FacetValues.serverSide:
        return "server_side";
      case FacetValues.openSource:
        return "open_source";
      case FacetValues.title:
        return "title";
      case FacetValues.author:
        return "author";
      case FacetValues.follows:
        return "follows";
      case FacetValues.projectId:
        return "project_id";
      case FacetValues.license:
        return "license";
      case FacetValues.downloads:
        return "downloads";
      case FacetValues.createdTimestamp:
        return "created_timestamp";
      case FacetValues.modifiedTimestamp:
        return "modified_timestamp";
    }
  }
}

enum CompareFacet {
  equals,
  greaterThan,
  lessThan,
  greaterThanEquals,
  lessThanEquals;

  String get symbol {
    switch (this) {
      case CompareFacet.equals:
        return ":";
      case CompareFacet.greaterThan:
        return ">";
      case CompareFacet.lessThan:
        return "<";
      case CompareFacet.greaterThanEquals:
        return ">=";
      case CompareFacet.lessThanEquals:
        return "<=";
    }
  }
}