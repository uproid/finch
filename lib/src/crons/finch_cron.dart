import 'dart:async';

/// A class to manage and run cron jobs using Finch's own built-in scheduler.
/// The [FinchCron] class schedules and manages tasks based on the given cron schedule.
/// It includes functionalities for delayed starts, counting executions, and tracking status.
/// Example:
/// ```dart
/// final cronJob = FinchCron(
///   schedule: '*/5 * * * * *', // Run every 5 seconds
///   onCron: (count, cron) async {
///     print('Task executed $count times');
///   },
/// );
/// cronJob.start();
/// ```
class FinchCron {
  /// Cron schedule in string format.
  ///
  /// The schedule should be in a cron format (e.g., `*/5 * * * * *`).
  String schedule;

  /// Internal parsed representation of [schedule].
  late final CronSchedule _parsedSchedule;

  /// Internal timer used to check the schedule once per second.
  Timer? _timer;

  /// The last time a tick matched and the task was executed.
  DateTime? _lastRun;

  /// The time the cron was registered (in microseconds since epoch).
  ///
  /// This is automatically set when the [FinchCron] instance is created.
  late final int registerTime;

  /// The callback function to be executed on each cron tick.
  ///
  /// The function receives the current tick count and the [FinchCron] instance as parameters.
  Future Function(int count, FinchCron cron) onCron;

  /// The number of times the cron task has been executed.
  int get counter => _counter;

  /// Internal counter to track the number of executions.
  int _counter = 0;

  /// Indicates whether the first execution should be delayed.
  ///
  /// If set to `true`, the first tick will not run immediately when the cron starts.
  bool delayFirstMoment = true;

  /// The current status of the cron job.
  ///
  /// Can be [CronStatus.notStarted], [CronStatus.running], or [CronStatus.stopped].
  CronStatus _status = CronStatus.notStarted;

  /// The current status of the cron job.
  ///
  /// Can be [CronStatus.notStarted], [CronStatus.running], or [CronStatus.stopped].
  /// Public getter to access the current cron status.
  CronStatus get status => _status;

  /// Creates an instance of [FinchCron].
  ///
  /// [onCron] is required and specifies the callback function to be executed on each cron tick.
  /// [schedule] is required and specifies the cron schedule.
  /// [delayFirstMoment] is optional and defaults to `true`. When `false`, the first tick runs immediately.
  FinchCron({
    required this.onCron,
    required this.schedule,
    this.delayFirstMoment = true,
  }) {
    registerTime = DateTime.now().microsecondsSinceEpoch;
    _parsedSchedule = CronSchedule.parse(schedule);
  }

  /// Starts the cron job.
  ///
  /// This method changes the cron status to [CronStatus.running] and schedules the tasks according to the [schedule].
  /// If [delayFirstMoment] is `false`, the first tick runs immediately.
  /// Returns the instance of [FinchCron] for chaining.
  FinchCron start() {
    _status = CronStatus.running;

    if (delayFirstMoment == false) {
      _counter++;
      onCron(_counter, this);
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      if (!_parsedSchedule.matches(now)) return;

      final last = _lastRun;
      if (last != null &&
          last.year == now.year &&
          last.month == now.month &&
          last.day == now.day &&
          last.hour == now.hour &&
          last.minute == now.minute &&
          last.second == now.second) {
        return;
      }

      _lastRun = now;
      _counter++;
      onCron(_counter, this);
    });

    return this;
  }

  /// Converts a [Duration] to a cron expression.
  ///
  /// This method is useful if you want to generate a cron schedule from a [Duration].
  /// Throws an [ArgumentError] if the duration is less than 1 second.
  ///
  /// Example:
  /// ```dart
  /// String cronExpr = FinchCron.durationToCron(Duration(seconds: 10)); // "*/10 * * * * *"
  /// ```
  static String durationToCron(Duration duration) {
    int sec = duration.inSeconds;
    if (sec < 1) {
      throw ArgumentError('Duration must be at least 1 sec.');
    }
    String cronExpression = '*/$sec * * * * *';

    return cronExpression;
  }

  static String evrySecond([int sec = 1]) {
    return '*/$sec * * * * *';
  }

  static String evryMinute([int min = 1]) {
    return '0 */$min * * * *';
  }

  static String evryHour([int hour = 1]) {
    return '0 0 */$hour * * *';
  }

  static String evryDay([int day = 1]) {
    return '0 0 0 */$day * *';
  }

  static String evryMonth([int month = 1]) {
    return '0 0 0 1 */$month *';
  }

  static String evryYear([int year = 1]) {
    return '0 0 0 1 1 */$year';
  }

  /// Stops the cron job and cleans up resources.
  ///
  /// This method changes the cron status to [CronStatus.stopped] and closes the internal timer.
  void close() {
    _timer?.cancel();
    _timer = null;
    _status = CronStatus.stopped;
  }
}

