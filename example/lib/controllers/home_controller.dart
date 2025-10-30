import 'dart:io';
import 'dart:math';
import '../db/sqlite/sqlite_books.dart';
import '../db/sqlite/sqlite_categories.dart';
import 'package:finch/finch_sqlite.dart';

import '../forms/book_form.dart';
import '../db/mysql/mysql_books.dart';
import '../db/mysql/mysql_categories.dart';
import 'package:finch/finch_mysql.dart';
import '../configs/setting.dart';
import '../db/example_collections.dart';
import '../models/example_model.dart';
import 'package:finch/finch_mail.dart';
import 'package:finch/finch_model.dart';
import 'package:finch/finch_route.dart';
import 'package:finch/finch_app.dart';
import 'package:finch/finch_tools.dart';
import 'package:finch/finch_ui.dart';
import '../app.dart';
import '../models/mock_user_model.dart';

class HomeController extends Controller {
  HomeController();

  @override
  Future<String> index() async {
    return renderTemplate('template/home');
  }

  Future<String> redirectToRoot() async {
    return rq.redirect('/');
  }

  Future<String> renderLocalhost() async {
    return rq.renderString(text: 'Localhost');
  }

  Future<String> render127001() async {
    return rq.renderString(text: '127.0.0.1');
  }

  Future<String> sseExample() async {
    Stream<String> streamer = Stream.periodic(Duration(seconds: 1), (count) {
      return 'This is an SSE message $count\n';
    }).take(10);

    return rq.renderSSEString(streamer);
  }

  Future<String> exampleForm() async {
    if (rq.method == Methods.POST) {
      var loginForm = FormValidator(
        name: 'loginForm',
        fields: {
          'email': [
            FieldValidator.isEmailField(),
            FieldValidator.requiredField(),
            FieldValidator.fieldLength(min: 5, max: 255)
          ],
          'password': [
            (value) async {
              return FieldValidateResult(
                success: value.toString().isPassword,
                error: 'error.invalid.password'.tr.write(),
              );
            },
            FieldValidator.requiredField(),
            FieldValidator.fieldLength(min: 8, max: 255)
          ],
        },
      );

      var result = await loginForm.validateAndForm();
      var loginResult = false;

      if (result.result) {
        var email = rq.get<String>('email', def: '');
        var password = rq.get<String>('password', def: '');
        if (email == 'example@uproid.com' && password == '@Test123') {
          loginResult = true;
        }
      }

      rq.addParams({
        'loginForm': result.form,
        'loginResult': loginResult,
      });
    }

    return renderTemplate('example/form');
  }

  Future<String> exampleCookie() async {
    return renderTemplate('example/cookie');
  }

  Future<String> exampleAuth() async {
    return renderTemplate('example/auth');
  }

  Future<String> exampleLanguage() async {
    var a = Random().nextInt(10);
    var b = Random().nextInt(10);
    var c = Random().nextInt(10);
    var d = Random().nextInt(10);

    rq.addParams({
      'exampleTString': TString('example.tstring').write(),
      'examplePathString': 'example.path'.tr.write(),
      'exampleTranslateParams': 'example.params'.tr.write({
        'name': 'Alexandre',
        'age': Random().nextInt(100),
      }),
      'exampleTranslateDynamic':
          'example.params.dynamic#$a#$b#$c#$d'.tr.write(),
    });
    return renderTemplate('example/i18n');
  }

  Future<String> exampleRoute() async {
    var allRoutes = await app.getAllRoutes();

    List<Map> convert(List<FinchRoute> routes, String parentPath, hasAuth) {
      var result = <Map>[];

      for (final route in routes) {
        for (var method in route.methods) {
          var map = route.toMap(
            parentPath,
            hasAuth || route.auth != null,
            method,
          );
          result.addAll(map);
        }
        if (route.children.isNotEmpty) {
          result.addAll(
            convert(
              route.children,
              "$parentPath${route.path}",
              hasAuth || route.auth != null,
            ),
          );

          for (var epath in route.extraPath) {
            result.addAll(
              convert(
                route.children,
                "$parentPath$epath",
                hasAuth || route.auth != null,
              ),
            );
          }
        }
      }

      return result;
    }

    var webRoutes = convert(allRoutes, '', false);
    webRoutes.sort(
        (a, b) => a['fullPath'].toString().compareTo(b['fullPath'].toString()));

    rq.addParam('routes', webRoutes);
    return renderTemplate('example/route');
  }

