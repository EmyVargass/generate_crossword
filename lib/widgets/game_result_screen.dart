import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model.dart' as model;
import '../game_providers.dart';
import '../providers.dart';
import '../services/supabase_service.dart';

class GameResultScreen extends ConsumerStatefulWidget {
  final bool won;

  const GameResultScreen({super.key, required this.won});

  @override
  ConsumerState<GameResultScreen> createState() => _GameResultScreenState();
}

class _GameResultScreenState extends ConsumerState<GameResultScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _savingScore = false;
  List<Map<String, dynamic>> _topScores = [];
  bool _loadingScores = false;

  @override
  void initState() {
    super.initState();
    _loadTopScores();
    if (widget.won) {
      _showNameDialog();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadTopScores() async {
    setState(() {
      _loadingScores = true;
    });

    try {
      final scores = await SupabaseService.getTopScores(limit: 10);
      
      setState(() {
        _topScores = scores;
        _loadingScores = false;
      });
    } catch (e) {
      debugPrint('Error loading scores: $e');
      setState(() {
        _loadingScores = false;
      });
    }
  }

  Future<void> _saveScore(String playerName) async {
    setState(() {
      _savingScore = true;
    });

    try {
      final startTime = ref.read(gameStartTimeProvider);
      final category = ref.read(selectedCategoryProvider) ?? 'Local';
      final guessedWords = ref.read(guessedWordsProvider);
      
      if (startTime == null) return;

      final timeElapsed = DateTime.now().difference(startTime).inSeconds;
      final correctGuesses = guessedWords.where((g) => g.isCorrect).length;
      final score = correctGuesses * 100;

      await SupabaseService.saveScore(
        playerName: playerName,
        score: score,
        time: timeElapsed,
        category: category,
      );

      setState(() {
        _savingScore = false;
      });

      // Recargar los scores
      await _loadTopScores();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Puntaje guardado exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _savingScore = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar puntaje: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showNameDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('¡Felicitaciones!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Ingresa tu nombre para guardar tu puntaje:'),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Tu nombre',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                maxLength: 20,
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    Navigator.of(context).pop();
                    _saveScore(value.trim());
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Omitir'),
            ),
            FilledButton(
              onPressed: _savingScore
                  ? null
                  : () {
                      final name = _nameController.text.trim();
                      if (name.isNotEmpty) {
                        Navigator.of(context).pop();
                        _saveScore(name);
                      }
                    },
              child: _savingScore
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Guardar'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameConfig = ref.watch(selectedGameModeProvider);
    final guessedWords = ref.watch(guessedWordsProvider);
    final startTime = ref.watch(gameStartTimeProvider);
    final currentScore = ref.watch(currentScoreProvider);
    final workQueueAsync = ref.watch(workQueueProvider);

    final correctGuesses = guessedWords.where((g) => g.isCorrect).length;
    final totalWords = workQueueAsync.when(
      data: (workQueue) => workQueue.crossword.words.length,
      loading: () => 0,
      error: (_, __) => 0,
    );

    final timeElapsed = startTime != null
        ? DateTime.now().difference(startTime).inSeconds
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.won ? '¡Victoria!' : 'Juego Terminado'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Result icon and message
            Icon(
              widget.won ? Icons.emoji_events : Icons.sentiment_dissatisfied,
              size: 100,
              color: widget.won ? Colors.amber : Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              widget.won ? '¡Felicitaciones!' : '¡Inténtalo de nuevo!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.won
                  ? 'Completaste el crucigrama exitosamente'
                  : gameConfig.mode == model.GameMode.time
                      ? 'Se acabó el tiempo'
                      : 'Se acabaron los intentos',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Stats card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Estadísticas',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Divider(height: 24),
                    _buildStatRow(
                      context,
                      Icons.emoji_events,
                      'Puntaje',
                      currentScore.toString(),
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      context,
                      Icons.check_circle,
                      'Palabras correctas',
                      '$correctGuesses / $totalWords',
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      context,
                      Icons.timer,
                      'Tiempo',
                      _formatTime(timeElapsed),
                    ),
                    if (gameConfig.mode == model.GameMode.attempts) ...[
                      const SizedBox(height: 12),
                      _buildStatRow(
                        context,
                        Icons.numbers,
                        'Intentos usados',
                        '${guessedWords.where((g) => !g.isCorrect).length}',
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Leaderboard
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tabla de Líderes',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _loadingScores ? null : _loadTopScores,
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    if (_loadingScores)
                      const Center(child: CircularProgressIndicator())
                    else if (_topScores.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No hay puntajes guardados'),
                        ),
                      )
                    else
                      ..._topScores.asMap().entries.map((entry) {
                        final index = entry.key;
                        final score = entry.value;
                        return _buildLeaderboardRow(
                          context,
                          index + 1,
                          score['player_name'] ?? 'Anónimo',
                          score['score'] ?? 0,
                          score['time'] ?? 0,
                        );
                      }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            FilledButton.icon(
              onPressed: () {
                // Reset game state
                ref.read(gameStateNotifierProvider.notifier).reset();
                ref.read(timeRemainingProvider.notifier).reset();
                ref.read(attemptsRemainingProvider.notifier).reset();
                ref.read(guessedWordsProvider.notifier).reset();
                ref.read(gameStartTimeProvider.notifier).reset();

                // Go back to main screen
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: const Icon(Icons.home),
              label: const Text('Volver al Inicio'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            const SizedBox(height: 8),

            OutlinedButton.icon(
              onPressed: () {
                // Reset game state
                ref.read(gameStateNotifierProvider.notifier).reset();
                ref.read(timeRemainingProvider.notifier).reset();
                ref.read(attemptsRemainingProvider.notifier).reset();
                ref.read(guessedWordsProvider.notifier).reset();
                ref.read(gameStartTimeProvider.notifier).reset();

                // Go back to mode selection
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.replay),
              label: const Text('Jugar de Nuevo'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardRow(
    BuildContext context,
    int position,
    String name,
    int score,
    int time,
  ) {
    IconData medal;
    Color? medalColor;

    switch (position) {
      case 1:
        medal = Icons.emoji_events;
        medalColor = Colors.amber;
        break;
      case 2:
        medal = Icons.emoji_events;
        medalColor = Colors.grey.shade400;
        break;
      case 3:
        medal = Icons.emoji_events;
        medalColor = Colors.brown.shade400;
        break;
      default:
        medal = Icons.circle;
        medalColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Icon(medal, color: medalColor, size: 24),
          ),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$score pts',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatTime(time),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
