import 'package:cached_network_image/cached_network_image.dart';
import 'package:delern_flutter/remote/error_reporting.dart' as error_reporting;
import 'package:delern_flutter/views/helpers/localization.dart';
import 'package:delern_flutter/views/helpers/progress_indicator_widget.dart';
import 'package:delern_flutter/views/helpers/styles.dart' as app_styles;
import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

Widget buildDisplayImageWidget(
  String url, {
  String title,
  String alt,
}) {
  final image = CachedNetworkImage(
    imageUrl: url,
    placeholder: (context, url) =>
        const ImageProgressIndicatorPlaceholderWidget(),
    errorWidget: (context, url, dynamic error) {
      error_reporting.report(
        error,
        description: 'Image loading failed: $url',
      );
      return Column(
        children: <Widget>[
          Icon(
            Icons.error,
            color: app_styles.kIconColor,
          ),
          Text(
            isBlank(alt) ? context.l.imageLoadingErrorUserMessage : alt,
            softWrap: true,
            textAlign: TextAlign.center,
            style: app_styles.secondaryText,
          ),
        ],
      );
    },
  );
  if (isBlank(title)) {
    return image;
  }
  return Tooltip(
    message: title,
    child: image,
  );
}
