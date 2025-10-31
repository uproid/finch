import '../app.dart';
import '../models/example_model.dart';
import 'package:finch/finch_model.dart';

class ExampleCollections extends DBCollection {
  ExampleCollections() : super(db: app.mongoDb, name: 'example');

  Future<ExampleModel> insertExample(ExampleModel model) async {
    var res = await collection.insert(model.toJson());
    ExampleModel newModel = ExampleModel.fromJson(res);
    return newModel;
  }

  Future<List<ExampleModel>> getAllExample({
    int? start,
    int? count,
  }) async {
    start = (start != null && start > 0) ? start : null;
    var rows = await collection
        .modernFind(
          limit: count,
          skip: start,
          sort: DQ.order('_id'),
        )
        .toList();
    return ExampleModel.fromListJson(rows);
  }
}
