import 'dart:async';

import 'package:flutter_qiita_client/api/qiita_api.dart';
import 'package:flutter_qiita_client/models/qiita_item.dart';
import 'package:flutter_qiita_client/repository/qiita_item_repository.dart';

class QiitaItemRepositoryImpl implements QiitaItemRepository {

  QiitaApi _api;

  List<QiitaItem> _cache = new List();

  bool _isDirty = true;

  QiitaItemRepositoryImpl(this._api, this._cache);

  @override
  Future<List<QiitaItem>> search(int page, int perPage) {
    if (!_isDirty && _cache.isNotEmpty) {
      return new Future.value(_cache);
    }
    return _api.getItems(page, perPage).then((items) {
      _isDirty = false;
      _cache = items;
      return items;
    });
  }
}