  Future<String> exampleAddCookie() async {
    var name = rq.get<String>('name', def: '');
    var value = rq.get<String>('value', def: '');
    var safe = rq.get<bool>('safe', def: false);
    var action = rq.get<String>('action', def: 'add');

    if (action == 'delete') {
      rq.removeCookie(name);
    } else if (action == 'add' && name.isNotEmpty && value.isNotEmpty) {
      rq.addCookie(name, value, safe: safe);
    }

    return exampleCookie();
  }

  Future<String> exampleSocket() async {
    return renderTemplate('example/socket');
  }

  Future<String> exampleDatabase() async {
    var action = rq.get<String>('action', def: '');
    var page = rq.get<int>('page', def: 0);
    ExampleCollections exampleCollections = ExampleCollections();

    if (rq.method == Methods.POST && action == 'add') {
      var title = rq.get<String>('title', def: '').trim();
      if (title.isNotEmpty) {
        var model = ExampleModel(title: title, slug: title.toSlug());
        await exampleCollections.insertExample(model);
      }
    } else if (action == 'delete') {
      var id = rq.get<String>('id', def: '');
      if (id.isNotEmpty) {
        await exampleCollections.delete(id);
      }
    }

    var countRecords = await exampleCollections.getCount();
    var pagination = UIPaging(
      widget: 'template/paging',
      page: page,
      total: countRecords,
      pageSize: 10,
    );

    var allRecords = await exampleCollections.getAllExample(
      start: pagination.start,
      count: pagination.pageSize,
    );
    rq.addParam('allRecords', await DBModel.toListParams(allRecords));
    rq.addParam('pagination', await pagination.render());
    return renderTemplate('example/database');
  }

  Future<String> paginationExample() async {
    var pageA = rq.get<int>('page_a', def: 0);
    var pageB = rq.get<int>('page_b', def: 0);
    var pageC = rq.get<int>('page_c', def: 0);

    var paginationA = UIPaging(
      widget: 'template/paging',
      page: pageA,
      total: 1000,
      pageSize: 10,
      prefix: 'page_a',
      otherQuery: {
        'page_b': pageB.toString(),
        'page_c': pageC.toString(),
      },
    );

    rq.addParam('paginationA', await paginationA.render());

    var paginationB = UIPaging(
      widget: 'template/paging',
      page: pageB,
      total: 500,
      pageSize: 10,
      widthSide: 5,
      prefix: 'page_b',
      otherQuery: {
        'page_a': pageA.toString(),
        'page_c': pageC.toString(),
      },
    );

    rq.addParam('paginationB', await paginationB.render());

    var paginationC = UIPaging(
      widget: 'template/paging',
      page: pageC,
      total: 1000,
      pageSize: 100,
      prefix: 'page_c',
      otherQuery: {
        'page_a': pageA.toString(),
        'page_b': pageB.toString(),
      },
    );

    rq.addParam('paginationC', await paginationC.render());

    return renderTemplate('example/pagination');
  }

  Future<String> exampleEmail() async {
    return renderTemplate('example/email');
  }

