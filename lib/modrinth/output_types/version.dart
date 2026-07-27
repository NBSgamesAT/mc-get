import "package:json_annotation/json_annotation.dart";
import "package:mc_get/modrinth/output_types/modrinth_enums.dart";

part "version.g.dart";

@JsonSerializable(explicitToJson: true)
class Version {
  String? name;
  @JsonKey(name: "version_number") String? versionNumber;
  String? changelog;
  List<Dependency>? dependencies;
  @JsonKey(name: "game_versions") List<String>? gameVersions;
  @JsonKey(name: "version_type") VersionType? versionType;
  List<String>? loaders;
  bool? featured;
  Status? status;
  @JsonKey(name: "requested_status") Status? requestedStatus;
  @JsonKey(name: "changelog_url") String? changelogUrl;

  String id;
  @JsonKey(name: "project_id") String projectId;
  @JsonKey(name: "author_id") String authorId;
  @JsonKey(name: "date_published") String datePublished;
  int downloads;
  List<ApiFile> files;

  Version({
    required this.id,
    required this.projectId,
    required this.authorId,
    required this.datePublished,
    required this.downloads,
    required this.files,
  });

  factory Version.fromJson(Map<String, dynamic> json) => _$VersionFromJson(json);
  static List<Version> fromJsonList(List<dynamic> jsonList) => jsonList.map((json) => Version.fromJson(json)).toList();
  Map<String, dynamic> toJson() => _$VersionToJson(this);

}

@JsonSerializable(explicitToJson: true)
class ApiFile {
  Hash hashes;
  String url;
  String filename;
  bool primary;
  int size;
  @JsonKey(name: "file_type") FileType? fileType;

  ApiFile({
    required this.hashes,
    required this.url,
    required this.filename,
    required this.primary,
    required this.size,
  });

  factory ApiFile.fromJson(Map<String, dynamic> json) => _$ApiFileFromJson(json);
  Map<String, dynamic> toJson() => _$ApiFileToJson(this);
}

@JsonSerializable()
class Hash {
  String? sha512;
  String? sha1;

  Hash({this.sha512, this.sha1});

  factory Hash.fromJson(Map<String, dynamic> json) => _$HashFromJson(json);
  Map<String, dynamic> toJson() => _$HashToJson(this);
}

@JsonSerializable()
class Dependency {
  @JsonKey(name: "version_id") String? versionId;
  @JsonKey(name: "project_id") String? projectId;
  @JsonKey(name: "file_name") String? fileName;
  @JsonKey(name: "dependency_type") DependencyType type;

  Dependency({
    required this.type,
  });

  factory Dependency.fromJson(Map<String, dynamic> json) => _$DependencyFromJson(json);
  Map<String, dynamic> toJson() => _$DependencyToJson(this);
}