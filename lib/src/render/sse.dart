class SSE {
  String id;
  String event;
  String data;
  int retry;

  SSE({
    required this.data,
    this.id = '',
    this.event = '',
    this.retry = -1,
  });

  @override
  String toString() {
    var buffer = StringBuffer();
    if (id.isNotEmpty) {
      buffer.writeln('id: $id');
    } else {
      buffer.writeln('id: ${DateTime.now().millisecondsSinceEpoch}');
    }
    if (event.isNotEmpty) {
      buffer.writeln('event: $event');
    }
    buffer.writeln('data: $data');
    buffer.writeln();
    if (retry >= 0) {
      buffer.writeln('retry: $retry');
    }
    return buffer.toString();
  }
}
