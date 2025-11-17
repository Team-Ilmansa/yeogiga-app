const String _tripCardAssetBase = 'asset/img/tripcard';
const String _defaultTripCardBackground = '$_tripCardAssetBase/etc.jpg';

const Map<String, String> _cityImageMap = {
  '서울': '$_tripCardAssetBase/seoul.jpg',
  '서울특별시': '$_tripCardAssetBase/seoul.jpg',
  '부산': '$_tripCardAssetBase/busan.jpg',
  '부산광역시': '$_tripCardAssetBase/busan.jpg',
  '대구': '$_tripCardAssetBase/daegu.jpg',
  '대구광역시': '$_tripCardAssetBase/daegu.jpg',
  '인천': '$_tripCardAssetBase/incheon.jpg',
  '인천광역시': '$_tripCardAssetBase/incheon.jpg',
  '여수': '$_tripCardAssetBase/yeosu.jpg',
  '여수시': '$_tripCardAssetBase/yeosu.jpg',
  '경주': '$_tripCardAssetBase/gyeongju.jpg',
  '경주시': '$_tripCardAssetBase/gyeongju.jpg',
  '강릉': '$_tripCardAssetBase/gangneung.jpg',
  '강릉시': '$_tripCardAssetBase/gangneung.jpg',
  '전주': '$_tripCardAssetBase/jeonju.jpg',
  '전주시': '$_tripCardAssetBase/jeonju.jpg',
  '제주': '$_tripCardAssetBase/jeju.jpg',
  '제주시': '$_tripCardAssetBase/jeju.jpg',
  '제주특별자치도': '$_tripCardAssetBase/jeju.jpg',
  '포항': '$_tripCardAssetBase/pohang.jpg',
  '포항시': '$_tripCardAssetBase/pohang.jpg',
};

/// Returns the asset path for the trip card background based on the first city.
String getTripCardBackgroundAsset(String? cityName) {
  final normalized = _normalizeCityName(cityName);
  if (normalized == null) return _defaultTripCardBackground;
  return _cityImageMap[normalized] ?? _defaultTripCardBackground;
}

String? _normalizeCityName(String? cityName) {
  if (cityName == null) return null;
  final trimmed = cityName.trim();
  if (trimmed.isEmpty) return null;
  return trimmed.replaceAll(' ', '');
}
