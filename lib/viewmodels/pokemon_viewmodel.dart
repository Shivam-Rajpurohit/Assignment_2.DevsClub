import '../models/pokemon.dart';
import '../repos/pokemon_repository.dart';

class PokemonViewModel {
  final PokeRepo _repository = PokeRepo();

  List<Pokemon> _pokemonList = [];
  Pokemon? _selectedPokemon;
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<Pokemon> get pokemonList => _pokemonList;
  Pokemon? get selectedPokemon => _selectedPokemon;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool get hasError => _errorMessage != null;
  bool get hasData => _pokemonList.isNotEmpty;

  Future<void> loadPokemonList({int limit = 20}) async {
    _isLoading = true;
    _errorMessage = null;

    try {
      final entries = await _repository.fetchPokemonList(limit: limit);

      List<Future<Pokemon>> futures = entries.map((entry) {
        return _repository.fetchPokemonDetail(entry['url']);
      }).toList();

      _pokemonList = await Future.wait(futures);
      _isLoading = false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
    }
  }

  Future<void> searchPokemon(String query) async {
    _searchQuery = query.trim();

    if (_searchQuery.isEmpty) {
      _pokemonList = [];
      return;
    }
    _isLoading = true;
    _errorMessage = null;

    try {
      _pokemonList = await _repository.searchPokemon(_searchQuery);
      _isLoading = false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
    }
  }

  void selectPokemon(Pokemon pokemon) {
    _selectedPokemon = pokemon;
  }

  void clearSelection() {
    _selectedPokemon = null;
  }

  void dispose() {
    _repository.dispose();
  }
}