  Future<String> exampleEmailSend() async {
    var emailForm = FormValidator(
      name: 'emailForm',
      fields: {
        'email': [
          FieldValidator.requiredField(),
          FieldValidator.isEmailField(),
        ],
        'from': [
          FieldValidator.requiredField(),
          FieldValidator.isEmailField(),
        ],
        'subject': [
          FieldValidator.requiredField(),
          FieldValidator.fieldLength(min: 5, max: 255),
        ],
        'message': [
          FieldValidator.requiredField(),
          FieldValidator.fieldLength(min: 5, max: 1000),
        ],
        'host': [
          FieldValidator.requiredField(),
          FieldValidator.fieldLength(min: 5, max: 255),
        ],
        'port': [
          FieldValidator.isNumberField(
            min: 1,
            max: 65535,
            isRequired: true,
          ),
        ],
        'username': [
          FieldValidator.requiredField(),
          FieldValidator.fieldLength(min: 5, max: 255),
        ],
        'password': [
          FieldValidator.requiredField(),
          FieldValidator.fieldLength(min: 5, max: 255),
        ],
        'fromName': [
          FieldValidator.requiredField(),
          FieldValidator.fieldLength(min: 5, max: 255),
        ],
      },
    );

    var resEmailForm = await emailForm.validateAndForm();
    if (resEmailForm.result) {
      var resSendEmail = await MailSender.sendEmail(
        from: rq.get('from'),
        to: [rq.get('email')],
        subject: rq.get('subject'),
        text: rq.get('message'),
        html: rq.get('message'),
        host: rq.get('host'),
        port: rq.get('port', def: 465),
        username: rq.get('username'),
        password: rq.get('password'),
        ssl: rq.get('ssl', def: true),
        allowInsecure: rq.get('allowInsecure', def: true),
        fromName: rq.get('fromName'),
      );

      if (resSendEmail) {
        rq.addParam('sendEmailSuccess', 'Email sent successfully');
      } else {
        rq.addParam('sendEmailFailed', 'Email not sent');
      }
    }

    rq.addParams({
      'emailForm': resEmailForm.form,
    });

    return renderTemplate('example/email');
  }

  Future<String> renderTemplate(String widget, {bool toData = false}) async {
    MockUserModel? user;
    if (rq.session.containsKey('user')) {
      user = MockUserModel();
    }

    rq.addParam('languages', Setting.languages);

    rq.addParams({
      'title': 'logo.title',
      'year': DateTime.now().year,
      'user': await user?.toParams(),
      'mongoActive': app.db.isConnected,
      'mysqlActive': app.mysqlDb.connected,
      'version': 'v${FinchApp.info.version}',
    });

    return rq.renderView(path: widget, toData: toData);
  }

  Future<String> exampleError() async {
    throw Exception('This is an example error of exceptions');
  }

  Future<String> exampleDump() async {
    var variable = {
      "test": {
        "test1": 'test',
        "test2": 1,
        "test3": false,
        "test4": String,
        "test5": [1, 2, 3],
        "test6": {
          "key": "value",
          "key2": rq.getAssets(),
          "key3": rq.getValidator(),
          "key4": {
            "key": rq.getAllSession(),
            "key2": rq.getAll(),
            "key3": this,
          },
          "type": rq.getLanguage(),
        },
      },
    };

    rq.addParam('variable', variable);
    return renderTemplate('example/dump');
  }

  Future<String> indexApi() async => rq.renderData(
        data: {
          "message": "Hello World!!!",
          "success": true,
          "time": DateTime.now().toString(),
        },
      );

  Future<String> changeLanguage() async {
    var redirectTo = '/';
    var language = rq.uri.pathSegments.first;

    rq.changeLanguege(language);
    if (rq.uri.pathSegments.length > 1) {
      redirectTo = joinPaths(rq.uri.pathSegments.sublist(1));
    }
    redirectTo =
        rq.uri.replace(path: redirectTo, scheme: null, host: null).toString();

    return rq.redirect("/$redirectTo");
  }

  Future<String> socket() async {
    await socketManager.requestHandle(rq);
    return rq.renderSocket();
  }

