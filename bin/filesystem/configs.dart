
abstract class ConfigMain {
  final String fileName;
  final String filePath;
  final ConfigParser parser;
  void save();
  String load();

  ConfigMain(this.fileName, this.filePath, this.parser);
}

class ConfigFile extends ConfigMain {

  ConfigFile(super.fileName, super.filePath, super.parser);

  @override
  void save() {}

  @override
  String load() => '';
}

abstract class ConfigParser<T> {
  T parse(String content);
  String serialize(T data);
}