import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';
import '../utils/constants.dart';

class PokeRepo {
  final http.Client _client = http.Client();
  PokeRepo();
  void dispose() {
    _client.close();
  }

  Future<List<Map<String, dynamic>>> fetchPokemonList({int limit = 20}) async {
    try {
      final response = await _client
          .get(Uri.parse('${AppConstants.baseUrl}/pokemon?limit=$limit'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['results']);
      } else {
        throw Exception('Failed to load Pokemon list: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Pokemon> fetchPokemonDetail(String url) async {
    try {
      final response = await _client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Pokemon.fromJson(data);
      } else {
        throw Exception('Failed to load Pokemon detail: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Pokemon> fetchPokemonByIdOrName(String query) async {
    try {
      final response = await _client
          .get(Uri.parse('${AppConstants.baseUrl}/pokemon/${query.toLowerCase()}'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Pokemon.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Pokemon not found');
      } else {
        throw Exception('Failed to load Pokemon: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<Pokemon>> searchPokemon(String query) async {
    if (query.isEmpty) return [];
    try {
      final pokemon = await fetchPokemonByIdOrName(query);
      return [pokemon];
    } catch (e) {
      try {
        final allPokemon = await fetchPokemonList(limit: 1000);
        final matching = allPokemon
            .where((entry) => entry['name'].contains(query.toLowerCase()))
            .take(20)
            .toList();
        if (matching.isEmpty) return [];

        List<Future<Pokemon>> futures = matching.map((entry) {
          return fetchPokemonDetail(entry['url']);
        }).toList();
        return await Future.wait(futures);
      } catch (e) {
        throw Exception('Search failed: $e');
      }
    }
  }
}