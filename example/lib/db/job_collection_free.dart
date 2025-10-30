import 'package:finch/finch_model_less.dart';
import 'package:finch/finch_ui.dart';
import 'package:finch/finch_mongo_db.dart';

class JobCollectionFree extends DBCollectionFree {
  JobCollectionFree({required super.db})
      : super(
          name: 'job',
          form: formPerson,
          indexes: {
            'title': DBIndex(
              name: '_title_',
              key: 'title',
              background: false,
              unique: true,
              sparse: false,
            ),
          },
        );
  static DBFormFree get formPerson => DBFormFree(
        fields: {
          '_id': DBFieldFree<ObjectId>(
            readonly: true,
            hideJson: true,
          ),
          'title': DBFieldFree<String?>(
            validators: [
              FieldValidator.requiredField(),
              FieldValidator.fieldLength(min: 3),
            ],
          ),
        },
      );

  @override
  Future<List<Map<String, Object?>>> getAll({
    SelectorBuilder? selector,
    Map<String, Object?>? filter,
    FindOptions? findOptions,
    String? hint,
    int? skip,
    Map<String, Object>? sort,
    int? limit,
    Map<String, Object>? hintDocument,
    Map<String, Object>? projection,
    Map<String, Object>? rawOptions,
  }) async {
    var res = await super.getAll(
        selector: selector,
        filter: filter,
        findOptions: findOptions,
        hint: hint,
        skip: skip,
        sort: sort,
        limit: limit,
        hintDocument: hintDocument,
        projection: projection,
        rawOptions: rawOptions);
    if (res.isEmpty) {
      super.insert({
        'title': 'Example Job 1',
      });
      super.insert({
        'title': 'Example Job 2',
      });
      super.insert({
        'title': 'Example Job 3',
      });
    }
    return res;
  }
}
