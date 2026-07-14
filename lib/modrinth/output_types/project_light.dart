import 'package:json_annotation/json_annotation.dart';
import 'package:mc_get/modrinth/output_types/modrinth_enums.dart';

part "project_light.g.dart";

@JsonSerializable()
class LightProject {
  String? slug;
  String? title;
  String? description;
  List<String>? categories;
  @JsonKey(name: "client_side") SideData? clientSide;
  @JsonKey(name: "server_side") SideData? serverSide;
  @JsonKey(name: "project_type") ProjectType projectType;
  int downloads;
  @JsonKey(name: "icon_url") String? iconUrl;
  int? color;
  @JsonKey(name: "thread_id") String? threadId;
  @JsonKey(name: "monetization_status") MonetizationStatus? monetizationStatus;
  @JsonKey(name: "project_id") String projectId;
  @JsonKey(name: "all_project_types") List<String> allProjectTypes;
  String author;
  @JsonKey(name: "display_categories") List<String>? displayCategories;
  List<String> versions;
  int follows;
  @JsonKey(name: "date_created") String dateCreated;
  @JsonKey(name: "date_modified") String dateModified;
  @JsonKey(name: "latest_version") String? latestVersion;
  String license;
  List<String>? gallery;
  @JsonKey(name: "featured_gallery") String? featuredGallery;

  LightProject({
    required this.projectType,
    required this.downloads,
    required this.projectId,
    required this.allProjectTypes,
    required this.author,
    required this.versions,
    required this.follows,
    required this.dateCreated,
    required this.dateModified,
    required this.license,
  });

  factory LightProject.fromJson(Map<String, dynamic> json) =>
      _$LightProjectFromJson(json);
  Map<String, dynamic> toJson() => _$LightProjectToJson(this);
}