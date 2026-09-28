import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pokemon.dart';
import 'repo_provider.dart';

class PokemonListNotifier extends AsyncNotifier<List<Pokemon>> {
  @override
  Future<List<Pokemon>> build() async {
    return ref.read(pokeRepoProvider).fetchPokemonListWithDetails(limit: 20);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(pokeRepoProvider).fetchPokemonListWithDetails(limit: 20),
    );
  }
}

final pokemonListProvider =
    AsyncNotifierProvider<PokemonListNotifier, List<Pokemon>>(
      PokemonListNotifier.new,
    );
