import '../db/person_collection_free.dart';
import '../app.dart';
import '../models/mock_user_model.dart';
import 'package:finch/finch_route.dart';

class ApiDocuments {
  static final r_403 = [
    ApiResponse<int>('timestamp_start', def: 0),
    ApiResponse<String>('message', def: 'Please login'),
    ApiResponse<bool>('success', def: false),
    ApiResponse<int>('status', def: 403),
  ];

  static final r_404 = [
    ApiResponse<int>('timestamp_start', def: 0),
    ApiResponse<String>('message', def: 'Not found'),
    ApiResponse<bool>('success', def: false),
    ApiResponse<int>('status', def: 404),
  ];

  static final _pagging = [
    ApiParameter<String>('orderBy'),
    ApiParameter<bool>('orderReverse', def: true),
    ApiParameter<int>('pageSize', def: 0),
    ApiParameter<int>('page', def: 0),
  ];

  static Future<ApiDoc> info() async {
    return ApiDoc(
      response: {
        '200': [
          ApiResponse<int>('timestamp_start', def: 0),
          ApiResponse<Map<String, String>>('server', def: {}),
          ApiResponse<MockUserModel>(
            'users',
            def: [
              await MockUserModel().toParams(db: app.db),
              await MockUserModel().toParams(db: app.db),
            ],
          ),
          ApiResponse<Map>('usersPaging', def: {}),
          ApiResponse<Map<String, List<Map<String, String>>>>('server', def: {
            'Headers': [
              {'Content-Type': 'application/json'},
              {'Access-Control-Allow-Origin': '*'},
            ],
          }),
        ],
        '403': r_403,
        '404': r_404,
      },
      description: "Get all informations about server details.",
      parameters: _pagging,
    );
  }

  static Future<ApiDoc> onePerson() async {
    return ApiDoc(
      post: ApiDoc(
        response: {
          '200': [
            ApiResponse<int>('timestamp_start', def: 0),
            ApiResponse<bool>('success', def: true),
            ApiResponse<Map<String, String>>(
              'data',
              def: PersonCollectionFree.formPerson.fields.map((k, v) {
                return MapEntry(k, v.defaultValue?.call());
              }),
            ),
          ],
          '404': r_404,
        },
        description: "Update one person by id.",
        parameters: [
          ApiParameter<String>(
            'id',
            isRequired: true,
            paramIn: ParamIn.path,
          ),
          ApiParameter<String>(
            'name',
            isRequired: false,
            paramIn: ParamIn.header,
          ),
          ApiParameter<int>(
            'age',
            isRequired: false,
            paramIn: ParamIn.header,
          ),
          ApiParameter<double>(
            'height',
            isRequired: false,
            paramIn: ParamIn.header,
          ),
          ApiParameter<String>(
            'email',
            isRequired: true,
            paramIn: ParamIn.header,
          ),
          ApiParameter<String>(
            'married',
            isRequired: false,
            paramIn: ParamIn.header,
            def: false,
          ),
        ],
      ),
      get: ApiDoc(
        response: {
          '200': [
            ApiResponse<int>('timestamp_start', def: 0),
            ApiResponse<Map<String, String>>(
              'data',
              def: PersonCollectionFree.formPerson.fields.map((k, v) {
                return MapEntry(k, v.defaultValue?.call());
              }),
            ),
          ],
          '404': r_404,
        },
        description: "Get one person by id.",
        parameters: [
          ApiParameter<String>('id', isRequired: true, paramIn: ParamIn.path),
        ],
      ),
      delete: ApiDoc(
        response: {
          '200': [
            ApiResponse<int>('timestamp_start', def: 0),
            ApiResponse<bool>('success', def: true),
          ],
          '404': r_404,
        },
        description: "Delete one person by id.",
        parameters: [
          ApiParameter<String>('id', isRequired: true, paramIn: ParamIn.path),
        ],
      ),
    );
  }

  static Future<ApiDoc> allPerson() async {
    var doc = ApiDoc(
      response: {
        '200': [
          ApiResponse<int>('timestamp_start', def: 0),
          ApiResponse<List<Map<String, String>>>(
            'data',
            def: List.generate(
              5,
              (index) => PersonCollectionFree.formPerson.fields.map(
                (k, v) {
                  return MapEntry(k, v.defaultValue?.call());
                },
              ),
            ),
          ),
        ],
        '404': r_404,
      },
      description: "Get one person by id.",
      parameters: [..._pagging],
    );

    return ApiDoc(
      get: doc,
      post: doc,
    );
  }
}
