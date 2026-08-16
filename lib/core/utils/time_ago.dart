// ponytail: hand-rolled timeago, swap for timeago pkg if i18n of durations matters
// TODO(l10n): plural units
String timeAgo(DateTime date) {
  final Duration diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'now';
  if (diff.inHours < 1) return '${diff.inMinutes}m';
  if (diff.inDays < 1) return '${diff.inHours}h';
  return '${diff.inDays}d';
}
