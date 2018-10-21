import 'dart:async';

import 'package:flutter_qiita_client/models/qiita_item.dart';

abstract class QiitaItemRepository {

  Future<List<QiitaItem>> search(int page, int perPage);
}