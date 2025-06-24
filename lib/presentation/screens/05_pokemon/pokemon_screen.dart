import 'package:blocs_app/presentation/blocs/05-pokemon/pokemon_event.dart';
import 'package:blocs_app/presentation/blocs/05-pokemon/pokemon_state.dart';
import 'package:blocs_app/presentation/blocs/bloc.dart';
import 'package:blocs_app/presentation/models/pokemonmodel.dart';
import 'package:blocs_app/services/pokemon_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PokemonScreen extends StatelessWidget {
  const PokemonScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokemon Finder'),
      ),
      body: BlocProvider(
        create: (context) => PokemonBloc(
          pokemonService: context.read<PokemonService>(),
        ),
        child: const PokemonView(),
      ),
    );
  }
}

class PokemonView extends StatelessWidget {
  const PokemonView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: 'Buscar Pokemon por nombre o ID',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  if (searchController.text.isNotEmpty) {
                    context.read<PokemonBloc>().add(
                        PokemonFetched(searchController.text.toLowerCase()));
                  }
                },
                child: const Text('Buscar'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BlocBuilder<PokemonBloc, PokemonState>(
              builder: (context, state) {
                if (state is PokemonInitial) {
                  return const Center(
                    child: Text('Busca un Pokemon para comenzar'),
                  );
                }

                if (state is PokemonLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is PokemonError) {
                  return Center(
                    child: Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (state is PokemonLoaded) {
                  return PokemonCard(pokemon: state.pokemon);
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonCard({Key? key, required this.pokemon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (pokemon.imageUrl.isNotEmpty)
              Image.network(
                pokemon.imageUrl,
                height: 200,
                width: 200,
                fit: BoxFit.contain,
              ),
            const SizedBox(height: 16),
            Text(
              pokemon.name.toUpperCase(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('ID: ${pokemon.id}'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: pokemon.types
                  .map((type) => Chip(
                        label: Text(type),
                        backgroundColor: _getTypeColor(type),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'fire':
        return Colors.red.shade200;
      case 'water':
        return Colors.blue.shade200;
      case 'grass':
        return Colors.green.shade200;
      case 'electric':
        return Colors.yellow.shade200;
      default:
        return Colors.grey.shade200;
    }
  }
}
