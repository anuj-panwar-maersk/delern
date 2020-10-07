import 'package:delern_flutter/models/base/keyed_list_item.dart';
import 'package:delern_flutter/views/helpers/localization.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

typedef ScrollToBeginningListWidgetBuilder = Widget Function(
  ScrollController controller,
);

class ScrollToBeginningListWidget extends StatefulWidget {
  const ScrollToBeginningListWidget({
    @required this.builder,
    @required this.minItemHeight,
    @required this.upButtonVisibleRow,
    Key key,
  }) : super(key: key);

  final ScrollToBeginningListWidgetBuilder builder;

  /// Minimum height of item.
  final double minItemHeight;

  /// From which row 'up' icon is visible.
  final int upButtonVisibleRow;

  @override
  ScrollToBeginningListWidgetState createState() =>
      ScrollToBeginningListWidgetState();
}

class ScrollToBeginningListWidgetState<T extends KeyedListItem>
    extends State<ScrollToBeginningListWidget> {
  final ScrollController _scrollController = ScrollController();
  var _isUpIconVisible = false;
  var _currentScrollRow = 0.0;

  @override
  Widget build(BuildContext context) => Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                child: NotificationListener<ScrollUpdateNotification>(
                    onNotification: (scrollNotification) {
                      // We don't have exact height of row, we only
                      // have min width/height. This calculation is
                      // approximate.
                      _currentScrollRow = scrollNotification.metrics.pixels /
                              widget.minItemHeight +
                          1;
                      if (_currentScrollRow > widget.upButtonVisibleRow &&
                          !_isUpIconVisible) {
                        // Call set state of parent.
                        setState(() {
                          _isUpIconVisible = true;
                        });
                      }
                      if (_currentScrollRow < widget.upButtonVisibleRow &&
                          _isUpIconVisible) {
                        setState(() {
                          _isUpIconVisible = false;
                        });
                      }
                      // Do not dispatch notification to further ancestors
                      return true;
                    },
                    child: widget.builder(_scrollController)),
              ),
            ],
          ),
          if (_currentScrollRow > widget.upButtonVisibleRow)
            _buildUpButton(context)
        ],
      );

  Padding _buildUpButton(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 20, bottom: 16),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: FloatingActionButton(
            // Because of 2 FAB button (add_card and up_button),
            // it tries to do hero animation in Preview screen.
            // The app doesn't know for what button to do.
            // It crashes. User hero for add card on default.
            heroTag: 'up_button',
            backgroundColor: Colors.blueGrey,
            tooltip: context.l.scrollToStartLabel,
            onPressed: () {
              _scrollController.animateTo(0,
                  duration: const Duration(seconds: 1), curve: Curves.easeIn);
            },
            child: const Icon(Icons.arrow_upward),
          ),
        ),
      );
}
