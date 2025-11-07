import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model.dart' as model;
import '../game_providers.dart';
import 'crossword_game_screen.dart';

class GameModeSelectionScreen extends ConsumerWidget {
  const GameModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedConfig = ref.watch(selectedGameModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Modo de Juego'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Elige cómo quieres jugar:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Modo de Tiempo
            Card(
              elevation: selectedConfig.mode == model.GameMode.time ? 8 : 2,
              color: selectedConfig.mode == model.GameMode.time
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          model.GameMode.time.icon,
                          size: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          model.GameMode.time.label,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Completa el crucigrama antes de que se acabe el tiempo',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    _buildTimeOptions(context, ref, selectedConfig),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Modo de Intentos
            Card(
              elevation: selectedConfig.mode == model.GameMode.attempts ? 8 : 2,
              color: selectedConfig.mode == model.GameMode.attempts
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          model.GameMode.attempts.icon,
                          size: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          model.GameMode.attempts.label,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tienes un número limitado de intentos para adivinar',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    _buildAttemptsOptions(context, ref, selectedConfig),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            FilledButton.icon(
              onPressed: () => _startGame(context, ref),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Iniciar Juego'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeOptions(
    BuildContext context,
    WidgetRef ref,
    model.GameConfig selectedConfig,
  ) {
    return Column(
      children: [
        RadioListTile<model.GameConfig>(
          title: const Text('5 minutos - Relajado'),
          value: model.GameConfig.timeMode5Min,
          groupValue: selectedConfig,
          onChanged: (value) {
            if (value != null) {
              ref.read(selectedGameModeProvider.notifier).setConfig(value);
            }
          },
        ),
        RadioListTile<model.GameConfig>(
          title: const Text('3 minutos - Normal'),
          value: model.GameConfig.timeMode3Min,
          groupValue: selectedConfig,
          onChanged: (value) {
            if (value != null) {
              ref.read(selectedGameModeProvider.notifier).setConfig(value);
            }
          },
        ),
        RadioListTile<model.GameConfig>(
          title: const Text('1 minuto - Desafío'),
          value: model.GameConfig.timeMode1Min,
          groupValue: selectedConfig,
          onChanged: (value) {
            if (value != null) {
              ref.read(selectedGameModeProvider.notifier).setConfig(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildAttemptsOptions(
    BuildContext context,
    WidgetRef ref,
    model.GameConfig selectedConfig,
  ) {
    return Column(
      children: [
        RadioListTile<model.GameConfig>(
          title: const Text('10 intentos - Fácil'),
          value: model.GameConfig.attempts10,
          groupValue: selectedConfig,
          onChanged: (value) {
            if (value != null) {
              ref.read(selectedGameModeProvider.notifier).setConfig(value);
            }
          },
        ),
        RadioListTile<model.GameConfig>(
          title: const Text('5 intentos - Medio'),
          value: model.GameConfig.attempts5,
          groupValue: selectedConfig,
          onChanged: (value) {
            if (value != null) {
              ref.read(selectedGameModeProvider.notifier).setConfig(value);
            }
          },
        ),
        RadioListTile<model.GameConfig>(
          title: const Text('3 intentos - Difícil'),
          value: model.GameConfig.attempts3,
          groupValue: selectedConfig,
          onChanged: (value) {
            if (value != null) {
              ref.read(selectedGameModeProvider.notifier).setConfig(value);
            }
          },
        ),
      ],
    );
  }

  void _startGame(BuildContext context, WidgetRef ref) {
    final config = ref.read(selectedGameModeProvider);
    
    // Inicializar el juego
    ref.read(gameStateNotifierProvider.notifier).start();
    ref.read(gameStartTimeProvider.notifier).start();
    ref.read(guessedWordsProvider.notifier).reset();
    
    if (config.mode == model.GameMode.time) {
      ref.read(timeRemainingProvider.notifier).start(config.timeInSeconds);
      ref.read(attemptsRemainingProvider.notifier).reset();
    } else {
      ref.read(attemptsRemainingProvider.notifier).initialize(config.maxAttempts);
      ref.read(timeRemainingProvider.notifier).reset();
    }
    
    // Navegar a la pantalla del juego
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const CrosswordGameScreen(),
      ),
    );
  }
}
