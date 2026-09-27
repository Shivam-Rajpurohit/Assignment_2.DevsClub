import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import 'repo_provider.dart';

class SearchNotifier extends AsyncNotifier<List<Pokemon>> {
  @override
  Future<List<Pokemon>> build() async => [];

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = AsyncData([]);
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(pokeRepoProvider).searchPokemon(query),
    );
  }
}

final searchProvider = AsyncNotifierProvider<SearchNotifier, List<Pokemon>>(
  SearchNotifier.new,
);
