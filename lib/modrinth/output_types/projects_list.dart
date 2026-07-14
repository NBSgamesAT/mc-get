import "package:json_annotation/json_annotation.dart";
import "project_light.dart";

part "projects_list.g.dart";

@JsonSerializable(explicitToJson: true)
class ProjectsList {
  List<LightProject> hits;
  int offset;
  int limit;
  @JsonKey(name: "total_hits") int totalHits;

  ProjectsList(this.hits, this.offset, this.limit, this.totalHits);

  factory ProjectsList.fromJson(Map<String, dynamic> json) =>
      _$ProjectsListFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectsListToJson(this);
}