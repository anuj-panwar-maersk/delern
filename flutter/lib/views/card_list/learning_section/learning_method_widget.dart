import 'package:auto_size_text/auto_size_text.dart';
import 'package:delern_flutter/views/helpers/styles.dart' as app_styles;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef LearningMethodTapCallback = void Function();

const double _kPadding = 8;

class LearningMethodWidget extends StatelessWidget {
  final String name;
  final String tooltip;
  final Widget image;
  final LearningMethodTapCallback onTap;

  const LearningMethodWidget({
    @required this.name,
    @required this.tooltip,
    @required this.image,
    @required this.onTap,
  })  : assert(name != null),
        assert(tooltip != null),
        assert(image != null),
        assert(onTap != null);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const _LerningBackgroundWidget(),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Card(
                margin: const EdgeInsets.all(0),
                child: Padding(
                  padding: const EdgeInsets.all(_kPadding),
                  child: Column(
                    children: <Widget>[
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 2 * _kPadding),
                        child: image,
                      )),
                      const SizedBox(height: _kPadding),
                      AutoSizeText(
                        name,
                        style: app_styles.secondaryText.copyWith(
                            fontWeight: FontWeight.w500, fontSize: 18),
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      );
}

@immutable
class _LerningBackgroundWidget extends StatelessWidget {
  const _LerningBackgroundWidget();

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
              children: const <Widget>[
                Expanded(
                  child: Card(
                    margin: EdgeInsets.all(0),
                    color: Colors.blue,
                    child: SizedBox(
                      width: 10,
                      height: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}
