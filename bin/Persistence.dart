import 'package:mongo_dart/mongo_dart.dart';

class Persistence
{
  Db db;

  Persistence({String mongoConnectionString: "mongodb://127.0.0.1/ProjectBanana"})
  {
    __init(mongoConnectionString);
  }

  __init (String mongoConnectionString) async
  {
    db = new Db(mongoConnectionString);
    await db.open();

    db.collection("Users").find().forEach(print);
  }
}