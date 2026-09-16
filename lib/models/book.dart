class Book {
  final String title;
  final String path;
  final bool isAsset;

  Book({
    required this.title,
    required this.path,
    this.isAsset = true,
  });
}

