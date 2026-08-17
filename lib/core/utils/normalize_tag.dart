/// Strips a leading '#', trims and lowercases.
///
/// No accent folding here: tags are stored pre-folded at write time (see
/// `extractTags` in the feed datasource), so '#cafe' matches but '#café'
/// won't — accepted limitation of folded tags.
String normalizeTag(String raw) {
  final String q = raw.trim().toLowerCase();
  return q.startsWith('#') ? q.substring(1) : q;
}
