import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../controllers/ai_controller.dart';
import '../../../core/theme.dart';

class AiExplanationCard extends ConsumerStatefulWidget {
  final String scholarshipId;

  const AiExplanationCard({super.key, required this.scholarshipId});

  @override
  ConsumerState<AiExplanationCard> createState() => _AiExplanationCardState();
}

class _AiExplanationCardState extends ConsumerState<AiExplanationCard> {
  bool _showExplanation = false;

  @override
  Widget build(BuildContext context) {
    if (!_showExplanation) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _showExplanation = true;
            });
          },
          icon: const Icon(Icons.auto_awesome),
          label: const Text('Jelaskan dengan AI'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple.shade50,
            foregroundColor: Colors.purple.shade700,
            elevation: 0,
            side: BorderSide(color: Colors.purple.shade200),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      );
    }

    final explanationAsync = ref.watch(
      aiExplanationProvider(widget.scholarshipId),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.purple.shade700, size: 20),
              const SizedBox(width: Spacing.sm),
              Text(
                'Analisis AI',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade900,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  setState(() {
                    _showExplanation = false;
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: Colors.purple.shade700,
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          explanationAsync.when(
            data: (explanation) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  explanation.summary,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.purple.shade900,
                    height: 1.5,
                  ),
                ),
                if (explanation.strengths.isNotEmpty) ...[
                  const SizedBox(height: Spacing.md),
                  Text(
                    'Kekuatan Profil:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  ...explanation.strengths.map(
                    (s) => Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.add, color: Colors.green.shade700, size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            s,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (explanation.weaknesses.isNotEmpty) ...[
                  const SizedBox(height: Spacing.md),
                  Text(
                    'Kekurangan / Perlu Ditingkatkan:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade800,
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  ...explanation.weaknesses.map(
                    (s) => Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.remove,
                          color: Colors.red.shade700,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            s,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (explanation.unknowns.isNotEmpty) ...[
                  const SizedBox(height: Spacing.md),
                  Text(
                    'Informasi Kurang:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  ...explanation.unknowns.map(
                    (s) => Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.help_outline,
                          color: Colors.orange.shade700,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            s,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(Spacing.md),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) => Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Text(
                    error.toString().replaceAll('Exception: ', ''),
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
