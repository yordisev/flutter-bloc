import 'package:blocs_app/presentation/blocs/04-guest/guest_event.dart';
import 'package:blocs_app/presentation/blocs/04-guest/guest_state.dart';
import 'package:blocs_app/presentation/blocs/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GuestsScreen extends StatelessWidget {
  const GuestsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Invitados'),
      ),
      body: BlocProvider(
        create: (context) => GuestBloc(),
        child: const GuestView(),
      ),
    );
  }
}

class GuestView extends StatelessWidget {
  const GuestView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    return Column(
      children: [
        // Filtros
        const FilterButtons(),

        // Agregar invitado
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: 'Nombre del invitado',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    context
                        .read<GuestBloc>()
                        .add(GuestAdded(nameController.text));
                    nameController.clear();
                  }
                },
                child: const Text('Agregar'),
              ),
            ],
          ),
        ),

        // Lista de invitados
        const Expanded(child: GuestList()),
      ],
    );
  }
}

class FilterButtons extends StatelessWidget {
  const FilterButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GuestBloc, GuestState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FilterButton(
                text: 'Todos',
                isSelected: state.filter == GuestFilterType.all,
                onPressed: () => context
                    .read<GuestBloc>()
                    .add(GuestFilterChanged(GuestFilterType.all)),
              ),
              FilterButton(
                text: 'Invitados',
                isSelected: state.filter == GuestFilterType.invited,
                onPressed: () => context
                    .read<GuestBloc>()
                    .add(GuestFilterChanged(GuestFilterType.invited)),
              ),
              FilterButton(
                text: 'No Invitados',
                isSelected: state.filter == GuestFilterType.notInvited,
                onPressed: () => context
                    .read<GuestBloc>()
                    .add(GuestFilterChanged(GuestFilterType.notInvited)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class FilterButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onPressed;

  const FilterButton({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey,
      ),
      child: Text(text),
    );
  }
}

class GuestList extends StatelessWidget {
  const GuestList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GuestBloc, GuestState>(
      builder: (context, state) {
        if (state.filteredGuests.isEmpty) {
          return const Center(
            child: Text('No hay invitados que mostrar'),
          );
        }

        return ListView.builder(
          itemCount: state.filteredGuests.length,
          itemBuilder: (context, index) {
            final guest = state.filteredGuests[index];
            return ListTile(
              title: Text(guest.name),
              trailing: Switch(
                value: guest.isInvited,
                onChanged: (value) {
                  context.read<GuestBloc>().add(GuestToggled(guest.id));
                },
              ),
              leading: Icon(
                guest.isInvited ? Icons.check_circle : Icons.circle_outlined,
                color: guest.isInvited ? Colors.green : Colors.grey,
              ),
            );
          },
        );
      },
    );
  }
}
