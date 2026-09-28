import 'package:flutter/material.dart';
import '../../services/weather_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.userName, required this.userId});

  final String userName;
  final String userId;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _weatherService = WeatherService();
  final _firestoreService = FirestoreService();
  WeatherData? _weather;
  Map<String, int>? _stats;
  bool _loadingWeather = true;

  @override
  void initState() {
    super.initState();
    _loadWeather();
    _loadStats();
  }

  Future<void> _loadWeather() async {
    try {
      final weather = await _weatherService.getCurrentWeather();
      if (mounted) setState(() => _weather = weather);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingWeather = false);
    }
  }

  Future<void> _loadStats() async {
    final stats = await _firestoreService.getUserBookStats(widget.userId);
    if (mounted) setState(() => _stats = stats);
  }

  String get _firstName => widget.userName.split(' ').first;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadWeather();
          await _loadStats();
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text(
                    'Tu biblioteca en números',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _buildStatsRow(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$_greeting,',
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
          Text(
            '$_firstName 👋',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildWeatherCard(),
        ],
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: _loadingWeather
          ? const SizedBox(
              height: 40,
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2,
                ),
              ),
            )
          : _weather == null
              ? const Text('No se pudo cargar el clima',
                  style: TextStyle(color: Colors.white70))
              : Row(
                  children: [
                    Text(_weather!.emoji, style: const TextStyle(fontSize: 38)),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_weather!.temperature.toStringAsFixed(1)}°C',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _weather!.description,
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
    );
  }

  Widget _buildStatsRow() {
    if (_stats == null) {
      return const SizedBox(
        height: 90,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.check_circle,
            label: 'Leídos',
            count: _stats!['leido']!,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            icon: Icons.menu_book,
            label: 'Leyendo',
            count: _stats!['leyendo']!,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            icon: Icons.bookmark_border,
            label: 'Pendientes',
            count: _stats!['pendiente']!,
            color: AppColors.pending,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            '$count',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textLight),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}