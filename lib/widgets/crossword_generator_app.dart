import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import 'category_selection_screen.dart';
import 'crossword_info_widget.dart';
import 'crossword_widget.dart';
import 'game_mode_selection_screen.dart';

class CrosswordGeneratorApp extends StatelessWidget {
  const CrosswordGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return _EagerInitialization(
      child: Scaffold(
        appBar: AppBar(
          leading: Consumer(
            builder: (context, ref, _) {
              final hasInternetAsync = ref.watch(hasInternetProvider);

              return hasInternetAsync.when(
                data: (hasInternet) {
                  if (!hasInternet) {
                    return const Icon(Icons.wifi_off, color: Colors.red);
                  }
                  return IconButton(
                    icon: const Icon(Icons.category),
                    tooltip: 'Seleccionar Categoría',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CategorySelectionScreen(),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Icon(Icons.wifi),
                error: (_, __) => const Icon(Icons.wifi_off, color: Colors.red),
              );
            },
          ),
          title: Consumer(
            builder: (context, ref, _) {
              final selectedCategory = ref.watch(selectedCategoryProvider);
              final hasInternetAsync = ref.watch(hasInternetProvider);

              return hasInternetAsync.when(
                data: (hasInternet) {
                  if (hasInternet && selectedCategory != null) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Crossword Generator',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Categoría: $selectedCategory',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    );
                  }
                  return Text(
                    hasInternet
                        ? 'Crossword Generator'
                        : 'Crossword Generator (Sin Internet)',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
                loading: () => Text(
                  'Crossword Generator',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                error: (_, __) => Text(
                  'Crossword Generator',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
          actions: [_CrosswordGeneratorMenu()],
        ),
        body: SafeArea(
          child: Consumer(
            builder: (context, ref, child) {
              return Stack(
                children: [
                  Positioned.fill(child: CrosswordWidget()),
                  if (ref.watch(showDisplayInfoProvider)) CrosswordInfoWidget(),
                ],
              );
            },
          ),
        ),
        floatingActionButton: Consumer(
          builder: (context, ref, _) {
            return FloatingActionButton.extended(
              onPressed: () {
                // Ocultar el panel de información antes de jugar si está visible
                if (ref.read(showDisplayInfoProvider)) {
                  ref.read(showDisplayInfoProvider.notifier).toggle();
                }
                
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const GameModeSelectionScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Jugar'),
            );
          },
        ),
      ),
    );
  }
}

class _EagerInitialization extends ConsumerWidget {
  const _EagerInitialization({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchar cambios en la categoría seleccionada
    ref.listen(selectedCategoryProvider, (previous, next) {
      // Cuando cambia la categoría, invalidar wordList para que se recargue
      if (previous != next) {
        ref.invalidate(wordListProvider);
      }
    });
    
    ref.watch(wordListProvider);
    return child;
  }
}

class _CrosswordGeneratorMenu extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => MenuAnchor(
    menuChildren: [
      for (final entry in CrosswordSize.values)
        MenuItemButton(
          onPressed: () => ref.read(sizeProvider.notifier).setSize(entry),
          leadingIcon: entry == ref.watch(sizeProvider)
              ? Icon(Icons.radio_button_checked_outlined)
              : Icon(Icons.radio_button_unchecked_outlined),
          child: Text(entry.label),
        ),
      for (final count in BackgroundWorkers.values)
        MenuItemButton(
          onPressed: () =>
              ref.read(workerCountProvider.notifier).setCount(count),
          leadingIcon: count == ref.watch(workerCountProvider)
              ? Icon(Icons.radio_button_checked_outlined)
              : Icon(Icons.radio_button_unchecked_outlined),
          child: Text('${count.label} worker${count.count == 1 ? "" : "s"}'),
        ),
      MenuItemButton(
        leadingIcon: ref.watch(showDisplayInfoProvider)
            ? Icon(Icons.check_box_outlined)
            : Icon(Icons.check_box_outline_blank_outlined),
        onPressed: () => ref.read(showDisplayInfoProvider.notifier).toggle(),
        child: Text('Display Info'),
      ),
    ],
    builder: (context, controller, child) => IconButton(
      onPressed: () => controller.open(),
      icon: Icon(Icons.settings),
    ),
  );
}
