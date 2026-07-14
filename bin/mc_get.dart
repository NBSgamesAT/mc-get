import 'package:mc_get/modrinth/modrinth.dart';
import 'secrets.dart';
import 'commands/cmd.dart';
import 'filesystem/configs.dart';
import 'filesystem/config_data.dart';

void main(List<String> arguments) async {

  runCommand(arguments);

}


ModrinthV2? _api;
Config<McGetJson>? _getConfig;
Config<McGetLock>? _lockConfig;

ModrinthV2 getApi() {
  _api ??= ModrinthV2("NBSgames", "mc-get", "0.0.1", ApiSecrets.modrinthContact.value, personalAccessToken: ApiSecrets.modrinthApiKey.value);
  return _api!;
}

Future<Config<McGetJson>> getMcGetConfig() async {
  _getConfig ??= Config.viaFile(filePath: "mc-get.json", codec: McGetJsonCodec());
  if(!_getConfig!.isLoaded) await _getConfig!.load(); 
  return _getConfig!;
}

Future<Config<McGetLock>> getMcGetLock() async {
  _lockConfig ??= Config.viaFile(filePath: "mc-get.lock", codec: McGetLockCodec());
  if(!_lockConfig!.isLoaded) await _lockConfig!.load();
  return _lockConfig!;
}