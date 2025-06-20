import 'package:blocs_app/presentation/models/guestmodel.dart';

enum GuestFilterType { all, invited, notInvited }

class GuestState {
  final List<Guest> guests;
  final GuestFilterType filter;

  GuestState({
    this.guests = const [],
    this.filter = GuestFilterType.all,
  });

  List<Guest> get filteredGuests {
    switch (filter) {
      case GuestFilterType.all:
        return guests;
      case GuestFilterType.invited:
        return guests.where((guest) => guest.isInvited).toList();
      case GuestFilterType.notInvited:
        return guests.where((guest) => !guest.isInvited).toList();
    }
  }

  GuestState copyWith({
    List<Guest>? guests,
    GuestFilterType? filter,
  }) {
    return GuestState(
      guests: guests ?? this.guests,
      filter: filter ?? this.filter,
    );
  }

  @override
  String toString() => 'GuestState(guests: ${guests.length}, filter: $filter)';
}
