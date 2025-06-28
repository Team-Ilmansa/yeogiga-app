/// 날씨 코드/상태 → 이미지 asset 매핑 함수
String getWeatherImageAsset(String weatherMain) {
  switch (weatherMain.toLowerCase()) {
    case 'clouds':
      return 'asset/img/weather/cloudy.png';
    case 'thunderstorm':
      return 'asset/img/weather/lightning.png';
    case 'rain':
      return 'asset/img/weather/rainy.png';
    case 'drizzle':
      return 'asset/img/weather/rainy.png';
    case 'snow':
      return 'asset/img/weather/snowy.png';
    case 'wind':
      return 'asset/img/weather/windy.png';
    case 'clear':
      return 'asset/img/weather/sunnyday.png';
    default:
      return 'asset/img/weather/sunnyday.png';
  }
}
