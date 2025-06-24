abstract class PokemonEvent {}

class PokemonFetched extends PokemonEvent {
  final String nameOrId;
  PokemonFetched(this.nameOrId);
}
