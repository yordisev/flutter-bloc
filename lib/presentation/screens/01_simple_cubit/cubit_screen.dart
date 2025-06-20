import 'package:blocs_app/config/config.dart';
import 'package:blocs_app/presentation/blocs/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CubitScreen extends StatelessWidget {
  const CubitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final username = context.watch<UsernameCubit>(); //primera forma de hacerlo
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cubit'),
      ),
      body: Column(
        children: [
          Center(
            child: Text('${username.state}'), //primera forma de hacerlo
          ),
          Center(
            child: BlocBuilder<UsernameCubit, String>( //segunda forma de hacerlo
                buildWhen: (previous, current) => previous != current,
                builder: (context, username) {
                  return Text(username);
                }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // final usernamecubit = context.read<UsernameCubit>();
          username.setUsername(RandomGenerator.getRandomName()); //primera forma de hacerlo
          context
              .read<UsernameCubit>()
              .setUsername(RandomGenerator.getRandomName());//segunda forma de hacerlo
        },
        child: Icon(Icons.refresh_rounded),
      ),
    );
  }
}
