class Record{
  final String type;
  final String thumb;
  final String uri;
  static const String domain = "https://www.discogs.com";

  const Record({required this.type, required this.thumb, required this.uri });

  factory Record.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {'type': String type, 'thumb': String thumb, 'uri': String uri} => Record(
        type: type,
        thumb: thumb,
        uri: uri,
      ),
      _ => throw const FormatException('Failed to load a record.'),
    };
  }
}