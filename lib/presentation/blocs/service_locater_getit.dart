import 'package:blocs_app/config/router/app_router.dart';
import 'package:get_it/get_it.dart';

import 'bloc.dart';

GetIt getIt = GetIt.instance;

void serviceLocaterInit() {
  getIt.registerSingleton(UsernameCubit());
  getIt.registerSingleton(RouterSimpleCubit());
  getIt.registerSingleton(CounterCubit());
  getIt.registerSingleton(ThemeCubit());
  getIt.registerSingleton(GuestBloc());
}
