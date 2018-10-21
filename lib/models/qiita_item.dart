class QiitaItem {

  final String title;
  final String url;
  final String userId;
  final String profileImageUrl;
  final int likesCount;

  static QiitaItem fromJson(json) {
    return QiitaItem(
        json['title'],
        json['url'],
        json['user']['id'],
        json['user']['profile_image_url'],
        json['likes_count']);

  }
  const QiitaItem(
    this.title,
    this.url,
    this.userId,
    this.profileImageUrl,
    this.likesCount);
}