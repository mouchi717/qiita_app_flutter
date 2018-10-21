import 'dart:async';
import 'dart:convert';

import 'package:flutter_qiita_client/api/qiita_api.dart';
import 'package:flutter_qiita_client/models/qiita_item.dart';
import 'package:http/http.dart' as http;

class QiitaApiImpl implements QiitaApi {

  static const String _BASE_URL = 'http://qiita.com/api/v2';

  @override
  Future<List<QiitaItem>> getItems(int page, int perPage) async {
    final String url = '$_BASE_URL/items?page=$page&per_page=$perPage';
    final response = await http.get(url);
    final body = json.decode(response.body).cast<Map>();
    return body.map((e) => QiitaItem.fromJson(e)).toList();
  }
}