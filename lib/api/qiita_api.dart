import 'dart:async';

import 'package:flutter_qiita_client/models/qiita_item.dart';

abstract class QiitaApi {

  Future<List<QiitaItem>> getItems(int page, int perPage);
}