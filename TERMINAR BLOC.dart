// ========== GUEST BLOC - ESTADO COMPLEJO ==========


// guest_bloc/guest_state.dart


// guest_bloc/guest_event.dart


// guest_bloc/guest_bloc.dart


// screens/guest_screen.dart


// ========== POKEMON BLOC ==========

// models/pokemon.dart
class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;

  Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: json['id'],
      name: json['name'],
      imageUrl: json['sprites']['front_default'] ?? '',
      types: (json['types'] as List)
          .map((type) => type['type']['name'] as String)
          .toList(),
    );
  }
}

// services/pokemon_service.dart
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

// pokemon_bloc/pokemon_state.dart
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

// pokemon_bloc/pokemon_event.dart
abstract class PokemonEvent {}

class PokemonFetched extends PokemonEvent {
  final String nameOrId;
  PokemonFetched(this.nameOrId);
}

// pokemon_bloc/pokemon_bloc.dart
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

// screens/pokemon_screen.dart
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
                    context.read<PokemonBloc>()
                        .add(PokemonFetched(searchController.text.toLowerCase()));
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

// ========== GEOLOCATION & HISTORIC LOCATION BLOC ==========

// models/location.dart
class LocationData {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  @override
  String toString() =>
      'LocationData(lat: $latitude, lng: $longitude, time: $timestamp)';
}

// services/geolocation_service.dart
import 'package:geolocator/geolocator.dart';

class GeolocationService {
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<LocationData?> getCurrentLocation() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return null;

    try {
      final position = await Geolocator.getCurrentPosition();
      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  Stream<LocationData> getLocationStream() async* {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    await for (final position in Geolocator.getPositionStream()) {
      yield LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
      );
    }
  }
}

// geolocation_bloc/geolocation_state.dart
abstract class GeolocationState {}

class GeolocationInitial extends GeolocationState {}

class GeolocationLoading extends GeolocationState {}

class GeolocationLoaded extends GeolocationState {
  final LocationData location;
  GeolocationLoaded(this.location);
}

class GeolocationError extends GeolocationState {
  final String message;
  GeolocationError(this.message);
}

// geolocation_bloc/geolocation_event.dart
abstract class GeolocationEvent {}

class GeolocationRequested extends GeolocationEvent {}

class GeolocationStreamStarted extends GeolocationEvent {}

class GeolocationUpdated extends GeolocationEvent {
  final LocationData location;
  GeolocationUpdated(this.location);
}

// geolocation_bloc/geolocation_bloc.dart
class GeolocationBloc extends Bloc<GeolocationEvent, GeolocationState> {
  final GeolocationService geolocationService;
  StreamSubscription<LocationData>? _locationSubscription;

  GeolocationBloc({required this.geolocationService}) 
      : super(GeolocationInitial()) {
    on<GeolocationRequested>(_onLocationRequested);
    on<GeolocationStreamStarted>(_onLocationStreamStarted);
    on<GeolocationUpdated>(_onLocationUpdated);
  }

  Future<void> _onLocationRequested(
    GeolocationRequested event,
    Emitter<GeolocationState> emit,
  ) async {
    emit(GeolocationLoading());
    
    try {
      final location = await geolocationService.getCurrentLocation();
      if (location != null) {
        emit(GeolocationLoaded(location));
      } else {
        emit(GeolocationError('No se pudo obtener la ubicación'));
      }
    } catch (e) {
      emit(GeolocationError(e.toString()));
    }
  }

  Future<void> _onLocationStreamStarted(
    GeolocationStreamStarted event,
    Emitter<GeolocationState> emit,
  ) async {
    emit(GeolocationLoading());
    
    _locationSubscription = geolocationService.getLocationStream().listen(
      (location) => add(GeolocationUpdated(location)),
    );
  }

  void _onLocationUpdated(
    GeolocationUpdated event,
    Emitter<GeolocationState> emit,
  ) {
    emit(GeolocationLoaded(event.location));
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    return super.close();
  }
}

// historic_locations_bloc/historic_locations_state.dart
class HistoricLocationsState {
  final List<LocationData> locations;
  final bool isWatching;

  HistoricLocationsState({
    this.locations = const [],
    this.isWatching = false,
  });

  HistoricLocationsState copyWith({
    List<LocationData>? locations,
    bool? isWatching,
  }) {
    return HistoricLocationsState(
      locations: locations ?? this.locations,
      isWatching: isWatching ?? this.isWatching,
    );
  }
}

// historic_locations_bloc/historic_locations_event.dart
abstract class HistoricLocationsEvent {}

