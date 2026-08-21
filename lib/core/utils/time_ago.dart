// ponytail: hand-rolled timeago, swap for timeago pkg if more locales or
// long-form ("2 days ago") units ever matter. fr abbreviations are
// invariable, so short forms carry no plural variants.
String timeAgo(DateTime date, {String locale = 'en'}) {
  final Duration diff = DateTime.now().difference(date);
  final bool fr = locale.startsWith('fr');
  if (diff.inMinutes < 1) return fr ? "à l'instant" : 'now';
  if (diff.inHours < 1) {
    return fr ? '${diff.inMinutes} min' : '${diff.inMinutes}m';
  }
  if (diff.inDays < 1) return fr ? '${diff.inHours} h' : '${diff.inHours}h';
  return fr ? '${diff.inDays} j' : '${diff.inDays}d';
}
