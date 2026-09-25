import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repos/pokemon_repository.dart';

final pokeRepoProvider = Provider<PokeRepo>((ref) {
  final repo = PokeRepo();
  ref.onDispose(repo.dispose);
  return repo;
});
