part of "cmd.dart";

Future<void> validateLocal({bool fixFoundIssues = false}) async {
  final config = await getMcGetConfig();
  final lock = await getMcGetLock();

  if(!await isValidConfig()){
    print("Please run the init command first to set up your config.");
    return;
  }

  if(!lock.isLoaded){
    print("No lock file found. Please run the install command first.");
    return;
  }

  // Validate that all mods in the lock file are present in the mods folder
  for(final mod in lock.data.mods){
    final modFile = File(p.join(".", config.data.installFolder, mod.fileName));
    if(!await modFile.exists()){
      print("Mod ${mod.fileName} is missing from the mods folder.");
      if(fixFoundIssues){
        await _fixSanityCheck(mod);
      }
      continue;
    }
    // Validate that the mod file's hash matches the hash in the lock file
    final bytes = await modFile.readAsBytes();
    final hash = sha512.convert(bytes).toString();
    if(hash != mod.hashes.sha512){
      print("Mod ${mod.fileName} has an invalid hash. Expected ${mod.hashes.sha512}, got $hash.");
      if(fixFoundIssues){
        await _fixSanityCheck(mod, modFile: modFile);
      }
      continue;
    }
  }
  await lock.save();

  print("Validation complete.");
}

Future<void> validateViaApi({bool fixFoundIssues = false}) async {
  final config = await getMcGetConfig();
  final lock = await getMcGetLock();

  if(!await isValidConfig()){
    print("Please run the init command first to set up your config.");
    return;
  }

  if(!lock.isLoaded){
    print("No lock file found. Please run the install command first.");
    return;
  }

  ModrinthV2 api = getApi();

  // Validate that all mods in the lock file are present in the mods folder
  for(final mod in lock.data.mods){
    Version? version = await api.sendRequest(.readVersion, SlugOrId(mod.versionId));
    if(version == null){
      print("Mod ${mod.modSlug} with version ID ${mod.versionId} not found on Modrinth.");

      continue;
    }

    final modFile = File(p.join(".", config.data.installFolder, mod.fileName));
    if(!await modFile.exists()){
      print("Mod ${mod.fileName} is missing from the mods folder.");
      if(fixFoundIssues){
        await _fixSanityCheck(mod, expectedFileData: version.files.where((file) => file.filename == mod.fileName).firstOrNull ?? version.files.where((file) => file.primary).firstOrNull);
      }
      continue;
    }
    // Validate that the mod file's hash matches the hash in the lock file
    final bytes = await modFile.readAsBytes();
    final hash = sha512.convert(bytes).toString();

    ApiFile? apiFile = version.files.where((file) => file.filename == mod.fileName).firstOrNull ?? version.files.where((file) => file.primary).firstOrNull;
    if(apiFile == null){
      print("Mod version ${version.versionNumber} was did not have a file named ${mod.fileName} on Modrinth. This may indicate that the version has been removed");
      return;
    }

    if(hash != apiFile.hashes.sha512){
      print("Mod ${mod.fileName} has an invalid hash. Expected ${apiFile.hashes.sha512}, got $hash.");
      if(fixFoundIssues){
        await _fixSanityCheck(mod, modFile: modFile, expectedFileData: apiFile);
      }
      continue;
    }
  }
  await lock.save();

  print("Validation complete.");
}

Future<void> _fixSanityCheck(LockedModData modData, {File? modFile, ApiFile? expectedFileData}) async {

  final getVersion = modData.versionNumber;

  if(expectedFileData == null){
    Version? version = await getApi().sendRequest(.readVersion, SlugOrId(modData.versionId));
    if(version == null){
      print("Mod ${modData.modSlug} with version ID ${modData.versionId} not found on Modrinth while trying to fix hashes and files.");
      return;
    }
    expectedFileData = version.files.where((file) => file.filename == modData.fileName).firstOrNull;
    expectedFileData ??= version.files.where((file) => file.primary).firstOrNull;

    if(expectedFileData == null){
      print("Mod ${modData.modSlug} with version ID ${modData.versionId} has no primary file on Modrinth while trying to fix hashes and files.");
      return;
    }
  }

  if(modData.hashes.sha512 != expectedFileData.hashes.sha512){
    print("Mod ${modData.modSlug} has an invalid hash. Expected ${expectedFileData.hashes.sha512}, got ${modData.hashes.sha512}. Fixing...");
    modData.hashes = expectedFileData.hashes;
  }

  if(modFile != null && await modFile.exists()){
    final bytes = await modFile.readAsBytes();
    final hash = sha512.convert(bytes).toString();
    if(hash != expectedFileData.hashes.sha512){
      print("Mod ${modData.modSlug} has an invalid file. Expected hash ${expectedFileData.hashes.sha512}, got $hash. Fixing...");
      await modFile.delete();
      await downloadFile(expectedFileData.url, modFile.path);
    }
  }
  else {
    print("Mod ${modData.modSlug} is missing the file ${modData.fileName}. Downloading...");
    await downloadFile(expectedFileData.url, p.join(".", (await getMcGetConfig()).data.installFolder, expectedFileData.filename).toString());
  }

}