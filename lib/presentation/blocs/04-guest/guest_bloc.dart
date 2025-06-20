import 'package:blocs_app/presentation/models/guestmodel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'guest_event.dart';
import 'guest_state.dart';

class GuestBloc extends Bloc<GuestEvent, GuestState> {
  GuestBloc() : super(GuestState()) {
    on<GuestFilterChanged>(_onFilterChanged);
    on<GuestAdded>(_onGuestAdded);
    on<GuestToggled>(_onGuestToggled);
  }

  void _onFilterChanged(GuestFilterChanged event, Emitter<GuestState> emit) {
    emit(state.copyWith(filter: event.filter));
  }

  void _onGuestAdded(GuestAdded event, Emitter<GuestState> emit) {
    final newGuest = Guest(
      id: const Uuid().v4(),
      name: event.name,
    );

    final updatedGuests = List<Guest>.from(state.guests)..add(newGuest);
    emit(state.copyWith(guests: updatedGuests));
  }

  void _onGuestToggled(GuestToggled event, Emitter<GuestState> emit) {
    final updatedGuests = state.guests.map((guest) {
      if (guest.id == event.guestId) {
        return guest.copyWith(isInvited: !guest.isInvited);
      }
      return guest;
    }).toList();

    emit(state.copyWith(guests: updatedGuests));
  }
}
