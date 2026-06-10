import 'package:flutter/material.dart';

import '../diary_controller.dart';
import '../diary_entry.dart';
import '../widgets/harutalk_ui.dart';
import '../widgets/tori_mascot.dart';
import 'summary_editor.dart';

class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key, required this.controller});

  final DiaryController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final entries = controller.entries;
        final latest = entries.isEmpty ? null : entries.first;
        return ListView(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
          children: [
            AppPageHeader(
              title: '한줄',
              subtitle: '토리와 함께 남긴 ${entries.length}개의 하루',
              trailing: const SmallPill(
                label: 'AI 한 줄',
                icon: Icons.auto_awesome_rounded,
              ),
            ),
            const SizedBox(height: 24),
            if (latest != null) ...[
              _LatestEntryCard(
                entry: latest,
                onTap: () => _openDetail(context, latest),
              ),
              const SizedBox(height: 28),
            ],
            Row(
              children: [
                Text('최근 기록', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                Text(
                  '${entries.length}개',
                  style: const TextStyle(
                    color: HarutalkColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (entries.isEmpty)
              const SoftCard(
                child: Row(
                  children: [
                    ToriMascot(expression: ToriExpression.sleeping, size: 88),
                    SizedBox(width: 14),
                    Expanded(child: Text('아직 기록이 없어요.\n토리와 오늘의 한 줄을 남겨보세요.')),
                  ],
                ),
              )
            else
              for (final entry in entries) ...[
                _DiaryListItem(
                  entry: entry,
                  onTap: () => _openDetail(context, entry),
                ),
                const SizedBox(height: 10),
              ],
          ],
        );
      },
    );
  }

  void _openDetail(BuildContext context, DiaryEntry entry) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            DiaryDetailScreen(controller: controller, entryId: entry.id),
      ),
    );
  }
}

class _LatestEntryCard extends StatelessWidget {
  const _LatestEntryCard({required this.entry, required this.onTap});

  final DiaryEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      color: HarutalkColors.cream,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ToriMascot(expression: ToriExpression.complete, size: 80),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    '가장 최근에 남긴 하루야.\n오늘도 잘 기록했어!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: HarutalkColors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            '최근 한 줄',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 7),
          Text(
            entry.summary,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontSize: 20, height: 1.45),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(entry.mood.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 7),
              Text(
                formatDiaryDate(entry.date, includeYear: false),
                style: const TextStyle(
                  color: HarutalkColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_rounded,
                color: HarutalkColors.primary,
                size: 19,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DiaryListItem extends StatelessWidget {
  const _DiaryListItem({required this.entry, required this.onTap});

  final DiaryEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: entry.mood.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(entry.mood.emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatDiaryDate(entry.date, includeYear: false),
                  style: const TextStyle(
                    color: HarutalkColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFFB8BEB9)),
        ],
      ),
    );
  }
}

class DiaryDetailScreen extends StatelessWidget {
  const DiaryDetailScreen({
    super.key,
    required this.controller,
    required this.entryId,
  });

  final DiaryController controller;
  final String entryId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final entry = controller.entryById(entryId);
        if (entry == null) {
          return const Scaffold(body: Center(child: Text('삭제된 기록입니다.')));
        }
        return Scaffold(
          appBar: AppBar(
            backgroundColor: HarutalkColors.background,
            surfaceTintColor: Colors.transparent,
            title: const Text('오늘의 기록'),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 10, 22, 32),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ToriMascot(
                        expression: ToriExpression.journal,
                        size: 98,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: HarutalkColors.cream,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '내가 정리한 한 줄이 마음에 들지 않으면 언제든 고쳐도 괜찮아!',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    formatDiaryDate(entry.date),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '오늘의 한 줄',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  SoftCard(
                    padding: const EdgeInsets.all(21),
                    child: Text(
                      entry.summary,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      SmallPill(
                        label: '${entry.mood.emoji} ${entry.mood.label}',
                      ),
                      for (final keyword in entry.keywords)
                        SmallPill(
                          label: keyword,
                          color: HarutalkColors.cream,
                          foreground: HarutalkColors.ink,
                        ),
                      SmallPill(
                        label: '${entry.satisfaction}점',
                        icon: Icons.star_rounded,
                        color: const Color(0xFFFFF0C9),
                        foreground: const Color(0xFF9A6B1E),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _edit(context, entry),
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('수정하기'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.check_rounded),
                          label: const Text('확인'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _delete(context, entry),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('기록 삭제'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFC75252),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _edit(BuildContext context, DiaryEntry entry) async {
    final summary = await showSummaryEditor(
      context,
      initialValue: entry.summary,
    );
    if (summary == null) return;
    final saved = await controller.updateSummary(entry.id, summary);
    if (!saved && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.storageError ?? '수정 내용을 저장하지 못했어요.')),
      );
    }
  }

  Future<void> _delete(BuildContext context, DiaryEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('기록을 삭제할까요?'),
        content: Text('${formatDiaryDate(entry.date)} 기록이 삭제됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final deleted = await controller.deleteEntry(entry.id);
    if (!context.mounted) return;
    if (deleted) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.storageError ?? '기록을 삭제하지 못했어요.')),
      );
    }
  }
}