class HistoricLocationAdded extends HistoricLocationsEvent {
  final LocationData location;
  HistoricLocationAdded(this.location);
}

class HistoricLocationsStartWatching extends HistoricLocationsEvent {}

class HistoricLocationsStopWatching extends HistoricLocationsEvent {}

class HistoricLocationsClear extends HistoricLocationsEvent {}

// historic_locations_bloc/historic_locations_bloc.dart
class HistoricLocationsBloc 
    extends Bloc<HistoricLocationsEvent, HistoricLocationsState> {
  final GeolocationBloc geolocationBloc;
  StreamSubscription<GeolocationState>? _geolocationSubscription;

  HistoricLocationsBloc({required this.geolocationBloc}) 
      : super(HistoricLocationsState()) {
    on<HistoricLocationAdded>(_onLocationAdded);
    on<HistoricLocationsStartWatching>(_onStartWatching);
    on<HistoricLocationsStopWatching>(_onStopWatching);
    on<HistoricLocationsClear>(_onClearLocations);

    // Escuchar cambios en GeolocationBloc
    _geolocationSubscription = geolocationBloc.stream.listen((geolocationState) {
      if (geolocationState is GeolocationLoaded && state.isWatching) {
        add(HistoricLocationAdded(geolocationState.location));
      }
    });
  }

  void _onLocationAdded(
    HistoricLocationAdded event,
    Emitter<HistoricLocationsState> emit,
  ) {
    final updatedLocations = List<LocationData>.from(state.locations)
      ..add(event.location);
    
    emit(state.copyWith(locations: updatedLocations));
  }

  void _onStartWatching(
    HistoricLocationsStartWatching event,
    Emitter<HistoricLocationsState> emit,
  ) {
    emit(state.copyWith(isWatching: true));
    geolocationBloc.add(GeolocationStreamStarted());
  }

  void _onStopWatching(
    HistoricLocationsStopWatching event,
    Emitter<HistoricLocationsState> emit,
  ) {
    emit(state.copyWith(isWatching: false));
  }

  void _onClearLocations(
    HistoricLocationsClear event,
    Emitter<HistoricLocationsState> emit,
  ) {
    emit(state.copyWith(locations: []));
  }

  @override
  Future<void> close() {
    _geolocationSubscription?.cancel();
    return super.close();
  }
}

// screens/location_screen.dart
class LocationScreen extends StatelessWidget {
  const LocationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicaciones'),
      ),
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => GeolocationBloc(
              geolocationService: context.read<GeolocationService>(),
            ),
          ),
          BlocProvider(
            create: (context) => HistoricLocationsBloc(
              geolocationBloc: context.read<GeolocationBloc>(),
            ),
          ),
        ],
        child: const LocationView(),
      ),
    );
  }
}

class LocationView extends StatelessWidget {
  const LocationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Controles
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  context.read<GeolocationBloc>().add(GeolocationRequested());
                },
                child: const Text('Obtener Ubicación'),
              ),
              BlocBuilder<HistoricLocationsBloc, HistoricLocationsState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: () {
                      if (state.isWatching) {
                        context.read<HistoricLocationsBloc>()
                            .add(HistoricLocationsStopWatching());
                      } else {
                        context.read<HistoricLocationsBloc>()
                            .add(HistoricLocationsStartWatching());
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: state.isWatching ? Colors.red : Colors.green,
                    ),
                    child: Text(state.isWatching ? 'Detener' : 'Iniciar'),
                  );
                },
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<HistoricLocationsBloc>()
                      .add(HistoricLocationsClear());
                },
                child: const Text('Limpiar'),
              ),
            ],
          ),
        ),
        
        // Estado actual
        BlocBuilder<GeolocationBloc, GeolocationState>(
          builder: (context, state) {
            if (state is GeolocationLoading) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              );
            }
            
            if (state is GeolocationError) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: ${state.message}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            
            if (state is GeolocationLoaded) {
              return Card(
                margin: const EdgeInsets.all(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ubicación Actual:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Latitud: ${state.location.latitude}'),
                      Text('Longitud: ${state.location.longitude}'),
                      Text('Hora: ${state.location.timestamp}'),
                    ],
                  ),
                ),
              );
            }
            
            return const SizedBox();
          },
        ),
        
        // Lista de ubicaciones históricas
        const Expanded(child: HistoricLocationsList()),
      ],
    );
  }
}

