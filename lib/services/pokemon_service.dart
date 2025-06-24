import 'package:blocs_app/presentation/models/pokemonmodel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PokemonService {
  static const String _baseUrl = 'https://pokeapi.co/api/v2';

  Future<Pokemon> getPokemon(String nameOrId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/pokemon/$nameOrId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Pokemon.fromJson(data);
      } else {
        throw Exception('Pokemon no encontrado');
      }
    } catch (e) {
      throw Exception('Error al obtener Pokemon: $e');
    }
  }
}