  Future<String> info() async {
    Map dbInfo = app.db.isConnected ? await app.db.getBuildInfo() : {};
    var languageCount = [];
    FinchApp.appLanguages.forEach((key, value) {
      languageCount.add("$key (${value.length})");
    });

    var collections =
        app.db.isConnected ? await app.db.modernListCollections().toList() : [];
    var collectionNames = collections.map((e) => e['name']);

    var headers = <String, List<String>>{};
    rq.headers.forEach((name, values) {
      headers[name] = values;
    });

    var serverInfo = <String, Object>{
      'Address': {
        'URL': rq.url(''),
        'URI': rq.uri.path,
        'Email default': configs.mailDefault,
        'IP': rq.getIP(),
      },
      'Headers': headers,
      'Versions': {
        'Version': configs.version,
        'Finch version': FinchApp.info.version,
        'Dart version': Platform.version,
        'Mongo Version': dbInfo['version'] ?? 'Unknown',
      },
      'System': {
        'Number of processors': Platform.numberOfProcessors,
        'Oprating System':
            "${Platform.operatingSystem.toUpperCase()} ${Platform.operatingSystemVersion}",
      },
      'Database': {
        'MongoDB connected': app.db.isConnected,
        if (configs.isLocalDebug)
          'MongoDB Host': "${configs.dbConfig.host}:${configs.dbConfig.port}",
        'MongoDB DB name': configs.dbConfig.dbName,
        'MongoDB Collections': collectionNames.join(', '),
        'MySQL connected': app.mysqlDb.connected,
        if (configs.isLocalDebug)
          'MySQL Host':
              "${configs.mysqlConfig.host}:${configs.mysqlConfig.port}",
        'MySQL DB name': configs.mysqlConfig.databaseName,
        'SQLite connected': app.sqliteDriver.connected(),
      },
      'Date & Time': {
        'Idle Timeout': app.server!.idleTimeout,
        'Time': DateTime.now(),
        'Time stamp': DateTime.now().millisecondsSinceEpoch,
        'Time Zone Name': DateTime.now().timeZoneName,
      },
      'Language': {
        'Current language': rq.getLanguage(),
        'Languages Strings': languageCount.join(' , ').toUpperCase(),
      },
      'Server Info': {
        'Server Header': app.server!.serverHeader ?? 'Unknown',
        'Connection Count': app.server!.connectionsInfo().total,
        'Connection Active': app.server!.connectionsInfo().active,
        'Connection Closing': app.server!.connectionsInfo().closing,
        'Connection Idle': app.server!.connectionsInfo().idle,
      },
      'Cron Job': {
        'Cron count': app.crons.length,
        'Active Cron': app.crons
            .where((element) => element.status == CronStatus.running)
            .length,
        'Stopped Cron': app.crons
            .where((element) => element.status == CronStatus.stopped)
            .length,
        'Not started Cron': app.crons
            .where((element) => element.status == CronStatus.notStarted)
            .length,
      },
      'Socker IO Server': {
        'Socket Runing': app.hasSocket,
        'Socket online sessions': app.socketManager?.countClients ?? 0,
        'Socket online users': app.socketManager?.countUsers ?? 0,
      },
    };

    rq.addParam('server', serverInfo);
    if (rq.isApiEndpoint) {
      return rq.renderDataParam();
    }

    return renderTemplate('example/info');
  }

  Future<String> addNewPerson() async {
    final res = await personCollectionFree.insert(rq.getAll());
    if (res.success) {
      rq.addParam('data', res.formValues);
    } else {
      rq.addParam('form', res.toJson());
    }
    return _renderPerson(data: {
      'success': res.success,
    });
  }

  Future<String> replacePerson() async {
    final id = rq.getParam('id', def: '').toString();
    final res = await personCollectionFree.replaceOne(id, rq.getAll());

    if (res == null) {
      return _renderPerson(
        data: {'success': false},
        status: 404,
      );
    }

    if (res.success) {
      rq.addParam('data', res.formValues);
    } else {
      rq.addParam('form', res.toJson());
    }
    return _renderPerson(data: {
      'success': res.success,
    });
  }

  Future<String> allPerson() async {
    final countAll = await personCollectionFree.getCount();
    final pageSize = rq.get<int>('pageSize', def: 20);
    final orderBy = rq.get<String>('orderBy', def: '_id');
    final orderReverse = rq.get<bool>('orderReverse', def: true);

    UIPaging paging = UIPaging(
      total: countAll,
      pageSize: pageSize,
      widget: '',
      page: rq.get<int>('page', def: 1),
    );

    final res = await personCollectionFree.getAll(
      limit: paging.pageSize,
      skip: paging.start,
      sort: DQ.order(orderBy, orderReverse),
    );

    return _renderPerson(data: {
      'success': res.isNotEmpty,
      'data': res,
      'paging': await paging.renderData(),
    });
  }

