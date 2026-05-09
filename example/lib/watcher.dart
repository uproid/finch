import 'dart:async';
import 'dart:io';
import 'dart:developer' as dev;
import 'package:vm_service/utils.dart';
import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';
import 'package:watcher/watcher.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:finch/console.dart';
import 'serve.dart' as servApp;
import 'package:finch/console.dart';

void main([List<String>? args]) async {
  Print.info('Starting Finch with hot reload enabled...');

  runZonedGuarded(() async {
    // Await if servApp.main is async
    servApp.main(args);

    // Retry getting VM service info — it may not be ready instantly
    Uri? observatoryUri;
    for (var i = 0; i < 10; i++) {
      final info = await dev.Service.getInfo();
      observatoryUri = info.serverUri;
      if (observatoryUri != null) break;
      Print.warning('VM service not ready, retrying... ($i)');
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (observatoryUri == null) {
      Print.error(
        'VM service unavailable. Run with:\n'
        '  dart run --enable-vm-service --disable-service-auth-codes',
      );
      return;
    }

    final wsUri =
        convertToWebSocketUrl(serviceProtocolUrl: observatoryUri).toString();
    Print.info('Connecting to VM service at $wsUri');

    final serviceClient = await vmServiceConnectUri(wsUri, log: StdoutLog());

    final vm = await serviceClient.getVM();
    final mainIsolate = vm.isolates!.first;

    await serviceClient.setIsolatePauseMode(
      mainIsolate.id!,
      exceptionPauseMode: 'None',
    );

    Print.info('Watching for file changes...');

    DirectoryWatcher(Directory.current.path)
        .events
        .throttle(const Duration(milliseconds: 1000))
        .listen((_) async {
      Print.warning('File change detected. Reloading sources...');
      try {
        final result = await serviceClient.reloadSources(mainIsolate.id!);
        if (result.success == true) {
          Print.info('Hot reload successful.');
        } else {
          Print.error('Hot reload failed: ${result.toString()}');
        }
      } catch (e) {
        Print.error('Reload error: $e');
      }
    });
  }, (error, stackTrace) {
    print('Caught an error: $error');
    print('Stack trace: $stackTrace');
  });
}

class StdoutLog extends Log {
  @override
  void warning(String message) => print('Watcher warning: $message');
  @override
  void severe(String message) => print('Watcher severe: $message');
}
