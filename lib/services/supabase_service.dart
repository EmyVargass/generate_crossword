import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://aoypczghtrdcarpzyepa.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFveXBjemdodHJkY2FycHp5ZXBhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0NDA1MjYsImV4cCI6MjA3ODAxNjUyNn0.zI3yeuQ-2rUDhQpE1V2Sh7YCigmA_s-OFhmcaZYXSUM';

  static Future<void> initialize() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;

  /// Obtiene todas las categorías disponibles
  static Future<List<String>> getCategories() async {
    try {
      final response = await client
          .from('categories')
          .select('name')
          .order('name', ascending: true);

      return (response as List).map((item) => item['name'] as String).toList();
    } catch (e) {
      throw Exception('Error al obtener categorías: $e');
    }
  }

  /// Obtiene palabras de una categoría específica
  static Future<List<String>> getWordsByCategory(String category) async {
    try {
      final response = await client
          .from('words')
          .select('word')
          .eq('category', category)
          .order('word', ascending: true);

      return (response as List).map((item) => item['word'] as String).toList();
    } catch (e) {
      throw Exception('Error al obtener palabras: $e');
    }
  }

  /// Guarda el score del jugador
  static Future<void> saveScore({
    required String playerName,
    required int score,
    required int time,
    required String category,
  }) async {
    try {
      await client.from('scores').insert({
        'player_name': playerName,
        'score': score,
        'time': time,
        'category': category,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Error al guardar score: $e');
    }
  }

  /// Obtiene los mejores scores
  static Future<List<Map<String, dynamic>>> getTopScores({
    int limit = 10,
  }) async {
    try {
      final response = await client
          .from('scores')
          .select('*')
          .order('score', ascending: false)
          .limit(limit);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Error al obtener scores: $e');
    }
  }
}