class HistoricLocationsList extends StatelessWidget {
  const HistoricLocationsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoricLocationsBloc, HistoricLocationsState>(
      builder: (context, state) {
        if (state.locations.isEmpty) {
          return const Center(
            child: Text('No hay ubicaciones registradas'),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Historial de Ubicaciones (${state.locations.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: state.locations.length,
                itemBuilder: (context, index) {
                  final location = state.locations[index];
                  return ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(
                      '${location.latitude.toStringAsFixed(6)}, '
                      '${location.longitude.toStringAsFixed(6)}',
                    ),
                    subtitle: Text(
                      location.timestamp.toString(),
                    ),
                    trailing: Text('#${index + 1}'),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// main.dart - Configuración de dependencias
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => PokemonService()),
        RepositoryProvider(create: (context) => GeolocationService()),
      ],
      child: MaterialApp(
        title: 'Flutter BLoC Examples',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter BLoC Examples'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GuestScreen()),
                );
              },
              child: const Text('Guest Management'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PokemonScreen()),
                );
              },
              child: const Text('Pokemon Finder'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LocationScreen()),
                );
              },
              child: const Text('Location Tracker'),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== PUBSPEC.YAML DEPENDENCIES ==========
/*
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.3
  bloc: ^8.1.2
  http: ^1.1.0
  geolocator: ^10.1.0
  uuid: ^4.2.1
  get_it: ^7.6.4

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
*/

// ========== CONFIGURACIÓN CON GET_IT (Service Locator) ==========

// config/service_locator.dart
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Servicios
  getIt.registerLazySingleton<PokemonService>(() => PokemonService());
  getIt.registerLazySingleton<GeolocationService>(() => GeolocationService());
  
  // BLoCs que necesitan ser singleton
  getIt.registerLazySingleton<GeolocationBloc>(
    () => GeolocationBloc(geolocationService: getIt<GeolocationService>()),
  );
  
  getIt.registerFactory<HistoricLocationsBloc>(
    () => HistoricLocationsBloc(geolocationBloc: getIt<GeolocationBloc>()),
  );
  
  getIt.registerFactory<PokemonBloc>(
    () => PokemonBloc(pokemonService: getIt<PokemonService>()),
  );
  
  getIt.registerFactory<GuestBloc>(() => GuestBloc());
}

// main.dart actualizado con Get_It
void main() {
  setupServiceLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter BLoC Examples',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
    );
  }
}

// Actualización de screens para usar Get_It

// screens/guest_screen.dart (actualizado)
class GuestScreen extends StatelessWidget {
  const GuestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Invitados'),
      ),
      body: BlocProvider(
        create: (context) => getIt<GuestBloc>(),
        child: const GuestView(),
      ),
    );
  }
}

// screens/pokemon_screen.dart (actualizado)
class PokemonScreen extends StatelessWidget {
  const PokemonScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokemon Finder'),
      ),
      body: BlocProvider(
        create: (context) => getIt<PokemonBloc>(),
        child: const PokemonView(),
      ),
    );
  }
}

// screens/location_screen.dart (actualizado)
class LocationScreen extends StatelessWidget {
  const LocationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicaciones'),
      ),
      body: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: getIt<GeolocationBloc>()),
          BlocProvider(create: (context) => getIt<HistoricLocationsBloc>()),
        ],
        child: const LocationView(),
      ),
    );
  }
}

// ========== EJEMPLOS DE USO Y EXPLICACIONES ==========

/*
EXPLICACIÓN DE LA IMPLEMENTACIÓN:

1. GUEST BLOC - ESTADO COMPLEJO:
   - Maneja una lista de invitados con filtros
   - Eventos: Cambiar filtro, agregar invitado, cambiar estado
   - Estados complejos con múltiples propiedades

2. POKEMON BLOC:
   - Integra servicio HTTP para obtener datos de API
   - Maneja estados de carga, éxito y error
   - Inyección de dependencias del servicio

3. GEOLOCATION BLOC:
   - Maneja permisos y ubicación del dispositivo
   - Stream de ubicaciones en tiempo real
   - Estados para diferentes escenarios

4. HISTORIC LOCATIONS BLOC:
   - Comunicación entre BLoCs
   - Escucha cambios de GeolocationBloc
   - Mantiene historial de ubicaciones

5. SERVICE LOCATOR (GET_IT):
   - Inyección de dependencias centralizada
   - Singleton para servicios compartidos
   - Factory para BLoCs que se crean bajo demanda

PATRONES IMPLEMENTADOS:
- Repository Pattern (servicios)
- Observer Pattern (comunicación entre BLoCs)
- Factory Pattern (creación de BLoCs)
- Singleton Pattern (servicios compartidos)

COMUNICACIÓN ENTRE BLOCS:
El HistoricLocationsBloc escucha los cambios del GeolocationBloc:

```dart
_geolocationSubscription = geolocationBloc.stream.listen((geolocationState) {
  if (geolocationState is GeolocationLoaded && state.isWatching) {
    add(HistoricLocationAdded(geolocationState.location));
  }
});
```

MANEJO DE PERMISOS:
La aplicación maneja permisos de ubicación automáticamente:
- Verifica si el servicio está habilitado
- Solicita permisos si no están otorgados
- Maneja casos de permisos denegados

ESTADOS COMPLEJOS:
Los BLoCs manejan estados complejos con múltiples propiedades:
- GuestState: lista de invitados + filtro actual
- HistoricLocationsState: lista de ubicaciones + estado de seguimiento

INYECCIÓN DE DEPENDENCIAS:
Se usa Get_It para:
- Registrar servicios como singleton
- Crear BLoCs con sus dependencias
- Facilitar testing y mantenimiento

MANEJO DE STREAMS:
Se implementan streams para:
- Ubicación en tiempo real
- Comunicación entre BLoCs
- Cancelación automática en dispose
*/

