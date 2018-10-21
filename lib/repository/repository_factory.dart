import 'package:flutter_qiita_client/api/qiita_api.dart';
import 'package:flutter_qiita_client/api/qiita_api_impl.dart';
import 'package:flutter_qiita_client/repository/qiita_item_repository.dart';
import 'package:flutter_qiita_client/repository/qiita_item_repository_impl.dart';

class RepositoryFactory {
  static final RepositoryFactory _singleton = new RepositoryFactory._internal();

  factory RepositoryFactory() {
    return _singleton;
  }

  QiitaApi _api;

  QiitaItemRepository _qiitaItemRepository;

  RepositoryFactory._internal() {
    _api = new QiitaApiImpl();
    _qiitaItemRepository = new QiitaItemRepositoryImpl(_api, new List());
  }

  QiitaItemRepository gerQiitaItemRepository() {
    return _qiitaItemRepository;
  }
}