/// Enum to represent the status of the cron job.
enum CronStatus {
  /// Indicates that the cron job is currently running.
  running,

  /// Indicates that the cron job has been stopped.
  stopped,

  /// Indicates that the cron job has not started yet.
  notStarted,
}

/// Internal parsed cron schedule supporting the 5-field (`min hour day month weekday`)
/// and 6-field (`sec min hour day month weekday`) formats.
///
/// Supports `*`, single values, comma-separated lists, `-` ranges and `*/n` or
/// `a-b/n` step values, matching the syntax used throughout [FinchCron]'s helpers
/// (e.g. `evrySecond`, `evryMinute`).
class CronSchedule {
  final List<int>? seconds;
  final List<int>? minutes;
  final List<int>? hours;
  final List<int>? days;
  final List<int>? months;
  final List<int>? weekdays;

  CronSchedule({
    this.seconds,
    this.minutes,
    this.hours,
    this.days,
    this.months,
    this.weekdays,
  });

  @override
  String toString() {
    return "Class<CronSchedule>(sec: $seconds, min: $minutes, hour: $hours, "
        "month: $months, week: $weekdays)";
  }

  factory CronSchedule.parse(String cronFormat) {
    final parts =
        cronFormat.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();

    if (parts.length != 5 && parts.length != 6) {
      throw FormatException('Invalid cron expression: $cronFormat');
    }

    // A 5-field expression has no seconds field, so per standard cron
    // semantics it fires once per matching minute (at second 0), not on
    // every second of that minute.
    final fields = parts.length == 5 ? ['0', ...parts] : parts;

    return CronSchedule(
      seconds: _parseField(fields[0], 0, 59),
      minutes: _parseField(fields[1], 0, 59),
      hours: _parseField(fields[2], 0, 23),
      days: _parseField(fields[3], 1, 31),
      months: _parseField(fields[4], 1, 12),
      weekdays: _parseField(fields[5], 1, 7, isWeekday: true),
    );
  }

  static List<int>? _parseField(
    String? field,
    int min,
    int max, {
    bool isWeekday = false,
  }) {
    if (field == null || field == '*') return null;

    final values = <int>{};
    for (final segment in field.split(',')) {
      values.addAll(_parseSegment(segment, min, max));
    }

    var list = values.toList()..sort();
    if (isWeekday) {
      list = list.map((v) => v == 0 ? 7 : v).toSet().toList()..sort();
    }
    return list;
  }

  static List<int> _parseSegment(String segment, int min, int max) {
    int step = 1;
    String rangePart = segment;

    if (segment.contains('/')) {
      final stepSplit = segment.split('/');
      if (stepSplit.length != 2) {
        throw FormatException('Invalid cron field: $segment');
      }
      rangePart = stepSplit[0];
      step = int.tryParse(stepSplit[1]) ?? -1;
      if (step < 1) {
        throw FormatException('Invalid step value in cron field: $segment');
      }
    }

    int lower;
    int upper;

    if (rangePart == '*') {
      lower = min;
      upper = max;
    } else if (rangePart.contains('-')) {
      final rangeSplit = rangePart.split('-');
      if (rangeSplit.length != 2) {
        throw FormatException('Invalid cron field: $segment');
      }
      lower = int.tryParse(rangeSplit[0]) ?? -1;
      upper = int.tryParse(rangeSplit[1]) ?? -1;
    } else {
      final value = int.tryParse(rangePart);
      if (value == null) {
        throw FormatException('Invalid cron field: $segment');
      }
      return [value];
    }

    if (lower < min || upper > max || lower > upper) {
      throw FormatException('Invalid cron field: $segment');
    }

    return [
      for (var v = lower; v <= upper; v += step) v,
    ];
  }

  bool matches(DateTime time) {
    if (seconds != null && !seconds!.contains(time.second)) return false;
    if (minutes != null && !minutes!.contains(time.minute)) return false;
    if (hours != null && !hours!.contains(time.hour)) return false;
    if (days != null && !days!.contains(time.day)) return false;
    if (months != null && !months!.contains(time.month)) return false;
    if (weekdays != null && !weekdays!.contains(time.weekday)) return false;
    return true;
  }
}
