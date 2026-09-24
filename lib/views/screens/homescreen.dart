import 'package:flutter/material.dart';
import '../../viewmodels/pokemon_viewmodel.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/error_display.dart';
import '../widgets/empty_display.dart';
import 'details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PokemonViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = PokemonViewModel();
    _loadData();
  }

  Future<void> _loadData() async {
    await _viewModel.loadPokemonList();
    setState(() {});
  }

  Future<void> _search(String query) async {
    await _viewModel.searchPokemon(query);
    setState(() {});
  }

  Future<void> _refresh() async {
    await _viewModel.loadPokemonList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or ID',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _search('');
                  },
                ),
              ),
              onChanged: _search,
            ),
          ),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_viewModel.isLoading) {
      return const ShimmerLoading();
    }

    if (_viewModel.hasError) {
      return ErrorDisplay(
        message: _viewModel.errorMessage!,
        onRetry: _refresh,
      );
    }

    if (!_viewModel.hasData) {
      return const EmptyDisplay();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _viewModel.pokemonList.length,
      itemBuilder: (context, index) {
        final pokemon = _viewModel.pokemonList[index];
        return PokemonCard(
          pokemon: pokemon,
          onTap: () {
            _viewModel.selectPokemon(pokemon);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(pokemon: pokemon),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}