class PageInfo {
  const PageInfo({
    required this.count,
    required this.pages,
    this.nextPage,
    this.prevPage,
  });

  final int count;
  final int pages;
  final int? nextPage;
  final int? prevPage;

  bool get hasNext => nextPage != null;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PageInfo &&
            count == other.count &&
            pages == other.pages &&
            nextPage == other.nextPage &&
            prevPage == other.prevPage;
  }

  @override
  int get hashCode => Object.hash(count, pages, nextPage, prevPage);
}
