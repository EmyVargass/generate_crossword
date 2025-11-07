import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'model.dart';
import 'providers.dart';
import 'services/feedback_service.dart';
import 'services/supabase_service.dart';

part 'game_providers.g.dart';

/// Provider para el modo de juego seleccionado
@Riverpod(keepAlive: true)
class SelectedGameMode extends _$SelectedGameMode {
  @override
  GameConfig build() {
    return GameConfig.timeMode5Min;
  }

  void setConfig(GameConfig config) {
    state = config;
  }
}

/// Provider para el estado del juego
@Riverpod(keepAlive: true)
class GameStateNotifier extends _$GameStateNotifier {
  @override
  GameState build() {
    return GameState.notStarted;
  }

  void start() {
    state = GameState.playing;
  }

  void win() {
    state = GameState.won;
  }

  void lose() {
    state = GameState.lost;
  }

  void reset() {
    state = GameState.notStarted;
  }
}

/// Provider para el tiempo restante (en segundos)
@Riverpod(keepAlive: true)
class TimeRemaining extends _$TimeRemaining {
  Timer? _timer;

  @override
  int? build() {
    return null;
  }

  void start(int seconds) {
    state = seconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state == null || state! <= 0) {
        timer.cancel();
        ref.read(gameStateNotifierProvider.notifier).lose();
        return;
      }
      state = state! - 1;
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void reset() {
    _timer?.cancel();
    _timer = null;
    state = null;
  }
}

/// Provider para los intentos restantes
@Riverpod(keepAlive: true)
class AttemptsRemaining extends _$AttemptsRemaining {
  @override
  int? build() {
    return null;
  }

  void initialize(int attempts) {
    state = attempts;
  }

  void decrement() {
    if (state != null && state! > 0) {
      state = state! - 1;
      if (state == 0) {
        ref.read(gameStateNotifierProvider.notifier).lose();
      }
    }
  }

  void reset() {
    state = null;
  }
}

/// Provider para las palabras adivinadas
@Riverpod(keepAlive: true)
class GuessedWords extends _$GuessedWords {
  @override
  List<WordGuess> build() {
    return [];
  }

  void addGuess(WordGuess guess) {
    state = [...state, guess];

    // Dar feedback
    if (guess.isCorrect) {
      FeedbackService.successFeedback();
    } else {
      FeedbackService.errorFeedback();
      // Decrementar intentos si está en modo intentos
      final gameConfig = ref.read(selectedGameModeProvider);
      if (gameConfig.mode == GameMode.attempts) {
        ref.read(attemptsRemainingProvider.notifier).decrement();
      }
    }

    // Verificar si ganó
    _checkWinCondition();
  }

  void _checkWinCondition() {
    final workQueueAsync = ref.read(workQueueProvider);
    workQueueAsync.whenData((workQueue) {
      if (workQueue.isCompleted) {
        final crossword = workQueue.crossword;
        final totalWords = crossword.words.length;
        final correctGuesses = state.where((g) => g.isCorrect).length;

        if (correctGuesses >= totalWords) {
          ref.read(gameStateNotifierProvider.notifier).win();
          ref.read(timeRemainingProvider.notifier).stop();
          _saveScore();
        }
      }
    });
  }

  Future<void> _saveScore() async {
    try {
      final timeStarted = ref.read(gameStartTimeProvider);
      final gameConfig = ref.read(selectedGameModeProvider);
      final category = ref.read(selectedCategoryProvider) ?? 'Local';
      
      if (timeStarted == null) return;

      final timeElapsed = DateTime.now().difference(timeStarted).inSeconds;
      final correctGuesses = state.where((g) => g.isCorrect).length;
      
      await SupabaseService.saveScore(
        playerName: 'Player', // TODO: Agregar nombre de jugador
        score: correctGuesses * 100,
        time: timeElapsed,
        category: category,
      );
    } catch (e) {
      debugPrint('Error saving score: $e');
    }
  }

  void reset() {
    state = [];
  }
}

/// Provider para verificar si una palabra fue adivinada
@riverpod
bool isWordGuessed(IsWordGuessedRef ref, CrosswordWord word) {
  final guesses = ref.watch(guessedWordsProvider);
  return guesses.any((g) => 
    g.isCorrect && 
    g.word.word == word.word &&
    g.word.location == word.location &&
    g.word.direction == word.direction
  );
}

/// Provider para obtener todas las palabras del crucigrama
@riverpod
List<CrosswordWord> crosswordWords(CrosswordWordsRef ref) {
  final workQueueAsync = ref.watch(workQueueProvider);
  return workQueueAsync.when(
    data: (workQueue) => workQueue.crossword.words.toList(),
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Provider para el score actual
@riverpod
int currentScore(CurrentScoreRef ref) {
  final guesses = ref.watch(guessedWordsProvider);
  final correctGuesses = guesses.where((g) => g.isCorrect).length;
  return correctGuesses * 100;
}

/// Provider para el tiempo de inicio del juego
@Riverpod(keepAlive: true)
class GameStartTime extends _$GameStartTime {
  @override
  DateTime? build() {
    return null;
  }

  void start() {
    state = DateTime.now();
  }

  void reset() {
    state = null;
  }
}
