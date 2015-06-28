library Persistence;

import 'package:mongo_dart/mongo_dart.dart';

class Persistence
{
  Db db;

  init ({String mongoConnectionString: "mongodb://localhost/ProjectBanana"}) async
  {
    db = new Db(mongoConnectionString);
    await db.open();

    db.collection("Users").find().forEach(__createUser);
  }

  __createUser(Map<String, String> data) async => new User(data);

  // Singleton Logic
  // ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
  static final Persistence _sharedPersistence = new Persistence._internal();

  factory Persistence() => _sharedPersistence;

  Persistence._internal();
}

class PersistenceObject
{
  Map _backingStorage;
  save() async {}

  PersistenceObject(this._backingStorage);
}

class User extends PersistenceObject
{
  static Future<User> getUser(String username) async
  {
    Persistence p = new Persistence();
    Map<String, String> result = await p.db.collection("Users").findOne({"name": username});

    if (result)
      return User(result);
  }

  static authenticate(String username, String password)
  {

  }

  User(Map data) : super(data);

  // Properties and shitty boilerplate shit stuff
  // ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
  String get name => _backingStorage["name"];
  String get password  => _backingStorage["password"];

  String set name(String newValue)
  {
    _backingStorage["name"] = newValue;
  }
  String set password(String newValue)
  {
    _backingStorage["password"] = newValue;
  }
}