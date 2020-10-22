import 'package:delern_flutter/views/helpers/device_info.dart';
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
        textStyle: isPhone()
            ? app_styles.primaryText
            : app_styles.primaryText.copyWith(
                fontSize: MediaQuery.of(context).size.longestSide * 0.035),
        // In numbered list we need to add list indent to size numbers
        // properly
        // https://github.com/flutter/flutter_markdown/issues/255
        listIndent:
            isPhone() ? null : MediaQuery.of(context).size.longestSide * 0.04,
      );
}
