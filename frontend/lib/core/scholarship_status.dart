import 'package:intl/intl.dart';

import '../models/scholarship.dart';

/// Registration status as derived by the backend from the deadline and the
/// current time (`registration_status` in the scholarship response).
///
/// The client never infers "open" on its own: anything other than an explicit
/// `OPEN` / `CLOSED` from the server is treated as [unknown], which keeps the UI
/// honest when a deadline is not stated by the official source.
enum RegistrationStatus { open, closed, unknown }

RegistrationStatus registrationStatusOf(Scholarship scholarship) {
  switch (scholarship.registrationStatus.toUpperCase()) {
    case 'OPEN':
      return RegistrationStatus.open;
    case 'CLOSED':
      return RegistrationStatus.closed;
    default:
      return RegistrationStatus.unknown;
  }
}

/// A live check older than this is shown with a staleness warning.
const Duration staleVerificationThreshold = Duration(days: 14);

/// Describes how fresh the information about a scholarship is.
class VerificationInfo {
  const VerificationInfo({
    required this.label,
    this.staleWarning,
    this.isLiveChecked = false,
  });

  /// Main text, e.g. `Halaman resmi dicek 22 Oct 2026; syarat dan manfaat
  /// dikurasi manual`.
  final String label;

  /// Non-null when the last live check is older than
  /// [staleVerificationThreshold].
  final String? staleWarning;

  /// True only when the record was confirmed against the live official page
  /// (`CRAWLER_LIVE` with a `last_verified_live_at` timestamp).
  final bool isLiveChecked;

  bool get isStale => staleWarning != null;
}

/// Timestamps from the API are naive UTC (no `Z`), which `DateTime.parse`
/// would interpret as local time. Re-tag them as UTC before comparing or
/// converting to the user's timezone.
DateTime asUtc(DateTime value) {
  if (value.isUtc) return value;
  return DateTime.utc(
    value.year,
    value.month,
    value.day,
    value.hour,
    value.minute,
    value.second,
    value.millisecond,
    value.microsecond,
  );
}

VerificationInfo verificationInfoOf(Scholarship scholarship, {DateTime? now}) {
  final verifiedAt = scholarship.lastVerifiedLiveAt;

  if (scholarship.dataOrigin == 'CRAWLER_LIVE' && verifiedAt != null) {
    final verifiedUtc = asUtc(verifiedAt);
    final reference = (now ?? DateTime.now()).toUtc();
    final date = DateFormat('dd MMM yyyy').format(verifiedUtc.toLocal());
    final isStale =
        reference.difference(verifiedUtc) > staleVerificationThreshold;
    return VerificationInfo(
      label: 'Halaman resmi dicek $date; syarat dan manfaat dikurasi manual',
      isLiveChecked: true,
      staleWarning: isStale
          ? 'Data mungkin sudah usang: pengecekan terakhir lebih dari '
                '${staleVerificationThreshold.inDays} hari lalu'
          : null,
    );
  }

  return VerificationInfo(
    label: switch (scholarship.dataOrigin) {
      'CRAWLER_LIVE' => 'Status verifikasi belum tersedia',
      'CRAWLER_BASELINE' => 'Baseline resmi, perlu verifikasi terbaru',
      'SEED' => 'Data seed, perlu verifikasi terbaru',
      _ => 'Status verifikasi belum tersedia',
    },
  );
}