  Future<String> onePerson() async {
    final id = rq.getParam('id', def: '').toString();
    final action = rq.get<String>('action', def: '');
    final res = await personCollectionFree.getById(id);
    if (res != null) {
      if (action == 'EDIT') {
        var res = await personCollectionFree.mergeOne(id, rq.getAll());
        if (res != null && res.success) {
          return rq.redirect('/example/person');
        } else {
          rq.addParam('form', res?.toJson());
        }
      } else {
        var personForm = await personCollectionFree.validate(res);
        rq.addParam('form', personForm.toJson());
      }
    }
    return _renderPerson(data: {
      'success': res != null,
      'data': res,
    });
  }

  Future<String> deletePerson() async {
    final id = rq.getParam('id', def: '').toString();
    final res = await personCollectionFree.delete(id);
    return _renderPerson(data: {
      'success': res,
    });
  }

  Future<String> _renderPerson({
    required Map<String, Object?> data,
    status = 200,
  }) async {
    if (rq.isApiEndpoint) {
      return rq.renderDataParam(
        data: data,
        status: status,
      );
    }

    final countAll = await personCollectionFree.getCount();
    final pageSize = rq.get<int>('pageSize', def: 10);
    final orderBy = rq.get<String>('orderBy', def: '_id');
    final orderReverse = rq.get<bool>('orderReverse', def: true);

    UIPaging paging = UIPaging(
      total: countAll,
      pageSize: pageSize,
      widget: 'template/paging',
      page: rq.get<int>('page', def: 1),
    );

    final res = await personCollectionFree.getAllWithJob(
      limit: paging.pageSize,
      skip: paging.start,
      sort: DQ.order(orderBy, orderReverse),
    );

    final jobs = await jobCollectionFree.getAll();

    data = {
      ...data,
      'success': res.isNotEmpty,
      'allPerson': res,
      'paging': await paging.render(),
      'jobs': jobs
    };
    rq.addParams(data);
    return renderTemplate('example/person');
  }

