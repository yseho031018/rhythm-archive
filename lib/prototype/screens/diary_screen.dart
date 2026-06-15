import 'package:flutter/material.dart';

import '../diary_controller.dart';
import '../diary_entry.dart';
import '../widgets/harutalk_ui.dart';
import '../widgets/tori_mascot.dart';
import 'summary_editor.dart';

class DiaryScreen extends StatelessWidget {
  const DiaryScreen({
    super.key,
    required this.controller,
    required this.onRecord,
  });

  final DiaryController controller;
  final VoidCallback onRecord;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final entries = controller.entries;
        final latest = entries.isEmpty ? null : entries.first;
        final previousEntries = entries.skip(1).toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
          children: [
            AppPageHeader(
              title: '한줄',
              subtitle: entries.isEmpty
                  ? '첫 한 줄을 기다리고 있어요.'
                  : '토리와 함께 남긴 ${entries.length}개의 하루',
              trailing: const SmallPill(
                label: '토리 한 줄',
                icon: Icons.spa_rounded,
              ),
            ),
            const SizedBox(height: 24),
            if (entries.isEmpty)
              ToriEmptyStateCard(
                title: '아직 남긴 한 줄이 없어요',
                body: '오늘의 기분과 함께한 일을 고르면\n토리가 부담 없이 한 줄로 정리해줄게요.',
                actionLabel: '오늘 기록 시작하기',
                onAction: onRecord,
                expression: ToriExpression.journal,
              )
            else ...[
              _LatestEntryCard(
                entry: latest!,
                onTap: () => _openDetail(context, latest),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Text('이전 기록', style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  Text(
                    '${previousEntries.length}개',
                    style: TextStyle(
                      color: context.colors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (previousEntries.isEmpty)
                SoftCard(
                  color: context.colors.surfaceSoft,
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: context.colors.primary,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('첫 한 줄을 남겼어요.\n다음 기록부터 이곳에 차곡차곡 모여요.'),
                      ),
                    ],
                  ),
                )
              else
                for (final entry in previousEntries) ...[
                  _DiaryListItem(
                    entry: entry,
                    onTap: () => _openDetail(context, entry),
                  ),
                  const SizedBox(height: 10),
                ],
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
    final colors = context.colors;
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      color: colors.cream,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ToriMascot(expression: ToriExpression.complete, size: 104),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: colors.surface.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    '가장 최근에 남긴 하루야.\n오늘도 잘 기록했어!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.primaryDark,
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
                style: TextStyle(
                  color: colors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_rounded,
                color: colors.primary,
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
    final colors = context.colors;
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
              color: entry.mood.color.withValues(alpha: 0.16),
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
                  style: TextStyle(
                    color: colors.muted,
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
          Icon(Icons.chevron_right_rounded, color: colors.muted),
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
        final colors = context.colors;
        return Scaffold(
          backgroundColor: colors.surfaceSoft,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Scaffold(
                  key: const ValueKey('diary-detail-mobile-frame'),
                  appBar: AppBar(
                    backgroundColor: colors.background,
                    surfaceTintColor: Colors.transparent,
                    title: const Text('오늘의 기록'),
                  ),
                  body: entry == null
                      ? const Center(child: Text('삭제된 기록입니다.'))
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(22, 10, 22, 32),
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const ToriMascot(
                                  expression: ToriExpression.journal,
                                  size: 128,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: colors.cream,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '내가 정리한 한 줄이 마음에 들지 않으면 언제든 고쳐도 괜찮아!',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
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
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(height: 1.5),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                SmallPill(
                                  label:
                                      '${entry.mood.emoji} ${entry.mood.label}',
                                ),
                                for (final keyword in entry.keywords)
                                  SmallPill(
                                    label: keyword,
                                    color: colors.cream,
                                    foreground: colors.ink,
                                  ),
                                SmallPill(
                                  label: '${entry.satisfaction}점',
                                  icon: Icons.star_rounded,
                                  color: colors.accentSoft,
                                  foreground: colors.accent,
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
        icon: const HarutalkDialogIcon(
          icon: Icons.delete_outline_rounded,
          destructive: true,
        ),
        title: const Text('기록을 삭제할까요?'),
        content: Text(
          '${formatDiaryDate(entry.date)} 기록이 삭제됩니다.',
          textAlign: TextAlign.center,
        ),
        actions: [
          HarutalkDialogActions(
            cancelLabel: '취소',
            confirmLabel: '삭제',
            onCancel: () => Navigator.pop(context, false),
            onConfirm: () => Navigator.pop(context, true),
            destructive: true,
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
