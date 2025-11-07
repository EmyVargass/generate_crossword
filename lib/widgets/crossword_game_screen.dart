import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model.dart' as model;
import '../game_providers.dart';
import '../providers.dart';
import 'game_result_screen.dart';

class CrosswordGameScreen extends ConsumerStatefulWidget {
  const CrosswordGameScreen({super.key});

  @override
  ConsumerState<CrosswordGameScreen> createState() => _CrosswordGameScreenState();
}

class _CrosswordGameScreenState extends ConsumerState<CrosswordGameScreen> {
  model.CrosswordWord? selectedWord;
  final TextEditingController _guessController = TextEditingController();

  @override
  void dispose() {
    _guessController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameConfig = ref.watch(selectedGameModeProvider);
    final timeRemaining = ref.watch(timeRemainingProvider);
    final attemptsRemaining = ref.watch(attemptsRemainingProvider);
    final guessedWords = ref.watch(guessedWordsProvider);
    final currentScore = ref.watch(currentScoreProvider);
    final workQueueAsync = ref.watch(workQueueProvider);

    // Listener para detectar victoria o derrota
    ref.listen<model.GameState>(gameStateNotifierProvider, (previous, next) {
      if (next == model.GameState.won || next == model.GameState.lost) {
        // Navegar a pantalla de resultado
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => GameResultScreen(won: next == model.GameState.won),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Juego de Crucigrama'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _showExitConfirmation(context);
          },
        ),
        actions: [
          // Mostrar temporizador o intentos según el modo
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: gameConfig.mode == model.GameMode.time
                  ? _buildTimer(timeRemaining)
                  : _buildAttempts(attemptsRemaining),
            ),
          ),
        ],
      ),
      body: workQueueAsync.when(
        data: (workQueue) {
          if (!workQueue.isCompleted) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final crossword = workQueue.crossword;
          final words = crossword.words.toList();

          return Column(
            children: [
              // Score bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatChip(
                      context,
                      Icons.emoji_events,
                      'Puntaje',
                      currentScore.toString(),
                    ),
                    _buildStatChip(
                      context,
                      Icons.check_circle,
                      'Palabras',
                      '${guessedWords.where((g) => g.isCorrect).length}/${words.length}',
                    ),
                  ],
                ),
              ),

              // Crossword grid
              Expanded(
                child: InteractiveViewer(
                  constrained: false,
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildCrosswordGrid(context, crossword, words),
                    ),
                  ),
                ),
              ),

              // Input section
              if (selectedWord != null) _buildInputSection(context),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildTimer(int? timeRemaining) {
    if (timeRemaining == null) return const SizedBox.shrink();

    final minutes = timeRemaining ~/ 60;
    final seconds = timeRemaining % 60;
    final isLowTime = timeRemaining < 30;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.timer,
          color: isLowTime ? Colors.red : Colors.white,
          size: 20,
        ),
        const SizedBox(width: 4),
        Text(
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isLowTime ? Colors.red : Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildAttempts(int? attemptsRemaining) {
    if (attemptsRemaining == null) return const SizedBox.shrink();

    final isLowAttempts = attemptsRemaining <= 1;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.favorite,
          color: isLowAttempts ? Colors.red : Colors.white,
          size: 20,
        ),
        const SizedBox(width: 4),
        Text(
          '$attemptsRemaining',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isLowAttempts ? Colors.red : Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCrosswordGrid(
    BuildContext context,
    model.Crossword crossword,
    List<model.CrosswordWord> words,
  ) {
    final cellSize = 40.0;
    final gridWidth = crossword.width * cellSize;
    final gridHeight = crossword.height * cellSize;

    return SizedBox(
      width: gridWidth,
      height: gridHeight,
      child: Stack(
        children: [
          // Draw grid background
          ...List.generate(crossword.height, (row) {
            return List.generate(crossword.width, (col) {
              final location = model.Location.at(col, row);
              final hasChar = crossword.characters[location] != null;

              return Positioned(
                left: col * cellSize,
                top: row * cellSize,
                child: Container(
                  width: cellSize,
                  height: cellSize,
                  decoration: BoxDecoration(
                    color: hasChar ? Colors.white : Colors.grey.shade300,
                    border: Border.all(
                      color: Colors.grey.shade400,
                      width: 0.5,
                    ),
                  ),
                ),
              );
            });
          }).expand((list) => list),

          // Draw words
          ...words.map((word) {
            final isGuessed = ref.watch(isWordGuessedProvider(word));
            final isSelected = selectedWord == word;

            return Positioned(
              left: word.location.x * cellSize,
              top: word.location.y * cellSize,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedWord = word;
                    _guessController.clear();
                  });
                },
                child: Container(
                  width: word.direction == model.Direction.across
                      ? word.word.length * cellSize
                      : cellSize,
                  height: word.direction == model.Direction.down
                      ? word.word.length * cellSize
                      : cellSize,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blue.withOpacity(0.3)
                        : isGuessed
                            ? Colors.green.withOpacity(0.2)
                            : Colors.transparent,
                    border: isSelected
                        ? Border.all(color: Colors.blue, width: 2)
                        : null,
                  ),
                  child: Stack(
                    children: [
                      // Show letters if guessed
                      if (isGuessed)
                        ...List.generate(word.word.length, (index) {
                          final x = word.direction == model.Direction.across ? index : 0;
                          final y = word.direction == model.Direction.down ? index : 0;

                          return Positioned(
                            left: x * cellSize,
                            top: y * cellSize,
                            child: Container(
                              width: cellSize,
                              height: cellSize,
                              alignment: Alignment.center,
                              child: Text(
                                word.word[index].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInputSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                selectedWord!.direction == model.Direction.across
                    ? Icons.arrow_forward
                    : Icons.arrow_downward,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '${selectedWord!.direction == model.Direction.across ? "Horizontal" : "Vertical"} - ${selectedWord!.word.length} letras',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedWord = null;
                    _guessController.clear();
                  });
                },
                child: const Text('Cancelar'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _guessController,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: selectedWord!.word.length,
                  decoration: InputDecoration(
                    hintText: 'Escribe tu respuesta...',
                    border: const OutlineInputBorder(),
                    counterText: '',
                    suffixIcon: _guessController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _guessController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                  onSubmitted: (value) {
                    if (value.length == selectedWord!.word.length) {
                      _submitGuess();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _guessController.text.length == selectedWord!.word.length
                    ? _submitGuess
                    : null,
                icon: const Icon(Icons.send),
                label: const Text('Enviar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submitGuess() {
    if (selectedWord == null) return;

    final guess = _guessController.text.trim().toUpperCase();
    final correctWord = selectedWord!.word.toUpperCase();
    final isCorrect = guess == correctWord;

    // Crear WordGuess
    final wordGuess = model.WordGuess(
      word: selectedWord!,
      guess: guess,
      isCorrect: isCorrect,
      timestamp: DateTime.now(),
    );

    // Agregar al provider (esto dispara el feedback automáticamente)
    ref.read(guessedWordsProvider.notifier).addGuess(wordGuess);

    // Limpiar selección
    setState(() {
      selectedWord = null;
      _guessController.clear();
    });
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Salir del juego?'),
        content: const Text('Si sales ahora, perderás tu progreso actual.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              // Detener el juego
              ref.read(timeRemainingProvider.notifier).stop();
              ref.read(gameStateNotifierProvider.notifier).reset();
              
              // Salir
              Navigator.of(context).pop(); // Cerrar diálogo
              Navigator.of(context).pop(); // Salir de la pantalla de juego
            },
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }
}
