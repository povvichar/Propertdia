// Shared formatting helpers (currency + dates) used across all feature
// modules. Consolidated from per-feature copies so output stays consistent.

/// `$1,234,567` — thousands-separated USD. Handles negatives (`-$50`).
/// Cambodian real estate is USD-denominated, so all money flows through here.
String usd(num v) {
  final neg = v < 0;
  final s = v.abs().round().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return '${neg ? '-' : ''}\$$b';
}

/// `Jun 8, 2026` — compact month-first date (valuation / title flows).
String shortDate(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[d.month - 1]} ${d.day}, ${d.year}';
}

/// `08 Jun 2026` — day-first date (wallet / investment ledger).
String fmtDate(DateTime d) {
  const m = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${d.day.toString().padLeft(2, '0')} ${m[d.month - 1]} ${d.year}';
}

/// `08 Jun 2026 · 3:05 PM` — day-first date with 12-hour time.
String fmtDateTime(DateTime d) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final mm = d.minute.toString().padLeft(2, '0');
  final ap = d.hour < 12 ? 'AM' : 'PM';
  return '${fmtDate(d)} · $h:$mm $ap';
}

/// Returns the date [days] business days (Mon–Fri) after [from]. Used to show
/// an expected completion date for valuation / title requests.
DateTime addBusinessDays(DateTime from, int days) {
  var d = from;
  var added = 0;
  while (added < days) {
    d = d.add(const Duration(days: 1));
    if (d.weekday != DateTime.saturday && d.weekday != DateTime.sunday) {
      added++;
    }
  }
  return d;
}
