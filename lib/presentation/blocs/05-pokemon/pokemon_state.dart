import 'package:blocs_app/presentation/models/pokemonmodel.dart';

abstract class PokemonState {}

class PokemonInitial extends PokemonState {}

class PokemonLoading extends PokemonState {}

class PokemonLoaded extends PokemonState {
  final Pokemon pokemon;
  PokemonLoaded(this.pokemon);
}

class PokemonError extends PokemonState {
  final String message;
  PokemonError(this.message);
}
