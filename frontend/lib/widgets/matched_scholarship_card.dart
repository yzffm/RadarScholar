import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import '../models/scholarship.dart';
import '../models/match_result.dart';

class MatchedScholarshipCard extends StatelessWidget {
  const MatchedScholarshipCard({
    super.key,
    required this.matchedScholarship,
  });

  final MatchedScholarshipResponse matchedScholarship;

  @override
  Widget build(BuildContext context) {
    final scholarship = matchedScholarship.scholarship;
    final match = matchedScholarship.match;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: Spacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: _getRelevanceColor(match.relevance).withOpacity(0.5), width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () {
          // Navigates to detail page. We can pass the scholarship ID
          // The detail page will re-fetch the match details or we can use Riverpod
          context.push('/scholarships/${scholarship.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scholarship.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade900,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          scholarship.source?.providerName ?? 'Penyedia Belum Tersedia',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.brandPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                  _buildRelevanceBadge(match.relevance),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                match.explanation,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: Spacing.md),
              Row(
                children: [
                  Icon(Icons.check_circle_outline, size: 14, color: Colors.green.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${match.matchedCount} Memenuhi',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(width: 12),
                  if (match.notMatchedCount > 0) ...[
                    Icon(Icons.cancel_outlined, size: 14, color: Colors.red.shade600),
                    const SizedBox(width: 4),
                    Text(
                      '${match.notMatchedCount} Tidak',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    'Lihat Detail',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppTheme.brandPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 14, color: AppTheme.brandPrimary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRelevanceBadge(RelevanceTier relevance) {
    Color bgColor;
    Color textColor;
    String text;

    switch (relevance) {
      case RelevanceTier.sangatRelevan:
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        text = 'Sangat Relevan';
        break;
      case RelevanceTier.relevan:
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        text = 'Relevan';
        break;
      case RelevanceTier.mungkinRelevan:
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        text = 'Mungkin Relevan';
        break;
      case RelevanceTier.perluDicek:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
        text = 'Perlu Dicek';
        break;
      case RelevanceTier.belumCukupInformasi:
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
        text = 'Info Kurang';
        break;
      case RelevanceTier.tidakMemenuhi:
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        text = 'Tidak Memenuhi';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getRelevanceColor(RelevanceTier relevance) {
    switch (relevance) {
      case RelevanceTier.sangatRelevan:
        return Colors.green;
      case RelevanceTier.relevan:
        return Colors.blue;
      case RelevanceTier.mungkinRelevan:
        return Colors.orange;
      case RelevanceTier.perluDicek:
        return Colors.grey;
      case RelevanceTier.belumCukupInformasi:
        return Colors.grey.shade400;
      case RelevanceTier.tidakMemenuhi:
        return Colors.red;
    }
  }
}
