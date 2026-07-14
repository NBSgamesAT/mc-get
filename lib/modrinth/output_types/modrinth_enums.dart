import 'package:json_annotation/json_annotation.dart';

enum SideData {
  @JsonValue("required") required,
  @JsonValue("optional") optional,
  @JsonValue("unsupported") unsupported,
  @JsonValue("unknown") unknown,
}

enum ProjectType {
  @JsonValue("mod") mod,
  @JsonValue("modpack") modpack,
  @JsonValue("resourcepack") resourcepack,
}

enum MonetizationStatus {
  @JsonValue("monetized") monetized,
  @JsonValue("demonetized") demonetized,
  @JsonValue("force-demonetized") forceDemonetized,
}

enum DependencyType {
  @JsonValue("required") required,
  @JsonValue("optional") optional,
  @JsonValue("incompatible") incompatible,
  @JsonValue("embedded") embedded,
}

enum VersionType {
  @JsonValue("release") release,
  @JsonValue("beta") beta,
  @JsonValue("alpha") alpha,
}

enum Status {
  @JsonValue("listed") listed,
  @JsonValue("unlisted") unlisted,
  @JsonValue("archived") archived,
  @JsonValue("draft") draft,
  @JsonValue("scheduled") scheduled,
}

enum FileType {
  @JsonValue("required-resource-pack") requiredResourcePack,
  @JsonValue("optional-resource-pack") optionalResourcePack,
  @JsonValue("source-jar") sourceJar,
  @JsonValue("dev-jar") devJar,
  @JsonValue("javadoc-jar") javadocJar,
  @JsonValue("unknown") unknown,
  @JsonValue("signature") signature,
}