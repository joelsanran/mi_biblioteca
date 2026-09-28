import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherData {
  final double temperature;
  final int weatherCode;

  WeatherData({required this.temperature, required this.weatherCode});

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    return WeatherData(
      temperature: (current['temperature_2m'] as num).toDouble(),
      weatherCode: current['weather_code'] as int,
    );
  }

  // Traduce el código numérico de Open-Meteo a texto legible
  String get description {
    if (weatherCode == 0) return 'Despejado';
    if (weatherCode <= 3) return 'Parcialmente nublado';
    if (weatherCode <= 48) return 'Neblina';
    if (weatherCode <= 67) return 'Lluvia';
    if (weatherCode <= 77) return 'Nieve';
    if (weatherCode <= 82) return 'Chubascos';
    if (weatherCode <= 99) return 'Tormenta';
    return 'Desconocido';
  }

  String get emoji {
    if (weatherCode == 0) return '☀️';
    if (weatherCode <= 3) return '⛅';
    if (weatherCode <= 48) return '🌫️';
    if (weatherCode <= 67) return '🌧️';
    if (weatherCode <= 77) return '❄️';
    if (weatherCode <= 82) return '🌦️';
    return '⛈️';
  }
}

class WeatherService {
  // Coordenadas de ejemplo (Ciudad de México). Cámbialas por tu ciudad.
  static const double _lat = 19.4326;
  static const double _lon = -99.1332;

  Future<WeatherData> getCurrentWeather() async {
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$_lat&longitude=$_lon'
      '&current=temperature_2m,weather_code',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Error al obtener el clima');
    }

    return WeatherData.fromJson(jsonDecode(response.body));
  }
}