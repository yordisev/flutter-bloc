import 'package:flutter/material.dart';
import 'package:blocs_app/config/config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'presentation/blocs/bloc.dart';

void main() {
  serviceLocaterInit();
  runApp(const BlocsProviders());
}

class BlocsProviders extends StatelessWidget {
  const BlocsProviders({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // BlocProvider(create: (context) => UsernameCubit(), lazy: false),
        // BlocProvider(create: (context) => RouterSimpleCubit()),
        // BlocProvider(create: (context) => CounterCubit()),
        // BlocProvider(create: (context) => ThemeCubit()),
        BlocProvider(create: (context) => getIt<UsernameCubit>()),
        BlocProvider(create: (context) => getIt<RouterSimpleCubit>()),
        BlocProvider(create: (context) => getIt<CounterCubit>()),
        BlocProvider(create: (context) => getIt<ThemeCubit>()),
        BlocProvider(create: (context) => getIt<GuestBloc>()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = context.watch<RouterSimpleCubit>().state;
    final theme = context.watch<ThemeCubit>().state;
    return MaterialApp.router(
      title: 'Flutter BLoC',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: AppTheme(isDarkmode: theme.isDarkmode).getTheme(),
    );
  }
}
