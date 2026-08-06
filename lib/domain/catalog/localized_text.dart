/// The one centralized fallback resolver for locale-keyed content (§7).
///
/// Falling back to English (then the id) rather than hiding a value is
/// mandatory: a fixed 3×3–5×5 board must never lose a cell. This is pure and
/// portable to a future Cloud Function.
String resolveLocalized(
  Map<String, String> field,
  String locale, {
  String fallbackId = '',
}) {
  if (field.isEmpty) return fallbackId;

  // exact match, e.g. "pt-BR"
  final exact = field[locale];
  if (exact != null && exact.isNotEmpty) return exact;

  // language only, e.g. "pt"
  final lang = locale.split(RegExp('[-_]')).first;
  final byLang = field[lang];
  if (byLang != null && byLang.isNotEmpty) return byLang;

  // app base, guaranteed present in the bundled catalog
  final en = field['en'];
  if (en != null && en.isNotEmpty) return en;

  // last-ditch: the id, else any value we have
  return fallbackId.isNotEmpty ? fallbackId : field.values.first;
}
