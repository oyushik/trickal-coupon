import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';

import '../../core/constants/disclaimer_text.dart';

/// 면책 조항 페이지
class DisclaimerPage extends StatelessWidget {
  const DisclaimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bodyTextStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
          height: 1.6,
        );
    final h2TextStyle = Theme.of(context).textTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        );
    final h3TextStyle = Theme.of(context).textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text('면책 조항'),
      ),
      body: MarkdownWidget(
        data: DisclaimerText.content,
        selectable: true,
        config: MarkdownConfig(
          configs: [
            PConfig(textStyle: bodyTextStyle),
            H2Config(style: h2TextStyle),
            H3Config(style: h3TextStyle),
          ],
        ),
      ),
    );
  }
}
