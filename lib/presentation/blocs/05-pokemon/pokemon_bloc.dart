import 'package:blocs_app/presentation/blocs/05-pokemon/pokemon_event.dart';
import 'package:blocs_app/presentation/blocs/05-pokemon/pokemon_state.dart';
import 'package:blocs_app/services/pokemon_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PokemonBloc extends Bloc<PokemonEvent, PokemonState> {
  final PokemonService pokemonService;

  PokemonBloc({required this.pokemonService}) : super(PokemonInitial()) {
    on<PokemonFetched>(_onPokemonFetched);
  }

  Future<void> _onPokemonFetched(
    PokemonFetched event,
    Emitter<PokemonState> emit,
  ) async {
    emit(PokemonLoading());

    try {
      final pokemon = await pokemonService.getPokemon(event.nameOrId);
      emit(PokemonLoaded(pokemon));
    } catch (e) {
      emit(PokemonError(e.toString()));
    }
  }
}
