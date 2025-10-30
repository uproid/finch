import 'dart:io';
import 'package:finch/finch_app.dart';
import 'package:finch/finch_tools.dart';
import 'package:finch/finch_model_less.dart';
import 'package:test/test.dart';

void main() {
  group('Test tools', () {
    test("Select Map", () {
      var map = {'a': 1, 'b': 2, 'c': 3, 'd': 4};
      map = map.select(['a', 'c']);
      expect(map.keys, ['a', 'c']);
      map.remove('a');
      expect(map.keys, ['c']);
      expect(
        {'a': 1, 'b': 2, 'c': 3}.joinMap(':', ','),
        "a:1,b:2,c:3",
        reason: "Error joinMap",
      );
      expect(
        QueryString.parse("a=1&b=2&c=3"),
        {'a': '1', 'b': '2', 'c': '3'},
        reason: "Error QueryString",
      );
    });

    group("Test String tools", () {
      test("Check email", () {
        expect(
          "info@example.com".isEmail,
          true,
          reason: "Error checking email",
        );
        expect(
          "info@example".isEmail,
          false,
          reason: "Error checking email",
        );
      });

      test("Check password", () {
        expect("test123".isPassword, false, reason: "Error checking password");
        expect("@Test123".isPassword, true, reason: "Error checking password");
      });

      test("String convert", () {
        expect(
          ConvertSize.toLogicSizeString(10000000),
          "9.54 MB",
          reason: "Error convert size",
        );
        expect("test123".toInt(def: -1), -1, reason: "Error string to int");
        expect("123".toInt(), 123, reason: "Error string to int");
        expect("false".toBool, false, reason: "Error string to bool");
        expect("true".toBool, true, reason: "Error string to bool");
        expect("TRUE".toBool, true, reason: "Error string to bool");
        expect("aaa".toBool, false, reason: "Error string to bool");
        expect("1".toBool, true, reason: "Error string to bool");
        expect("0".toBool, false, reason: "Error string to bool");
        expect("FAlSE".toBool, false, reason: "Error string to bool");
        expect(
          "uproid".toBase32(),
          "OVYHE33JMQ======",
          reason: "Error convert to base32",
        );
        expect(
          "OVYHE33JMQ======".fromBase32(),
          "uproid",
          reason: "Error convert from base32",
        );
        expect(
          "uproid".toBase64(),
          "dXByb2lk",
          reason: "Error convert to toBase64",
        );
        expect(
          "dXByb2lk".fromBase64(),
          "uproid",
          reason: "Error convert from fromBase64",
        );

        expect(
          "uproid".toMd5(),
          "0630d50d13d7d02e1851d369d9b68ac8",
          reason: "Error convert to toMd5",
        );

        expect(
          "uproid".toSafe("password"),
          "ovhT9EmhaO6R++2Ni2xRhA==",
          reason: "Error convert to toSafe",
        );
        expect(
          "ovhT9EmhaO6R++2Ni2xRhA==".fromSafe("password"),
          "uproid",
          reason: "Error convert to fromSafe",
        );

        expect("aa123".isInt, false, reason: "Error isInt");
        expect("557798".isInt, true, reason: "Error isInt");
        expect(
          "www.Uproid.Com Web".toSlug(),
          "wwwuproidcom-web",
          reason: "Error toSlug",
        );
        expect(
          "wwwuproidcom-web".isSlug(),
          true,
          reason: "Error isSlug",
        );
        expect(
          "www.Uproid.Com Web".isSlug(),
          false,
          reason: "Error isSlug",
        );
      });
    });

    test("Test Path", () {
      expect(
        joinPaths(["uproid.com", "ln", "en"]),
        Platform.isWindows ? "uproid.com\\ln\\en" : "uproid.com/ln/en",
        reason: "Error joinPaths",
      );

      expect(
        pathNorm("d:\\movie/book", normSlashs: true),
        "d:/movie/book",
        reason: "Error pathNorm",
      );
    });

    test("Test Paths Equal", () {
      var res = pathsEqual([
        "/movie/book\\",
        "movie/book/",
        "movie/book",
      ]);

      expect(res, true, reason: "Error pathsEqual");

      var res2 = pathsEqual([
        "/movie/book\\",
        "movie/book/",
        "movie/book",
        "movie/book/news",
      ]);

      expect(res2, false, reason: "Error pathsEqual");
    });

    test("Test LMap", () {
      LMap lmap = LMap(
        {
          "a": 1,
          "d": 4,
        },
        def: "not found",
      );

      expect(lmap["a"], 1, reason: "Error LMap");
      expect(lmap["c"], "not found", reason: "Error LMap");
      lmap = LMap(
        {
          "a": 1,
          "d": 4,
        },
        def: "@key",
      );
      expect(lmap["c"], "c", reason: "Error LMap");
      lmap = LMap(
        {
          "a": 1,
          "d": 4,
        },
        def: "@key_uproid",
      );
      expect(lmap["test"], "test_uproid", reason: "Error LMap");
    });
  });

  group("Test ModelLess", () {
    test("Test ModelLess", () {
      var model = ModelLess.fromJson('''{
        "a": 1,
        "b": 2,
        "c": 3,
        "d": 4,
        "e": {
          "f": 5,
          "g": {
            "h": 6,
            "i": 7
          },
          "h": [
            11,
            22,
            33
          ],
          "i": [
            {"j": 1},
            {"j": 2},
            {"j": 3}
          ]
        }
      }''');

      expect(model.get<int>("a"), 1, reason: "Error ModelLess");
      expect(model.get<int>("e/f"), 5, reason: "Error ModelLess");
      expect(model.getByPath<int>(["e", "f"]), 5, reason: "Error ModelLess");
      expect(
        model.get<int>('e/h/0'),
        11,
        reason: "Error ModelLess",
      );
      expect(
        model.get<int>('e/i/0/j'),
        1,
        reason: "Error ModelLess",
      );
    });

    test("Map Navigation", () {
      var map = {
        "a": 1,
        "b": 2,
        "c": 3,
        "d": 4,
        "e": {
          "f": 5,
          "g": {"h": 6, "i": 7},
          "h": [11, 22, 33],
          "i": [
            {"j": 1},
            {"j": 2},
            {"j": 3}
          ]
        }
      };

      expect(
        map.navigation<int>(path: "e/f", def: -1),
        5,
        reason: "Error Map Navigation",
      );
      expect(
        map.navigation<int>(path: "e/h/0", def: -1),
        11,
        reason: "Error Map Navigation",
      );
      expect(
        map.navigation<int>(path: "e/i/0/j", def: -1),
        1,
        reason: "Error Map Navigation",
      );
      expect(
        map.navigation<int>(path: "e/i/5/j", def: -1),
        -1,
        reason: "Error Map Navigation",
      );
    });
  });

  group("check cron job", () {
    int i = 0;
    test("Cron job", () async {
      var cronJob = FinchCron(
        schedule: FinchCron.evrySecond(),
        delayFirstMoment: false,
        onCron: (count, cron) async {
          if (count >= 5) {
            cron.close();
          }

          i = count;
        },
      );

      cronJob.start();
      await Future.delayed(Duration(seconds: 6));
      expect(i, 5, reason: "Error cron job");
    });
  });
}
