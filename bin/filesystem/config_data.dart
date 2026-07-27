import "package:json_annotation/json_annotation.dart";
import "package:mc_get/modrinth/output_types/version.dart";

part "config_data.g.dart";

abstract class ConfigData<T> {
  Map<String, dynamic> toJson();
}

@JsonSerializable()
class McGetJson implements ConfigData<McGetJson> {
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
  @override Map<String, dynamic> toJson() => _$McGetJsonToJson(this);

  McGetJson.empty() : minecraftVersion = "", loader = "", installFolderOverride = null, mods = [];
}

@JsonSerializable(explicitToJson: true)
class McGetLock implements ConfigData<McGetLock> {
  String minecraftVersion;
  String loader;
  String installFolder;
  List<LockedModData> mods;

  McGetLock(this.minecraftVersion, this.loader, this.installFolder, {this.mods = const []});

  McGetLock.empty() : minecraftVersion = "", loader = "", installFolder = "", mods = [];

  factory McGetLock.fromJson(Map<String, dynamic> json) => _$McGetLockFromJson(json);
  @override Map<String, dynamic> toJson() => _$McGetLockToJson(this);
}

@JsonSerializable(explicitToJson: true)
class LockedModData {
  String modSlug; // I decided to use modSlug instead of modId so I can actually find the mod via something that can be typed by the user
  String versionId;
  String versionNumber;
  String fileName;
  Hash hashes;
  List<String> requiredDependencies = [];

  LockedModData(this.modSlug, this.versionId, this.versionNumber, this.fileName, this.hashes);

  factory LockedModData.fromJson(Map<String, dynamic> json) => _$LockedModDataFromJson(json);
  Map<String, dynamic> toJson() => _$LockedModDataToJson(this);
}
