import "dart:io";

import "package:mc_get/modrinth/facets.dart";
import "package:mc_get/modrinth/output_types/modrinth_api_error.dart";
import "package:mc_get/modrinth/output_types/project_light.dart";
import "package:mc_get/modrinth/output_types/version.dart";
import "package:crypto/crypto.dart" hide Hash;

import "package:path/path.dart" as p;

import "../mc_get.dart";
import "../filesystem/config_data.dart";
import "package:mc_get/modrinth/modrinth.dart";

part "cmd.install.dart";
part "cmd.sanity.dart";

void runCommand (List<String> arguments) async {
  if(arguments.isEmpty){
    noArgs(); // We might add a more interactive way in the future.
    return;
  }
  
  if(arguments[0] == "init"){
    await init();
  }
  else if(arguments[0] == "search"){
    if(arguments.length < 2){
      print("Please provide a search query.");
      return;
    }
    final query = arguments.sublist(1).join(" ");
    await search(query);
  }
  else if(arguments[0] == "install"){
    await installCommand(arguments);
  }
  else if(arguments[0] == "remove"){
    await removeCommand(arguments);
  }
  else if(arguments[0] == "validate"){
    if(arguments.length > 1 && arguments.contains("-f")){
      await validateLocal(fixFoundIssues: true);
      return;
    }
    await validateLocal();
  }
  else if(arguments[0] == "validate-online"){
    if(arguments.length > 1 && arguments.contains("-f")){
      await validateLocal(fixFoundIssues: true);
      return;
    }
    await validateViaApi();
  }
}

Future<bool> isValidConfig() async {
  final config = await getMcGetConfig();
  if(config.data.minecraftVersion.isEmpty || config.data.loader.isEmpty){
    return false;
  }
  return true;
}

Future<void> search(String query) async {
  final config = await getMcGetConfig();

  if(!await isValidConfig()){
    print("Please run the init command first to set up your config.");
    return;
  }

  final api = getApi(); // Let's the the API instance, which is initialized with the user's PAT if provided.
  final searchResults = await api.sendRequest(.searchProject, SearchInfo(query: query, facets: [
    [Facet(.versions, .equals, config.data.minecraftVersion)],
    [Facet(.categories, .equals, config.data.loader)],
    [Facet(.projectType, .equals, "mod")],
    [Facet(.serverSide, .equals, "optional"), Facet(.serverSide, .equals, "required"), Facet(.serverSide, .equals, "unknown")],
  ]));

  if(searchResults == null || searchResults.hits.isEmpty){
    print("No results found for query: $query");
    return;
  }
  print("Found ${searchResults.hits.length} results for query: $query");
  for(final hit in searchResults.hits){
    print("${hit.slug} (${hit.title}) - Author: ${hit.author} - Downloads: ${hit.downloads}");
    print("   ${hit.description}");
  }
}

Future<void> init() async {
  // Alright. We have some things to do. Let's check if the config file exists.
  final config = await getMcGetConfig();

  if(!await isValidConfig()){
    print("No config data found yet.");
  }
  else {
    print("Config data already exists. Do you want to reset it? (y/n)");
    final answer = stdin.readLineSync();
    if(answer == null || answer.toLowerCase() != "y"){
      print("Aborting.");
      return;
    }
    else {
      config.resetData();
      print("Config data reset. Please follow the promts to set up your config again.");
    }
  }

  stdout.write("Please enter the exact version number of Minecraft as it is used on Modrinth (e.g. 26.2): ");
  final minecraftVersion = stdin.readLineSync();
  if(minecraftVersion == null || minecraftVersion.isEmpty){
    print("Invalid Minecraft version. Please provide a valid version number.");
    return;
  }

  stdout.write("Please enter the loader type (e.g. forge, fabric, bukkit, spigot, paper): ");
  final loader = stdin.readLineSync();
  if(["forge", "neoforge", "fabric", "quilt", "bukkit", "spigot", "paper"].contains(loader) == false){
    print("Invalid loader type. Please use one of the following: forge, neoforge, fabric, quilt, bukkit, spigot, paper");
    return;
  }
  stdout.write("Please enter the install folder override (optional, press enter to skip): ");
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

Future<File> downloadFile(String url, String filePath) async {
  final client = HttpClient();
  try{
    final file = File(filePath);
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    if(response.statusCode != 200){
      throw Exception("Failed to download file from $url. Status code: ${response.statusCode}");
    }

    await response.pipe(file.openWrite());
  } finally {
    client.close();
  }
  return File(filePath);
}