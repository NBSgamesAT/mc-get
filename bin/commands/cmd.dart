import "dart:io";

import "../filesystem/configs.dart";

void runCommand (List<String> arguments) async {
  if(arguments.isEmpty){
    noArgs(); // We might add a more interactive way in the future.
    return;
  }
  
  if(arguments[0] == "init"){
    await init();
  }

  
}

Future<void> init() async {
  // Alright. We have some things to do. Let's check if the config file exists.
  final config = Config.viaFile(filePath: "mc-get.json", codec: McGetJsonCodec());
  await config.load();

  if(config.data.minecraftVersion.isEmpty || config.data.loader.isEmpty){
    print("No config data found yet.");
  }
  else {
    print("Config data already exists. Do you want to overwrite it? (y/n)");

  }

  stdout.write("Please enter the exact version number of Minecraft as it is used on Modrinth (e.g. 26.2):");
  final minecraftVersion = stdin.readLineSync();
  if(minecraftVersion == null || minecraftVersion.isEmpty){
    print("Invalid Minecraft version. Please provide a valid version number.");
    return;
  }

  stdout.write("Please enter the loader type (e.g. forge, fabric, bukkit, spigot, paper):");
  final loader = stdin.readLineSync();
  if(["forge", "neoforge", "fabric", "quilt", "bukkit", "spigot", "paper"].contains(loader) == false){
    print("Invalid loader type. Please use one of the following: forge, neoforge, fabric, quilt, bukkit, spigot, paper");
    return;
  }
  stdout.write("Please enter the install folder override (optional, press enter to skip):");
  final installFolderOverride = stdin.readLineSync();

  config.data.minecraftVersion = minecraftVersion;
  config.data.loader = loader!;
  config.data.installFolderOverride = installFolderOverride;
  await config.save();

  stdout.write("Perfect! Config saved in mc-get.json");
  return;
}

void noArgs() {
  print("No arguments provided. Please provide a command.");
}

