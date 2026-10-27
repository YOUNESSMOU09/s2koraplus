import 'package:flutter/material.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_spacing.dart';

/// The journal's markdown-LITE renderer: exactly the three marks the editor's
/// hint promises, and nothing else.
///
/// A full markdown package would bring tables, images, HTML and link handling
/// into a screen that stores plain text on a user's own device — a large
/// dependency and a much larger surface for a diary. Three marks, parsed here,
/// keep the promise honest:
///
///   `# heading`   `## subheading`   `- list item`   `**bold**`
///
/// Anything else is shown exactly as typed, which is the correct behaviour for
/// prose that was never meant to be markup.
class JournalMarkdown extends StatelessWidget {
  const JournalMarkdown({required this.source, super.key});

  final String source;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final List<Widget> blocks = <Widget>[];

    for (final String raw in source.split('\n')) {
      final String line = raw.trimRight();

      if (line.trim().isEmpty) {
        blocks.add(const SizedBox(height: AppSpacing.sm));
        continue;
      }
      if (line.startsWith('## ')) {
        blocks.add(Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xxs),
          child: _rich(context, line.substring(3),
              context.type.sectionHeader.copyWith(color: colors.textPrimary)),
        ));
        continue;
      }
      if (line.startsWith('# ')) {
        blocks.add(Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xxs),
          child: _rich(context, line.substring(2),
              context.type.titleMedium.copyWith(color: colors.textPrimary)),
        ));
        continue;
      }
      if (line.trimLeft().startsWith('- ')) {
        blocks.add(Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
                child: Text('•',
                    style: context.type.bodyLarge.copyWith(color: colors.accent)),
              ),
              Expanded(
                child: _rich(context, line.trimLeft().substring(2),
                    context.type.bodyLarge.copyWith(color: colors.textPrimary, height: 1.5)),
              ),
            ],
          ),
        ));
        continue;
      }
      blocks.add(Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
        child: _rich(context, line,
            context.type.bodyLarge.copyWith(color: colors.textPrimary, height: 1.55)),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks,
    );
  }

  /// `**bold**` inside one line. An unclosed `**` is left as typed rather than
  /// swallowing the rest of the paragraph.
  Widget _rich(BuildContext context, String text, TextStyle style) {
    final List<TextSpan> spans = <TextSpan>[];
    int index = 0;
    while (index < text.length) {
      final int open = text.indexOf('**', index);
      if (open < 0) {
        spans.add(TextSpan(text: text.substring(index)));
        break;
      }
      final int close = text.indexOf('**', open + 2);
      if (close < 0) {
        spans.add(TextSpan(text: text.substring(index)));
        break;
      }
      if (open > index) spans.add(TextSpan(text: text.substring(index, open)));
      spans.add(TextSpan(
        text: text.substring(open + 2, close),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ));
      index = close + 2;
    }
    return Text.rich(TextSpan(style: style, children: spans));
  }
}
