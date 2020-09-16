import 'dart:async';

import 'package:delern_flutter/models/base/stream_with_value.dart';
import 'package:delern_flutter/views/helpers/progress_indicator_widget.dart';
import 'package:delern_flutter/views/helpers/user_messages.dart';
import 'package:flutter/material.dart';

/// Build a [StreamBuilder] widget with values supplied from [StreamWithValue]
/// object. DEPRECATED: use [StreamBuilderWithValue] widget instead.
Widget buildStreamBuilderWithValue<T>({
  @required StreamWithValue<T> streamWithValue,
  @required AsyncWidgetBuilder<T> builder,
}) =>
    StreamBuilderWithValue<T>(
      streamWithValue: streamWithValue,
      builder: builder,
    );

@immutable
class StreamBuilderWithValue<T> extends StatefulWidget {
  final StreamWithValue<T> streamWithValue;
  final AsyncWidgetBuilder<T> builder;

  const StreamBuilderWithValue({
    @required this.streamWithValue,
    @required this.builder,
    Key key,
  }) : super(key: key);

  @override
  _StreamBuilderWithValueState<T> createState() =>
      _StreamBuilderWithValueState<T>();
}

class _StreamBuilderWithValueState<T> extends State<StreamBuilderWithValue<T>> {
  @override
  Widget build(BuildContext context) => StreamBuilder<T>(
        // By contract, we have to rebuild from scratch if the stream changes.
        key: ValueKey(widget.streamWithValue.updates),
        initialData: widget.streamWithValue.value,
        stream: widget.streamWithValue.updates,
        builder: widget.builder,
      );
}

typedef DataTrigger<T> = void Function(T newValue);
typedef DataBuilder<T> = Widget Function(BuildContext context, T value);

class DataStreamWithValueBuilder<T> extends StatefulWidget {
  /// Source [StreamWithValue].
  final StreamWithValue<T> streamWithValue;

  /// Builds a child widget. Never gets `null` as a value.
  final DataBuilder<T> builder;

  /// Called for every change to the data. May be called with `null`.
  final DataTrigger<T> onData;

  DataStreamWithValueBuilder({
    @required this.streamWithValue,
    @required this.builder,
    this.onData,
  }) : super(key: ValueKey(streamWithValue.updates));

  @override
  _DataStreamWithValueBuilderState<T> createState() =>
      _DataStreamWithValueBuilderState<T>();
}

class _DataStreamWithValueBuilderState<T>
    extends State<DataStreamWithValueBuilder<T>> {
  StreamSubscription<T> _streamSubscription;
  T _currentValue;

  @override
  void initState() {
    super.initState();

    if (widget.streamWithValue.loaded) {
      _currentValue = widget.streamWithValue.value;
      if (widget.onData != null) {
        scheduleMicrotask(() => widget.onData(_currentValue));
      }
    }

    _streamSubscription = widget.streamWithValue.updates.listen((event) {
      if (mounted) {
        if (widget.onData != null) {
          widget.onData(event);
        }
        setState(() {
          _currentValue = event;
        });
      }
    }, onDone: () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }, onError: (
      dynamic e,
      // https://github.com/dart-lang/linter/issues/1099
      // ignore: avoid_types_on_closure_parameters
      StackTrace stackTrace,
    ) {
      UserMessages.showAndReportError(
        () => Scaffold.of(context),
        e,
        stackTrace: stackTrace,
      );
    });
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _currentValue == null
      ? const ProgressIndicatorWidget()
      : widget.builder(context, _currentValue);
}
