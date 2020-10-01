import 'package:delern_flutter/views/helpers/localization.dart';
import 'package:delern_flutter/views/helpers/styles.dart' as app_styles;
import 'package:flutter/material.dart';

typedef SearchCallback = void Function(String input);

class SearchBarWidget extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final SearchCallback search;
  final Widget leading;
  final List<Widget> actions;

  const SearchBarWidget({this.title, this.search, this.leading, this.actions});

  @override
  State<StatefulWidget> createState() => SearchBarWidgetState();

  // Flutter documentation for AppBar.preferredSize says:
  // "the sum of kToolbarHeight and the bottom widget's preferred height".
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchMode = false;

  void _searchTextChanged() {
    if (_isSearchMode) {
      widget.search(_searchController.text);
    } else {
      widget.search(null);
    }
  }

  @override
  void initState() {
    _searchController.addListener(_searchTextChanged);
    super.initState();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_searchTextChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget appBarTitle;
    Icon actionIcon;

    if (_isSearchMode) {
      actionIcon = const Icon(Icons.close);
      appBarTitle = TextField(
        autofocus: true,
        showCursor: true,
        cursorColor: Theme.of(context).cursorColor,
        controller: _searchController,
        style: app_styles.searchBarText,
        decoration: InputDecoration(
            border: InputBorder.none,
            hintText: context.l.searchHint,
            hintStyle: app_styles.searchBarText),
      );
    } else {
      appBarTitle = Text(
        widget.title,
        overflow: TextOverflow.ellipsis,
      );
      actionIcon = const Icon(Icons.search);
    }

    final actions = <Widget>[
      AspectRatio(
        aspectRatio: 1,
        child: IconButton(
          icon: actionIcon,
          tooltip: MaterialLocalizations.of(context).searchFieldLabel,
          onPressed: () {
            setState(() {
              if (_isSearchMode) {
                // TODO(ksheremet): would the user always want to clear it?
                _searchController.clear();
                _isSearchMode = false;
              } else {
                _isSearchMode = true;
              }
            });
          },
        ),
      )
    ];

    if (widget.actions != null && widget.actions.isNotEmpty) {
      actions.addAll(widget.actions);
    }

    return AppBar(
      centerTitle: true,
      title: appBarTitle,
      leading: widget.leading,
      actions: actions,
    );
  }
}
