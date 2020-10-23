import 'dart:async';
import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:delern_flutter/views/helpers/card_color.dart';
import 'package:delern_flutter/views/helpers/card_side_widget.dart';
import 'package:delern_flutter/views/helpers/localization.dart';
import 'package:delern_flutter/views/helpers/styles.dart' as app_styles;
import 'package:delern_flutter/views/helpers/tags_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const _kFlipCardDuration = Duration(milliseconds: 300);
const double _kCardBorderPadding = 24;

class FlipCardWidget extends StatefulWidget {
  final String front;
  final BuiltList<String> frontImages;
  final String back;
  final BuiltList<String> backImages;
  final BuiltSet<String> tags;

  final CardColor colors;
  final ValueNotifier<bool> hasBeenFlipped;

  /// The [key] is required and must be unique to the card. E.g.:
  ///
  /// ```dart
  /// FlipCardWidget(
  ///   key: ValueKey(card.key),
  ///   ...
  /// )
  /// ```
  ///
  /// In IntervalLearning, there's a state of the card (e.g. whether it has been
  /// flipped at least once) that needs to be preserved.
  /// In ViewLearning PageView, key is necessary to correctly track a list of
  /// widgets of the same class, even when they change order.
  const FlipCardWidget({
    @required this.front,
    @required this.frontImages,
    @required this.back,
    @required this.colors,
    @required this.backImages,
    @required this.tags,
    @required Key key,
    this.hasBeenFlipped,
  })  : assert(key != null),
        super(key: key);

  @override
  _FlipCardWidgetState createState() => _FlipCardWidgetState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('front', front))
      ..add(StringProperty('back', back))
      ..add(DiagnosticsProperty<CardColor>('colors', colors));
  }
}

class _FlipCardWidgetState extends State<FlipCardWidget>
    with SingleTickerProviderStateMixin {
  Animation<double> _flipAnimation;
  Animation<double> _sizeAnimation;
  AnimationController _controller;

  /// Specifies whether we should render front (or back) side of the card in
  /// the next call to [build] method.
  bool _isFront = true;

  @override
  void initState() {
    super.initState();

    // initState() is called during build, so we can't change value that other
    // widgets (e.g. ValueListenableBuilder) might depend on.
    scheduleMicrotask(() => widget.hasBeenFlipped?.value = false);

    _controller =
        AnimationController(vsync: this, duration: _kFlipCardDuration);
    _sizeAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 1, end: 0.7), weight: 0.5),
      TweenSequenceItem(tween: Tween<double>(begin: 0.7, end: 1), weight: 0.5)
    ]).animate(_controller);

    _flipAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -pi / 2),
        weight: 0.5,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: pi / 2, end: 0),
        weight: 0.5,
      )
    ]).animate(_controller)
      ..addListener(() {
        final shouldRenderFront = _controller.value <= 0.5;
        if (_isFront != shouldRenderFront) {
          setState(() {
            _isFront = shouldRenderFront;
          });
          if (widget.hasBeenFlipped != null && !_isFront) {
            widget.hasBeenFlipped.value = true;
          }
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startAnimation() {
    if (!mounted) {
      return;
    }
    if (_controller.isCompleted) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          TagsWidget(
            tags: widget.tags,
            singleLine: true,
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: _flipAnimation,
              builder: (context, child) => Transform.scale(
                scale: _sizeAnimation.value,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(_flipAnimation.value),
                  child: child,
                ),
              ),
              child: GestureDetector(
                onTap: () {
                  // If card is not turning now, turn card
                  if (!_controller.isAnimating) {
                    _startAnimation();
                  }
                },
                child: Stack(
                  children: <Widget>[
                    Card(
                      color: _isFront
                          ? widget.colors.frontSideBackground
                          : widget.colors.backSideBackground,
                      elevation: app_styles.kCardElevation,
                      child: Padding(
                        padding: const EdgeInsets.all(_kCardBorderPadding),
                        child: LayoutBuilder(
                          builder: (context, viewportConstraints) =>
                              SingleChildScrollView(
                            // Keep scroll position separate for front and back.
                            key: ValueKey(_isFront),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: viewportConstraints.maxHeight,
                              ),
                              child: _isFront
                                  ? CardSideWidget(
                                      text: widget.front,
                                      imagesList: widget.frontImages,
                                    )
                                  : CardSideWidget(
                                      text: widget.back,
                                      imagesList: widget.backImages,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 1, right: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Icon(
                              Icons.autorenew,
                              color: app_styles.kSecondaryTextDeckItemColor,
                            ),
                            Text(
                              context.l.flip,
                              style: app_styles.secondaryText.copyWith(
                                  color:
                                      app_styles.kSecondaryTextDeckItemColor),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      );
}