  Future<String> exampleMysql() async {
    MysqlBooks tableBooks = MysqlBooks(app.mysqlDriver);
    MysqlCategories tableCategories = MysqlCategories(app.mysqlDriver);
    final action = rq.get<String>('action', def: '');
    rq.addParam('action', action);
    BookForm bookForm = BookForm(isSqlite: false);
    await bookForm.initOptions();

    if (action == 'add_category') {
      final title = rq.get<String>('title', def: '');
      if (title.isNotEmpty) {
        var res = await tableCategories.addNewCategory(title: title);

        addFlash(
          res.success
              ? 'Category added successfully'
              : 'Error adding category: ${res.errorMsg}',
          type: res.success ? FlashType.SUCCESS : FlashType.ERROR,
        );
      } else {
        addFlash('Category title is required', type: FlashType.ERROR);
      }
      return rq.redirect(FinchRoute.getPath('root.mysql'));
    } else if (action == 'delete_category') {
      final id = rq.get<String>('id', def: '');
      await tableCategories.deleteCategory(id);
      addFlash('Category deleted successfully');
    } else if (action == 'delete') {
      final id = rq.get<String>('id', def: '');
      await tableBooks.deleteBook(id);

      addFlash('Book deleted successfully', type: FlashType.ERROR);
    } else if (action == 'delete_all') {
      var ids = rq.get<String>('selected_books', def: '').split(',');
      await tableBooks.deleteAllBooks(ids);
    } else if (action == 'add' || action == 'edit' || action == 'update') {
      Map<String, dynamic>? book;
      var bookId = rq.get<String>('id', def: '');
      rq.addParam('id', bookId);

      if (action == 'edit' || action == 'update' || action == 'add') {
        book = await tableBooks.getBookById(bookId);
        var isValid = await bookForm.check();
        SqlDatabaseResult? res;

        if (action == "update" && book != null && isValid) {
          res = await tableBooks.updateBook(
            id: bookId,
            title: bookForm.get<String>('title', def: ''),
            author: bookForm.get<String>('author', def: ''),
            publishedDate: bookForm.get<String>('published_date', def: ''),
            categoryId: bookForm.get<String>('category_id', def: ''),
          );
        } else if (action == "add" && isValid) {
          res = await tableBooks.addNewBook(
            title: bookForm.get<String>('title', def: ''),
            author: bookForm.get<String>('author', def: ''),
            publishedDate: bookForm.get<String>('published_date', def: ''),
            categoryId: bookForm.get<String>('category_id', def: ''),
          );
        }

        if (res != null) {
          addFlash(
            res.success ? 'Book saved successfully' : 'Error saving book',
            type: res.success ? FlashType.SUCCESS : FlashType.ERROR,
          );
          return rq.redirect(FinchRoute.getPath('root.mysql'));
        }

        await bookForm.fill(res?.assocFirst ?? book);
      } else {
        return rq.redirect(FinchRoute.getPath('root.mysql'));
      }
    }

    var sort = rq.get<String>('sort', def: 'b.id');
    var order = rq.get<String>('order', def: 'asc');

    var formFilter = FormValidator(
      fields: {
        'filter_b.id': [
          FieldValidator.isNumberField(isRequired: false),
        ],
        'filter_published_date': [
          FieldValidator.isDateField(isRequired: false),
        ],
        'filter_category_id': [
          FieldValidator.isNumberField(isRequired: false),
        ],
        'filter_count': [
          FieldValidator.isNumberField(isRequired: false),
        ],
        'filter_title': [],
        'filter_author': [],
      },
      name: 'filter_books',
    );
    var filter = await formFilter.validateAndForm();
    rq.addParam('filter_books', filter.form);
    var page = rq.get<int>('page', def: 1);
    var pageSize = rq.get<int>('pageSize', def: 10);

    var paging = UIPaging(
      widget: 'template/paging',
      page: page,
      total: 10,
      pageSize: pageSize,
      otherQuery: {
        ...FormValidator.extractString(filter.form),
        'pageSize': pageSize.toString(),
        'sort': sort,
        'order': order,
      },
    );

    var books = await tableBooks.getAllBooks(
      sort,
      order,
      filters: filter.result ? FormValidator.extractValues(filter.form) : {},
      limit: paging.pageSize,
      offset: paging.offset,
    );
    paging.total = books.count;
    var categories = await tableCategories.getAllCategories(
      'id',
      'ASC',
    );
    rq.addParam('books', books.rows.assoc);
    rq.addParam('categories', categories.rows.assoc);
    rq.addParam('count_total', books.count);
    rq.addParam('paging', await paging.render(toData: rq.isApiEndpoint));

    if (rq.isApiEndpoint) {
      return rq.renderDataParam();
    }

    return renderTemplate('example/mysql/overview');
  }

