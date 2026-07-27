part of "cmd.dart";

Future<void> installCommand(List<String> args) async {
  if (args.length != 2) {
    print("Please provide the slug of the mods to install.");
    return;
  }

  final slug = args[1];
  final config = await getMcGetConfig();
  final lockConfig = await getMcGetLock();
  final api = getApi();

  try{
    final versions = await api.sendRequest(.listProjectVersions, VersionSearch(slug, 
      gameVersions: [config.data.minecraftVersion],
      loaders: [config.data.loader],
      includeChangeLog: false
    ));

    if(versions == null || versions.isEmpty){
      print("No versions found for mod '$slug' for Minecraft version '${config.data.minecraftVersion}' and loader '${config.data.loader}'.");
      return;
    }

    versions.sort((a, b) => b.datePublished.compareTo(a.datePublished)); // Sort by date published, descending.
    var version  = versions.first;
    
    var lockedMod = lockConfig.data.mods.where((mod) => mod.modSlug == slug).firstOrNull;
    if(lockedMod != null){
      print("Mod '$slug' is already installed with version '${lockedMod.versionNumber}'. Run with -U to update.");
      return;
    }

    lockedMod ??= LockedModData("", "", "", "", Hash());

    var file = version.files.where((file) => file.primary).firstOrNull;

    if(file == null){
      print("No primary file found for version '${version.versionNumber}'.");
      return;
    }

    lockedMod.modSlug = slug;
    lockedMod.versionId = version.id;
    lockedMod.versionNumber = version.versionNumber!;
    lockedMod.fileName = file.filename;
    lockedMod.hashes = file.hashes;

    lockConfig.data.mods.add(lockedMod);
    await lockConfig.save();
    config.data.mods = config.data.mods.where((mod) => !mod.contains(slug)).toList(); // Just to make sure we don't have duplicates.
    config.data.mods.add("$slug>=${version.versionNumber}");
    await config.save();

    File downloaded = await downloadFile(file.url, p.join(".", config.data.installFolder, file.filename).toString());    

    final sha1Hash = sha1.convert(await downloaded.readAsBytes()).toString();
    final sha512Hash = sha512.convert(await downloaded.readAsBytes()).toString();

    if(sha1Hash != file.hashes.sha1 || sha512Hash != file.hashes.sha512){
      print("Downloaded file hash does not match expected hash. Deleting file.");
      await downloaded.delete();
      return;
    }

    print("Successfully installed mod '$slug' version '${version.versionNumber}'.");
  
  } on ModrinthApiException catch (e) {
    print("Couldn't find the mod with slug '$slug'. Error: ${e.message}");
  }
}


Future<void> removeCommand(List<String> args) async {
  if (args.length != 2) {
    print("Please provide the slug of the mod to remove.");
    return;
  }

  final slug = args[1];
  final config = await getMcGetConfig();
  final lockConfig = await getMcGetLock();

  var lockedMod = lockConfig.data.mods.where((mod) => mod.modSlug == slug).firstOrNull;
  if(lockedMod == null){
    print("Mod '$slug' is not installed.");
    return;
  }

  lockConfig.data.mods.remove(lockedMod);
  await lockConfig.save();
  config.data.mods = config.data.mods.where((mod) => !mod.contains(slug)).toList();
  await config.save();

  final filePath = p.join(".", config.data.installFolder, lockedMod.fileName);
  final file = File(filePath);
  if(await file.exists()){
    await file.delete();
    print("Successfully removed mod '$slug'.");
  } else {
    print("File for mod '$slug' not found. It may have been deleted manually.");
  }
}

