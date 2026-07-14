import "package:json_annotation/json_annotation.dart";
import "package:mc_get/modrinth/output_types/version.dart";

part "config_data.g.dart";

@JsonSerializable()
class McGetJson {
  String minecraftVersion;
  String loader;
  String? installFolderOverride;
  List<String> mods;

  String get installFolder {
    if (installFolderOverride != null && installFolderOverride!.isNotEmpty) {
      return installFolderOverride!;
    } else if(loader == "bukkit" || loader == "spigot" || loader == "paper") {
      return "plugins";
    } else {
      return "mods";
    }
  }

  McGetJson(this.minecraftVersion, this.loader, {this.installFolderOverride}) : mods = [];

  factory McGetJson.fromJson(Map<String, dynamic> json) => _$McGetJsonFromJson(json);
  Map<String, dynamic> toJson() => _$McGetJsonToJson(this);
}

@JsonSerializable(explicitToJson: true)
class McGetLock {
  String minecraftVersion;
  String loader;
  String installFolder;
  List<LockedModData> mods;

  McGetLock(this.minecraftVersion, this.loader, this.installFolder, {this.mods = const []});

  factory McGetLock.fromJson(Map<String, dynamic> json) => _$McGetLockFromJson(json);
  Map<String, dynamic> toJson() => _$McGetLockToJson(this);
}

@JsonSerializable(explicitToJson: true)
class LockedModData {
  String modId;
  String versionId;
  String versionNumber;
  String fileName;
  Hash hashes;

  LockedModData(this.modId, this.versionId, this.versionNumber, this.fileName, this.hashes);

  factory LockedModData.fromJson(Map<String, dynamic> json) => _$LockedModDataFromJson(json);
  Map<String, dynamic> toJson() => _$LockedModDataToJson(this);
}
