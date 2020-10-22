import 'package:delern_flutter/views/helpers/non_scrolling_markdown_widget.dart';
import 'package:delern_flutter/views/helpers/styles.dart' as app_styles;
import 'package:flutter/material.dart';

class CardSideWidget extends StatelessWidget {
  final String _markdownContent;

  CardSideWidget({
    @required String text,
    Iterable<String> imagesList,
  }) : _markdownContent = imagesList == null
            ? text
            : imagesList
                .fold<StringBuffer>(
                  StringBuffer(text),
                  (buffer, imageUrl) =>
                      buffer..write('\n\n![alt text]($imageUrl "$text image")'),
                )
                .toString();

  @override
  Widget build(BuildContext context) => NonScrollingMarkdownWidget(
        text: _markdownContent,
        textStyle: app_styles.specifyCardFontStyle(),
        listIndent: app_styles.specifyMarkdownListIndent(),
      );
}
