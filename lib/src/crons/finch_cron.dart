import 'package:cron/cron.dart';

/// A class to manage and run cron jobs using the `cron` package.
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

  /// Internal instance of the Cron package.
  final _cron = Cron();

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

    _cron.schedule(Schedule.parse(schedule), () async {
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
    return '0 0 0 1 1 * */$year';
  }

  /// Stops the cron job and cleans up resources.
  ///
  /// This method changes the cron status to [CronStatus.stopped] and closes the internal [Cron] instance.
  void close() {
    _cron.close();
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
