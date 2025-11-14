/// 카테고리 아이콘 유틸리티
class CategoryIconUtil {
  /// 카테고리에 따라 아이콘 경로 반환
  static String getCategoryIconByKorean(String category) {
    switch (category.toUpperCase()) {
      case '관광지':
        return 'asset/icon/category spot.svg';
      case '숙소':
        return 'asset/icon/category hotel.svg';
      case '식당':
        return 'asset/icon/category restaurant.svg';
      case '교통수단':
        return 'asset/icon/category transport.svg';
      case '기타':
        return 'asset/icon/category etc.svg';
      case '매칭해제':
        return 'asset/icon/category real etc.svg';
      default:
        return 'asset/icon/category icon.svg'; // 기본값
    }
  }

  static String getCategoryIconByEnglish(String category) {
    switch (category.toUpperCase()) {
      case 'TOURISM':
        return 'asset/icon/category spot.svg';
      case 'LODGING':
        return 'asset/icon/category hotel.svg';
      case 'RESTAURANT':
        return 'asset/icon/category restaurant.svg';
      case 'TRANSPORT':
        return 'asset/icon/category transport.svg';
      case 'ETC':
        return 'asset/icon/category etc.svg';
      default:
        return 'asset/icon/category icon.svg'; // 기본값
    }
  }

  /// 영문 카테고리 타입을 한글로 변환
  static String getCategoryKoreanName(String type) {
    switch (type.toUpperCase()) {
      case 'TOURISM':
        return '관광지';
      case 'LODGING':
        return '숙소';
      case 'RESTAURANT':
        return '식당';
      case 'TRANSPORT':
        return '교통수단';
      case 'ETC':
        return '기타';
      default:
        return '기타';
    }
  }

  /// 한글 카테고리를 영문 타입으로 변환
  static String getCategoryEnglishType(String korean) {
    switch (korean) {
      case '관광지':
        return 'TOURISM';
      case '숙소':
        return 'LODGING';
      case '식당':
        return 'RESTAURANT';
      case '교통수단':
        return 'TRANSPORT';
      case '기타':
        return 'ETC';
      default:
        return 'ETC';
    }
  }
}
