import 'dart:math';
import 'package:finch/app.dart';
import 'package:test/test.dart';

void main() {
  group("check cron schedule", () {
    test('Check parser', () {
      expect(CronSchedule.parse("*/10 * * * * *"), isA<CronSchedule>());
      try {
        CronSchedule.parse("----------");
      } catch (e) {
        expect(e, isA<FormatException>());
      }
      var schedule = CronSchedule.parse("5 4 * * *");
      expect(schedule.seconds, [0]);
      expect(schedule.hours, [4]);
      expect(schedule.minutes, [5]);
      expect(schedule.days, null);
      expect(schedule.months, null);
      expect(schedule.weekdays, null);
      for (var i = 0; i < 10; i++) {
        expect(schedule.matches(randomDateTime(min: [5], hour: [4], sec: [0])),
            true);
      }

      schedule = CronSchedule.parse("*/25 * * * * *");
      expect(schedule.seconds, [0, 25, 50]);
      expect(schedule.minutes, null);
      expect(schedule.hours, null);
      expect(schedule.days, null);
      expect(schedule.months, null);
      expect(schedule.weekdays, null);
      for (var i = 0; i < 10; i++) {
        expect(schedule.matches(randomDateTime(sec: [0, 25, 50])), true);
      }

      // * */25 * * * *
      schedule = CronSchedule.parse("* */25 * * * *");
      for (var i = 0; i < 10; i++) {
        expect(
          schedule.matches(randomDateTime(
            min: [0, 25, 50],
          )),
          isTrue,
        );
        expect(
          schedule.matches(randomDateTime(
            min: [10, 40, 55, 1, 2, 3, 4],
          )),
          isFalse,
        );
      }
      expect(schedule.seconds, null);
      expect(schedule.minutes, [0, 25, 50]);
      expect(schedule.hours, null);
      expect(schedule.days, null);
      expect(schedule.months, null);
      expect(schedule.weekdays, null);
      // 57 */2 * 13 6 3
      schedule = CronSchedule.parse('57 */10 */2 13 6 *');
      expect(schedule.seconds, [57]);
      expect(schedule.minutes, [0, 10, 20, 30, 40, 50]);
      expect(schedule.hours, [0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22]);
      expect(schedule.days, [13]);
      expect(schedule.months, [6]);
      expect(schedule.weekdays, null);
      var time = DateTime.parse("2024-06-13 00:20:57");
      expect(schedule.matches(time), isTrue);
      time = DateTime.parse("2020-06-13 14:50:57");
      expect(schedule.matches(time), isTrue);
      time = DateTime.parse("2024-06-13 00:30:57");
      expect(schedule.matches(time), isTrue);
      time = DateTime.parse("2024-06-13 00:21:57");
      expect(schedule.matches(time), isFalse);
    });

    test("Check cron schedule functions", () {
      expect(
        FinchCron.durationToCron(Duration(seconds: 10)),
        "*/10 * * * * *",
        reason: "Error durationToCron",
      );
      expect(
        FinchCron.evrySecond(5),
        "*/5 * * * * *",
        reason: "Error evrySecond",
      );
      expect(
        FinchCron.evryMinute(2),
        "0 */2 * * * *",
        reason: "Error evryMinute",
      );
      expect(
        FinchCron.evryHour(3),
        "0 0 */3 * * *",
        reason: "Error evryHour",
      );
      expect(
        FinchCron.evryDay(4),
        "0 0 0 */4 * *",
        reason: "Error evryDay",
      );
      expect(
        FinchCron.evryMonth(5),
        "0 0 0 1 */5 *",
        reason: "Error evryMonth",
      );
      expect(
        FinchCron.evryYear(6),
        "0 0 0 1 1 */6",
        reason: "Error evryYear",
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

DateTime randomDateTime({
  List<int>? sec,
  List<int>? min,
  List<int>? hour,
  List<int>? day,
  List<int>? month,
  List<int>? year,
}) {
  int randomSecond = sec?[Random().nextInt(sec.length)] ?? Random().nextInt(60);
  int randomMinute = min?[Random().nextInt(min.length)] ?? Random().nextInt(60);
  int randomHour = hour?[Random().nextInt(hour.length)] ?? Random().nextInt(24);
  int randomDay =
      day?[Random().nextInt(day.length)] ?? Random().nextInt(28) + 1;
  int randomMonth =
      month?[Random().nextInt(month.length)] ?? Random().nextInt(12) + 1;
  int randomYear =
      year?[Random().nextInt(year.length)] ?? Random().nextInt(10) + 2020;
  var dateTime = DateTime(randomYear, randomMonth, randomDay, randomHour,
      randomMinute, randomSecond);
  return dateTime;
}
