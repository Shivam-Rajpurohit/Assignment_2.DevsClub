import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/pokemon.dart';
import '../../providers/pokemon_list_provider.dart';
import '../../providers/search_provider.dart';
import '../../providers/selected_pokemon_provider.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/error_display.dart';
import '../widgets/empty_display.dart';
import 'details_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(pokemonListProvider.notifier).loadMore();
    }
  }

  void _search(String query) {
    ref.read(searchProvider.notifier).search(query);
  }

  Future<void> _refresh() {
    return ref.read(pokemonListProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or ID',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _search('');
                  },
                ),
              ),
              onChanged: _search,
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final listAsync = ref.watch(pokemonListProvider);
    final searchAsync = ref.watch(searchProvider);

    final searchResults = searchAsync.value ?? const [];
    if (searchResults.isNotEmpty) {
      return _buildSearchList(searchResults);
    }

    return listAsync.when(
      loading: () => const ShimmerLoading(),
      error: (e, _) => ErrorDisplay(message: e.toString(), onRetry: _refresh),
      data: (items) {
        if (items.isEmpty) return const EmptyDisplay();
        return _buildDefaultList(items);
      },
    );
  }

  Widget _buildDefaultList(List<Pokemon> items) {
    final hasMore = ref.read(pokemonListProvider.notifier).hasMore;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      itemCount: items.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == items.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return _buildCard(items[index]);
      },
    );
  }

  Widget _buildSearchList(List<Pokemon> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildCard(items[index]),
    );
  }

  Widget _buildCard(Pokemon pokemon) {
    return PokemonCard(
      pokemon: pokemon,
      onTap: () {
        ref.read(selectedPokemonProvider.notifier).select(pokemon);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(pokemon: pokemon),
          ),
        );
      },
    );
  }
}