  Future<String> exampleSqlite() async {
    SqliteBooks tableBooks = SqliteBooks(app.sqliteDriver);
    SqliteCategories tableCategories = SqliteCategories(app.sqliteDriver);
    final action = rq.get<String>('action', def: '');
    rq.addParam('action', action);
    BookForm bookForm = BookForm(isSqlite: true);
    await bookForm.initOptions();

    if (action == 'add_category') {
      final title = rq.get<String>('title', def: '');
      if (title.isNotEmpty) {
        var res = await tableCategories.addNewCategory(title: title);

        addFlash(
          res.success
              ? 'Category added successfully'
              : 'Error adding category: ${res.errorMsg}',
          type: res.success ? FlashType.SUCCESS : FlashType.ERROR,
        );
      } else {
        addFlash('Category title is required', type: FlashType.ERROR);
      }
      return rq.redirect(FinchRoute.getPath('root.sqlite'));
    } else if (action == 'delete_category') {
      final id = rq.get<String>('id', def: '');
      await tableCategories.deleteCategory(id);
      addFlash('Category deleted successfully');
    } else if (action == 'delete') {
      final id = rq.get<String>('id', def: '');
      await tableBooks.deleteBook(id);

      addFlash('Book deleted successfully', type: FlashType.ERROR);
    } else if (action == 'delete_all') {
      var ids = rq.get<String>('selected_books', def: '').split(',');
      await tableBooks.deleteAllBooks(ids);
    } else if (action == 'add' || action == 'edit' || action == 'update') {
      Map<String, dynamic>? book;
      var bookId = rq.get<String>('id', def: '');
      rq.addParam('id', bookId);

      if (action == 'edit' || action == 'update' || action == 'add') {
        book = await tableBooks.getBookById(bookId);
        var isValid = await bookForm.check();
        SqlDatabaseResult? res;

        if (action == "update" && book != null && isValid) {
          res = await tableBooks.updateBook(
            id: bookId,
            title: bookForm.get<String>('title', def: ''),
            author: bookForm.get<String>('author', def: ''),
            publishedDate: bookForm.get<String>('published_date', def: ''),
            categoryId: bookForm.get<String>('category_id', def: ''),
          );
        } else if (action == "add" && isValid) {
          res = await tableBooks.addNewBook(
            title: bookForm.get<String>('title', def: ''),
            author: bookForm.get<String>('author', def: ''),
            publishedDate: bookForm.get<String>('published_date', def: ''),
            categoryId: bookForm.get<String>('category_id', def: ''),
          );
        }

        if (res != null) {
          addFlash(
            res.success ? 'Book saved successfully' : 'Error saving book',
            type: res.success ? FlashType.SUCCESS : FlashType.ERROR,
          );
          return rq.redirect(FinchRoute.getPath('root.sqlite'));
        }

        await bookForm.fill(res?.assocFirst ?? book);
      } else {
        return rq.redirect(FinchRoute.getPath('root.sqlite'));
      }
    }

    var sort = rq.get<String>('sort', def: 'b.id');
    var order = rq.get<String>('order', def: 'asc');

    var formFilter = FormValidator(
      fields: {
        'filter_b.id': [
          FieldValidator.isNumberField(isRequired: false),
        ],
        'filter_published_date': [
          FieldValidator.isDateField(isRequired: false),
        ],
        'filter_category_id': [
          FieldValidator.isNumberField(isRequired: false),
        ],
        'filter_count': [
          FieldValidator.isNumberField(isRequired: false),
        ],
        'filter_title': [],
        'filter_author': [],
      },
      name: 'filter_books',
    );
    var filter = await formFilter.validateAndForm();
    rq.addParam('filter_books', filter.form);
    var page = rq.get<int>('page', def: 1);
    var pageSize = rq.get<int>('pageSize', def: 10);

    var paging = UIPaging(
      widget: 'template/paging',
      page: page,
      total: 10,
      pageSize: pageSize,
      otherQuery: {
        ...FormValidator.extractString(filter.form),
        'pageSize': pageSize.toString(),
        'sort': sort,
        'order': order,
      },
    );

    var books = await tableBooks.getAllBooks(
      sort,
      order,
      filters: filter.result ? FormValidator.extractValues(filter.form) : {},
      limit: paging.pageSize,
      offset: paging.offset,
    );
    paging.total = books.count;
    var categories = await tableCategories.getAllCategories(
      'id',
      'ASC',
    );
    rq.addParam('books', books.rows.assoc);
    rq.addParam('categories', categories.rows.assoc);
    rq.addParam('count_total', books.count);
    rq.addParam('paging', await paging.render(toData: rq.isApiEndpoint));

    if (rq.isApiEndpoint) {
      return rq.renderDataParam();
    }

    return renderTemplate('example/sqlite/overview');
  }

  void addFlash(String text, {final type = FlashType.SUCCESS}) {
    List<Map<String, String>> flashMessages = rq.session['flashes'] ?? [];
    flashMessages.add({
      'type': type.toString(),
      'text': text,
    });
    rq.session['flashes'] = flashMessages;
  }
}

enum FlashType {
  SUCCESS,
  ERROR,
  DANGER,
  INFO,
  WARNING;

  @override
  String toString() {
    switch (this) {
      case FlashType.SUCCESS:
        return 'success';
      case FlashType.ERROR:
      case FlashType.DANGER:
        return 'danger';
      case FlashType.INFO:
        return 'info';
      case FlashType.WARNING:
        return 'warning';
    }
  }
}