// ========== TESTING EXAMPLES ==========

// test/guest_bloc_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

void main() {
  group('GuestBloc', () {
    late GuestBloc guestBloc;

    setUp(() {
      guestBloc = GuestBloc();
    });

    tearDown(() {
      guestBloc.close();
    });

    test('initial state is empty', () {
      expect(guestBloc.state.guests, isEmpty);
      expect(guestBloc.state.filter, GuestFilterType.all);
    });

    blocTest<GuestBloc, GuestState>(
      'emits new state when guest is added',
      build: () => guestBloc,
      act: (bloc) => bloc.add(GuestAdded('John Doe')),
      expect: () => [
        isA<GuestState>().having(
          (state) => state.guests.length,
          'guests length',
          1,
        ),
      ],
    );

    blocTest<GuestBloc, GuestState>(
      'emits new state when filter is changed',
      build: () => guestBloc,
      act: (bloc) => bloc.add(GuestFilterChanged(GuestFilterType.invited)),
      expect: () => [
        isA<GuestState>().having(
          (state) => state.filter,
          'filter',
          GuestFilterType.invited,
        ),
      ],
    );

    blocTest<GuestBloc, GuestState>(
      'toggles guest invitation status',
      build: () => guestBloc,
      seed: () => GuestState(
        guests: [
          Guest(id: '1', name: 'John', isInvited: false),
        ],
      ),
      act: (bloc) => bloc.add(GuestToggled('1')),
      expect: () => [
        isA<GuestState>().having(
          (state) => state.guests.first.isInvited,
          'first guest isInvited',
          true,
        ),
      ],
    );
  });
}

// test/pokemon_bloc_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPokemonService extends Mock implements PokemonService {}

void main() {
  group('PokemonBloc', () {
    late PokemonService pokemonService;
    late PokemonBloc pokemonBloc;

    setUp(() {
      pokemonService = MockPokemonService();
      pokemonBloc = PokemonBloc(pokemonService: pokemonService);
    });

    tearDown(() {
      pokemonBloc.close();
    });

    test('initial state is PokemonInitial', () {
      expect(pokemonBloc.state, isA<PokemonInitial>());
    });

    blocTest<PokemonBloc, PokemonState>(
      'emits loading then loaded when pokemon is fetched successfully',
      build: () => pokemonBloc,
      setUp: () {
        when(() => pokemonService.getPokemon('pikachu'))
            .thenAnswer((_) async => Pokemon(
                  id: 25,
                  name: 'pikachu',
                  imageUrl: 'url',
                  types: ['electric'],
                ));
      },
      act: (bloc) => bloc.add(PokemonFetched('pikachu')),
      expect: () => [
        isA<PokemonLoading>(),
        isA<PokemonLoaded>().having(
          (state) => state.pokemon.name,
          'pokemon name',
          'pikachu',
        ),
      ],
    );

    blocTest<PokemonBloc, PokemonState>(
      'emits loading then error when pokemon fetch fails',
      build: () => pokemonBloc,
      setUp: () {
        when(() => pokemonService.getPokemon('invalid'))
            .thenThrow(Exception('Pokemon not found'));
      },
      act: (bloc) => bloc.add(PokemonFetched('invalid')),
      expect: () => [
        isA<PokemonLoading>(),
        isA<PokemonError>(),
      ],
    );
  });
}