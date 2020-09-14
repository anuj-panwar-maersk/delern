import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:delern_flutter/models/base/keyed_list_item.dart';
import 'package:delern_flutter/models/base/list_change_record.dart';
import 'package:delern_flutter/models/base/stream_with_value.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:quiver/strings.dart';

abstract class ListAccessor<T> implements StreamWithValue<BuiltList<T>> {
  void close();
}

class DataListAccessorItem<T extends KeyedListItem>
    implements StreamWithValue<T> {
  final String key;
  final DataListAccessor<T> _listAccessor;
  StreamController<T> _updates;

  @visibleForTesting
  DataListAccessorItem(this._listAccessor, this.key) {
    StreamSubscription<ListChangeRecord<T>> eventsSubscription;
    _updates = StreamController<T>.broadcast(
      onListen: () {
        eventsSubscription = _listAccessor.events.listen(
          (listChangedRecord) {
            final addedItem = listChangedRecord.added
                .firstWhere((item) => item.key == key, orElse: () => null);
            final itemWasRemoved =
                listChangedRecord.removed.any((item) => item.key == key);
            if (addedItem != null || itemWasRemoved) {
              _updates.add(addedItem);
            }
          },
          onDone: () => _updates.close(),
          // Forward errors on the listener. In addition, DataListAccessor
          // errors are always terminating the stream, so onDone will follow.
          // We have to annotate parameter types because onError handler is
          // defined as untyped Function and types can not be inferred.
          // ignore: avoid_types_on_closure_parameters
          onError: (dynamic e, StackTrace stackTrace) =>
              _updates.addError(e, stackTrace),
        );
      },
      onCancel: () => eventsSubscription.cancel(),
    );
  }

  /// Whether the underlying list is fully loaded and therefore the state of
  /// this item (exists / does not exist) is known.
  @override
  bool get loaded => _listAccessor.loaded;

  /// There's the following contract to [updates] of a list item:
  /// - when an item is gone from the list, this stream yields `null`, but the
  ///   stream itself is not closed. If the item re-appears, it will be yielded;
  /// - when the list itself is gone (e.g. we are watching a Card in a Deck that
  ///   has been removed), then nothing is yielded and the stream is closed.
  @override
  Stream<T> get updates => _updates.stream;

  /// If the underlying list is fully loaded, and there is currently an item
  /// with this [key] in the list, returns the value. Otherwise, returns `null`.
  @override
  T get value {
    if (_listAccessor.loaded) {
      final index = _listAccessor.value.indexOfKey(key);
      if (index >= 0) {
        return _listAccessor.value[index];
      }
    }
    return null;
  }
}

/// A proxy class for [DatabaseError], used to only report errors about reading
/// from a database (streams like [Query.onChildAdded], [Query.onValue] etc).
/// The differences are:
/// - it includes [path], which should be set to [Query.path] of the [Query]
///   which subscription has failed;
/// - it overrides [toString] to provide additional information like [path];
/// - it implements [Exception] interface as a good citizen.
///
/// It `implements` [DatabaseError] rather than extending it because it does not
/// have a public constructor.
@immutable
class DatabaseReadException implements Exception, DatabaseError {
  final String path;
  final DatabaseError _underlyingError;

  const DatabaseReadException({
    @required DatabaseError underlyingError,
    @required this.path,
  }) : _underlyingError = underlyingError;

  @override
  int get code => _underlyingError.code;

  @override
  String get message => _underlyingError.message;

  @override
  String get details => isEmpty(_underlyingError.details)
      ? 'path:$path'
      : '${_underlyingError.details} (path:$path)';

  @override
  String toString() => 'DatabaseReadException($code, $message, $details)';
}

