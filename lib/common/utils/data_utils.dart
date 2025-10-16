import 'package:yeogiga/common/const/data.dart';

class DataUtils{
  static DateTime stringToDateTime(String value){
    return DateTime.parse(value);
  }

  static String pathToUrl(String value){
    return 'https://$ip$value';
  }

  static List<String> listPathsToUrls(List paths){
    return paths.map((e) => pathToUrl(e)).toList();
  }

  /// 날짜 포맷 (YYYY-MM-DD -> YYYY. MM. DD)
  static String formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      return '${parsedDate.year}. ${parsedDate.month.toString().padLeft(2, '0')}. ${parsedDate.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return date;
    }
  }

  /// DateTime을 날짜 포맷으로 (DateTime -> YYYY. MM. DD)
  static String formatDateFromDateTime(DateTime date) {
    return '${date.year}. ${date.month.toString().padLeft(2, '0')}. ${date.day.toString().padLeft(2, '0')}';
  }

  // static String plainToBase64(String plain){
  //   Codec<String, String> stringToBase64 = utf8.fuse(base64);

  //   String encoded = stringToBase64.encode(plain);

  //   return encoded;
  // }
}