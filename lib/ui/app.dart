import 'dart:async';
import 'package:flutter_qiita_client/models/qiita_item.dart';
import 'package:flutter_qiita_client/repository/repository_factory.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qiita Sample',
      theme: ThemeData(primaryColor: Colors.green),
      home: QiitaItemsPage(),
    );
  }

}

class QiitaItemsPage extends StatefulWidget {
  QiitaItemsPage({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => QiitaItemsState();
}

class QiitaItemsState extends State<QiitaItemsPage> {

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final List<QiitaItem> _qiitaItems = [];
  final Set<QiitaItem> _savedQiitaItems = Set<QiitaItem>();
  final TextStyle _biggerFontStyle = TextStyle(fontSize: 18.0);

  int _nextPage = 1;
  bool _isLastPage = false;


  @override
  void initState() {
    super.initState();
    _getInitialQiitaItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        title: Text('Qiita Sample'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.list), onPressed: _navigateToSavedPage)
        ],
      ),
      body: _buildBody(),
    );
  }

  void _navigateToSavedPage() {
    Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) {
              final tiles = _savedQiitaItems.map(
                    (qiitaItem) {
                  return ListTile(
                    title: Text(
                      qiitaItem.title,
                      style: _biggerFontStyle,
                    ),
                  );
                },
              );
              final divided = ListTile
                  .divideTiles(
                context: context,
                tiles: tiles,
              )
                  .toList();
              return Scaffold(
                appBar: AppBar(
                  title: Text('Saved Items'),
                ),
                body: ListView(children: divided),
              );
            }
        )
    );
  }

  Widget _buildBody() {
    if (_qiitaItems.isEmpty) {
      return Center(
        child: Container(
          margin: EdgeInsets.only(top: 8.0),
          width: 32.0,
          height: 32.0,
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _getInitialQiitaItems,
        child: _buildQiitaItemsListView(),
      );
    }
  }

  Widget _buildQiitaItemsListView() {
    return ListView.builder(itemBuilder: (BuildContext context, int index) {
      if (index.isOdd) return Divider();

      final i = index ~/ 2;
      if (i < _qiitaItems.length) {
        return _buildQiitaItemRow(_qiitaItems[i]);
      } else if (i == _qiitaItems.length) {
        if (_isLastPage) {
          return null;
        } else {
          _getQiitaItems();
          return Center(
            child: Container(
              margin: EdgeInsets.only(top: 8.0),
              width: 32.0,
              height: 32.0,
              child: CircularProgressIndicator(),
            ),
          );
        }
      } else if (i > _qiitaItems.length) {
        return null;
      }
    });
  }

  Widget _buildQiitaItemRow(QiitaItem qiitaItem) {
    return ListTile(
      leading: _buildBadge(qiitaItem.profileImageUrl),
      title: Text(
        qiitaItem.title,
        style: _biggerFontStyle,
      ),
      subtitle: Text('@' + qiitaItem.userId),
      trailing: FavoriteButton(
          qiitaItem: qiitaItem,
          savedQiitaItems: _savedQiitaItems,
          handleFavoritePressed: _handleFavoritePressed),
      onTap: () {
        _viewQiitaItem(qiitaItem);
      },
    );
  }

  Widget _buildBadge(String url) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2.0),
      width: 36.0,
      height: 36.0,
      decoration: BoxDecoration(
        image: DecorationImage(image: NetworkImage(url)),
        shape: BoxShape.circle,
      ),
      child: Container(
        padding: EdgeInsets.all(1.0),
        child: Center(
          child: Text(
            '',
            style: TextStyle(color: Colors.white, fontSize: 16.0),
          ),
        ),
      ),
    );
  }

  _handleFavoritePressed(QiitaItem qiitaItem, bool isAlreadySaved, Set<QiitaItem> savedQiitaItems) {
    setState(
            () {
          if (isAlreadySaved) {
            savedQiitaItems.remove(qiitaItem);
          } else {
            savedQiitaItems.add(qiitaItem);
          }
        }
    );
  }

  void _viewQiitaItem(QiitaItem qiitaItem) {
    url_launcher.launch(qiitaItem.url);
  }

  Future<Null> _getInitialQiitaItems() async {
    _nextPage = 1;
    await _getQiitaItems();
  }

  Future<Null> _getQiitaItems() async {
    final qiitaItems = await new RepositoryFactory().gerQiitaItemRepository().search(_nextPage, 20);
    if (qiitaItems.isEmpty) {
      setState(() {
        _isLastPage = true;
      });
    } else {
      setState(() {
        _qiitaItems.addAll(qiitaItems);
        _nextPage++;
      });
    }

  }
}

typedef void FavoritePressedCallback(QiitaItem qiitaItem, bool isAlreadySaved, Set<QiitaItem> savedQiitaItems);

class FavoriteButton extends StatelessWidget {
  final QiitaItem qiitaItem;
  final Set<QiitaItem> savedQiitaItems;
  final FavoritePressedCallback handleFavoritePressed;
  final bool isAlreadySaved;

  FavoriteButton({
    @required this.qiitaItem,
    @required this.savedQiitaItems,
    @required this.handleFavoritePressed}) : isAlreadySaved = savedQiitaItems.contains(qiitaItem);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(0.0),
      child: IconButton(
          icon: Icon(
            isAlreadySaved ? Icons.favorite : Icons.favorite_border,
            color: isAlreadySaved ? Colors.red : null,
          ),
          onPressed: () {
            handleFavoritePressed(qiitaItem, isAlreadySaved, savedQiitaItems);
          }
      ),
    );
  }
}