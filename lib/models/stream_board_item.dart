class StreamBoardItem {
  const StreamBoardItem({
    required this.id,
    required this.title,
    this.content,
  });

  final int id;
  final String title;
  final String? content;

  String get displayText =>
      (content != null && content!.isNotEmpty) ? content! : title;

  /// Backend stores `content` as HTML (`<p>…</p>` paragraphs). Convert to
  /// plain text so the shop card can render it with normal [Text] widgets:
  ///   - `</p><p>` and `<br>` become paragraph breaks
  ///   - remaining tags are stripped
  ///   - common entities (`&nbsp; &amp; &lt; &gt; &quot; &#39;`) are decoded
  String get plainContent {
    final raw = content;
    if (raw == null || raw.isEmpty) return '';
    var text = raw
        .replaceAll(RegExp(r'<\s*br\s*/?\s*>', caseSensitive: false), '\n')
        .replaceAll(
          RegExp(r'</\s*p\s*>\s*<\s*p[^>]*>', caseSensitive: false),
          '\n\n',
        )
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
    // Collapse runs of 3+ newlines into a single paragraph break.
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return text.trim();
  }

  factory StreamBoardItem.fromJson(Map<String, dynamic> json) =>
      StreamBoardItem(
        id: json['id'] as int? ?? 0,
        title: json['title'] as String? ?? '',
        content: json['content'] as String?,
      );
}
