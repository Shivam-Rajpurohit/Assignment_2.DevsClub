import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pokemon.dart';
import 'repo_provider.dart';

class PokemonListNotifier extends AsyncNotifier<List<Pokemon>> {
  static const _pageSize = 20;

  int _offset = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  Future<List<Pokemon>> build() async {
    _offset = 0;
    _hasMore = true;
    return ref
        .read(pokeRepoProvider)
        .fetchPokemonListWithDetails(limit: _pageSize, offset: 0);
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    try {
      final next = await ref
          .read(pokeRepoProvider)
          .fetchPokemonListWithDetails(
        limit: _pageSize,
        offset: _offset + _pageSize,
      );

      if (next.length < _pageSize) {
        _hasMore = false;
      }

      _offset += _pageSize;

      state = AsyncData([...state.value ?? [], ...next]);
    } catch (e) {
      // nothing
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    _offset = 0;
    _hasMore = true;
    state = await AsyncValue.guard(
          () => ref
          .read(pokeRepoProvider)
          .fetchPokemonListWithDetails(limit: _pageSize, offset: 0),
    );
  }

  bool get hasMore => _hasMore;
}

final pokemonListProvider =
AsyncNotifierProvider<PokemonListNotifier, List<Pokemon>>(
  PokemonListNotifier.new,
);