abstract class DataListAccessor<T extends KeyedListItem>
    implements ListAccessor<T> {
  final List<T> _currentValue = [];
  bool _loaded = false;
  final _value = StreamController<BuiltList<T>>.broadcast();
  final _events = StreamController<ListChangeRecord<T>>.broadcast();

  /// Current value of the list. The following edge cases exist:
  /// - the value is `null` if initialization is not yet complete ([loaded] is
  ///   false);
  /// - if the `ListAccessor` has been [close]d, the value is an empty list.
  @override
  BuiltList<T> get value => _loaded ? BuiltList.from(_currentValue) : null;

  /// `true` once the initial value has been loaded from the database. Never
  /// changes to `false` afterwards.
  @override
  bool get loaded => _loaded;

  /// Updates to the current [value]. This stream is closed when this object is
  /// [close]d.
  @override
  Stream<BuiltList<T>> get updates => _value.stream;

  /// Updates to the current [value] delivered in the form of
  /// [ListChangeRecord]. This stream is closed when this [DataListAccessor] is
  /// [close]d.
  Stream<ListChangeRecord<T>> get events => _events.stream;

  StreamSubscription<Event> _onChildAdded, _onChildChanged, _onChildRemoved;
  String _path;

  DataListAccessor(DatabaseReference reference) {
    _path = reference.path;
    _onChildAdded = reference.onChildAdded.listen(
      _childAddedOrChanged,
      onError: _onListenError,
    );
    _onChildChanged = reference.onChildChanged.listen(
      _childAddedOrChanged,
      onError: _onListenError,
    );
    _onChildRemoved = reference.onChildRemoved.listen(
      (data) {
        final index = _currentValue.indexOfKey(data.snapshot.key);
        final deletedItem = _currentValue[index];
        _currentValue.removeAt(index);
        disposeItem(deletedItem);
        if (_loaded) {
          if (_value.hasListener) {
            _value.add(BuiltList.from(_currentValue));
          }
          if (_events.hasListener) {
            _events.add(ListChangeRecord<T>.remove(
                _currentValue, index, [deletedItem]));
          }
        }
      },
      onError: _onListenError,
    );
    // onChildAdded listener will be called first, but we don't send updates
    // until we get the full list value.
    reference.once().then((val) {
      _loaded = true;
      // TODO(dotdoom): replace/update current value with val.

      if (_value.hasListener) {
        _value.add(BuiltList.from(_currentValue));
      }
      if (_events.hasListener) {
        _events.add(
            ListChangeRecord<T>.add(_currentValue, 0, _currentValue.length));
      }
    }).catchError(_onListenError);
  }

  void _onListenError(dynamic error, StackTrace stackTrace) {
    dynamic wrappedError = error;
    if (error is DatabaseError) {
      // Can't use throw because that would loose stackTrace that we have.
      wrappedError = DatabaseReadException(
        underlyingError: error,
        path: _path,
      );
    }

    if (!_value.isClosed && _value.hasListener) {
      _value.addError(wrappedError, stackTrace);
    }
    if (!_events.isClosed && _events.hasListener) {
      _events.addError(wrappedError, stackTrace);
    }

    close();
  }

  void _childAddedOrChanged(Event data) {
    final existingIndex = _currentValue.indexOfKey(data.snapshot.key);
    if (existingIndex >= 0) {
      final replacedItem = _currentValue[existingIndex];
      _currentValue[existingIndex] =
          updateItem(replacedItem, data.snapshot.value);
      if (_loaded && _events.hasListener) {
        _events.add(ListChangeRecord<T>.replace(
            _currentValue, existingIndex, [replacedItem]));
      }
    } else {
      _currentValue.add(parseItem(data.snapshot.key, data.snapshot.value));
      if (_loaded && _events.hasListener) {
        _events.add(ListChangeRecord<T>.add(
            _currentValue, _currentValue.length - 1, 1));
      }
    }
    if (_loaded && _value.hasListener) {
      _value.add(BuiltList.from(_currentValue));
    }
  }

  StreamWithValue<T> getItem(String key) => DataListAccessorItem(this, key);

  @protected
  @visibleForOverriding
  T parseItem(String key, dynamic value);

  @protected
  @visibleForOverriding
  T updateItem(T previous, dynamic value) => parseItem(previous.key, value);

  @protected
  @visibleForOverriding
  void disposeItem(T item) {}

  /// Close this object and release associated resources. Typically used only
  /// when the parent object is being removed from the database, or current user
  /// looses access to this object.
  @override
  void close() {
    _onChildAdded?.cancel();
    _onChildChanged?.cancel();
    _onChildRemoved?.cancel();
    _currentValue
      ..forEach(disposeItem)
      ..clear();
    _events.close();
    _value.close();
  }
}

typedef Filter<T> = bool Function(T item);

/// We use Decorator pattern because _base is an abstract class.
class FilteredListAccessor<T extends KeyedListItem> implements ListAccessor<T> {
  final ListAccessor<T> _base;
  Filter<T> _filter;
  BuiltList<T> _currentValue;
  StreamSubscription<BuiltList<T>> _baseValueSubscription;
  final _value = StreamController<BuiltList<T>>.broadcast();

  FilteredListAccessor(this._base) : _currentValue = _base.value {
    _baseValueSubscription = _base.updates.listen((_) => _updateCurrentValue());
  }

  Filter<T> get filter => _filter;
  set filter(Filter<T> value) {
    _filter = value;
    _updateCurrentValue();
  }

  @override
  Stream<BuiltList<T>> get updates => _value.stream;
  @override
  BuiltList<T> get value => _currentValue;
  @override
  bool get loaded => _base.loaded;

  @override
  void close() {
    _value.close();
    _baseValueSubscription.cancel();
  }

  void _updateCurrentValue() {
    // Base can be null only before the first even has arrived. Ignore such
    // updates.
    if (_base.value != null) {
      if (_filter == null) {
        _currentValue = _base.value;
      } else {
        _currentValue = BuiltList<T>.of(_base.value.where(_filter));
      }
      _value.add(_currentValue);
    }
  }
}
