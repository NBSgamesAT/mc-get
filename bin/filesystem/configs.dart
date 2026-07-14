import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'config_data.dart';

abstract class ConfigCodec<T extends ConfigData<T>> {
  T createNew();
  String serialize(T data);
  T deserialize(String content);
}

abstract class ConfigStorage {
  FutureOr<void> createNewIfNotExists();
  FutureOr<void> save(String serializedContent);
  FutureOr<String> load();
}

class Config<T extends ConfigData<T>> {
  T? _data;
  final ConfigCodec<T> codec;
  final ConfigStorage storage;

  Config({
    required this.codec,
    required this.storage,
  });

  Config.viaFile({
    required String filePath,
    required this.codec,
  }) : storage = FileConfigStorage(filePath);

  T _checkNull() {
    if (_data == null) {
      throw Exception("Config data is null. Please load or create new data first.");
    }
    return _data!;
  }

  bool get isLoaded => _data != null;

  void resetData() {
    _data = codec.createNew();
  }

  T get data {
    return _checkNull();
  }

  Future<void> save() async {
    await storage.save(codec.serialize(_checkNull()));
  }

  Future<void> load() async {
    late String content;
    try {
      await storage.createNewIfNotExists();
      content = await storage.load();
      if(content.isNotEmpty) {
        _data = codec.deserialize(content);
        return;
      }
      _data = codec.createNew();
      save();
    } 
    catch(e, stackTrace) {
      throw Exception("Failed to load config: $e\n$stackTrace");
    }
  }
}

class FileConfigStorage implements ConfigStorage {
  final String filePath;

  FileConfigStorage(this.filePath);

  @override
  Future<void> createNewIfNotExists() async {
    final file = File(filePath);
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
  }

  @override
  Future<String> load() async {
    final file = File(filePath);
    return await file.readAsString();
  }

  @override
  Future<void> save(String serializedContent) async {
    final file = File(filePath);
    await file.writeAsString(serializedContent);
  }
}

const JsonEncoder _jsonEncoder = JsonEncoder.withIndent("  ");
const JsonDecoder _jsonDecoder = JsonDecoder();

abstract class JsonCodecMain<T extends ConfigData<T>> implements ConfigCodec<T> {
  T _fromJson(Map<String, dynamic> json);

  @override
  String serialize(T data){
    Map<String, dynamic> serialized = data.toJson();
    return _jsonEncoder.convert(serialized);
  }
  @override
  T deserialize(String content){
    Map<String, dynamic> json = _jsonDecoder.convert(content);
    return _fromJson(json);
  }
}

class McGetJsonCodec extends JsonCodecMain<McGetJson> {
  @override
  McGetJson createNew() {
    return McGetJson.empty();
  }

  @override
  McGetJson _fromJson(Map<String, dynamic> json) {
    return McGetJson.fromJson(json);
  }
}

class McGetLockCodec extends JsonCodecMain<McGetLock> {
  @override
  McGetLock createNew() {
    return McGetLock.empty();
  }

  @override
  McGetLock _fromJson(Map<String, dynamic> json) {
    return McGetLock.fromJson(json);
  }
}