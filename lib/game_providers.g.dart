// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isWordGuessedHash() => r'a5e92ba86fa2bc828935ec1a7d680cd56e6dc9d8';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider para verificar si una palabra fue adivinada
///
/// Copied from [isWordGuessed].
@ProviderFor(isWordGuessed)
const isWordGuessedProvider = IsWordGuessedFamily();

/// Provider para verificar si una palabra fue adivinada
///
/// Copied from [isWordGuessed].
class IsWordGuessedFamily extends Family<bool> {
  /// Provider para verificar si una palabra fue adivinada
  ///
  /// Copied from [isWordGuessed].
  const IsWordGuessedFamily();

  /// Provider para verificar si una palabra fue adivinada
  ///
  /// Copied from [isWordGuessed].
  IsWordGuessedProvider call(CrosswordWord word) {
    return IsWordGuessedProvider(word);
  }

  @override
  IsWordGuessedProvider getProviderOverride(
    covariant IsWordGuessedProvider provider,
  ) {
    return call(provider.word);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'isWordGuessedProvider';
}

/// Provider para verificar si una palabra fue adivinada
///
/// Copied from [isWordGuessed].
class IsWordGuessedProvider extends AutoDisposeProvider<bool> {
  /// Provider para verificar si una palabra fue adivinada
  ///
  /// Copied from [isWordGuessed].
  IsWordGuessedProvider(CrosswordWord word)
    : this._internal(
        (ref) => isWordGuessed(ref as IsWordGuessedRef, word),
        from: isWordGuessedProvider,
        name: r'isWordGuessedProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$isWordGuessedHash,
        dependencies: IsWordGuessedFamily._dependencies,
        allTransitiveDependencies:
            IsWordGuessedFamily._allTransitiveDependencies,
        word: word,
      );

  IsWordGuessedProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.word,
  }) : super.internal();

  final CrosswordWord word;

  @override
  Override overrideWith(bool Function(IsWordGuessedRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: IsWordGuessedProvider._internal(
        (ref) => create(ref as IsWordGuessedRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        word: word,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _IsWordGuessedProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsWordGuessedProvider && other.word == word;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, word.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin IsWordGuessedRef on AutoDisposeProviderRef<bool> {
  /// The parameter `word` of this provider.
  CrosswordWord get word;
}

class _IsWordGuessedProviderElement extends AutoDisposeProviderElement<bool>
    with IsWordGuessedRef {
  _IsWordGuessedProviderElement(super.provider);

  @override
  CrosswordWord get word => (origin as IsWordGuessedProvider).word;
}

String _$crosswordWordsHash() => r'68325ecdac2d3c5e261f2acfb606a55bab2564bb';

/// Provider para obtener todas las palabras del crucigrama
///
/// Copied from [crosswordWords].
@ProviderFor(crosswordWords)
final crosswordWordsProvider =
    AutoDisposeProvider<List<CrosswordWord>>.internal(
      crosswordWords,
      name: r'crosswordWordsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$crosswordWordsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CrosswordWordsRef = AutoDisposeProviderRef<List<CrosswordWord>>;
String _$currentScoreHash() => r'01c080a929f82e481eed0352611983ca012b6cbc';

/// Provider para el score actual
///
/// Copied from [currentScore].
@ProviderFor(currentScore)
final currentScoreProvider = AutoDisposeProvider<int>.internal(
  currentScore,
  name: r'currentScoreProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentScoreHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentScoreRef = AutoDisposeProviderRef<int>;
String _$selectedGameModeHash() => r'0e6a2bc864f71b3ba852f086514e6239aa730072';

/// Provider para el modo de juego seleccionado
///
/// Copied from [SelectedGameMode].
@ProviderFor(SelectedGameMode)
final selectedGameModeProvider =
    NotifierProvider<SelectedGameMode, GameConfig>.internal(
      SelectedGameMode.new,
      name: r'selectedGameModeProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedGameModeHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedGameMode = Notifier<GameConfig>;
String _$gameStateNotifierHash() => r'b59e98715fa1672d3cc5adb884ce3853b532c987';

/// Provider para el estado del juego
///
/// Copied from [GameStateNotifier].
@ProviderFor(GameStateNotifier)
final gameStateNotifierProvider =
    NotifierProvider<GameStateNotifier, GameState>.internal(
      GameStateNotifier.new,
      name: r'gameStateNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$gameStateNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GameStateNotifier = Notifier<GameState>;
String _$timeRemainingHash() => r'2ada4d140a5f0f45d87774a31d0f0c2010dcd5fe';

/// Provider para el tiempo restante (en segundos)
///
/// Copied from [TimeRemaining].
@ProviderFor(TimeRemaining)
final timeRemainingProvider = NotifierProvider<TimeRemaining, int?>.internal(
  TimeRemaining.new,
  name: r'timeRemainingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$timeRemainingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TimeRemaining = Notifier<int?>;
String _$attemptsRemainingHash() => r'd4eaea66c4fb8d3e32a2c29d3ad4f2e57f03c871';

/// Provider para los intentos restantes
///
/// Copied from [AttemptsRemaining].
@ProviderFor(AttemptsRemaining)
final attemptsRemainingProvider =
    NotifierProvider<AttemptsRemaining, int?>.internal(
      AttemptsRemaining.new,
      name: r'attemptsRemainingProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$attemptsRemainingHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AttemptsRemaining = Notifier<int?>;
String _$guessedWordsHash() => r'5b418822d56d9e2ffcd120fb15e3a054a2aa8390';

/// Provider para las palabras adivinadas
///
/// Copied from [GuessedWords].
@ProviderFor(GuessedWords)
final guessedWordsProvider =
    NotifierProvider<GuessedWords, List<WordGuess>>.internal(
      GuessedWords.new,
      name: r'guessedWordsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$guessedWordsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GuessedWords = Notifier<List<WordGuess>>;
String _$gameStartTimeHash() => r'f8a01e57161bd224f36ae86ff2adf90d003a5ad9';

/// Provider para el tiempo de inicio del juego
///
/// Copied from [GameStartTime].
@ProviderFor(GameStartTime)
final gameStartTimeProvider =
    NotifierProvider<GameStartTime, DateTime?>.internal(
      GameStartTime.new,
      name: r'gameStartTimeProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$gameStartTimeHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GameStartTime = Notifier<DateTime?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
