import 'guest_state.dart';

abstract class GuestEvent {}

class GuestFilterChanged extends GuestEvent {
  final GuestFilterType filter;
  GuestFilterChanged(this.filter);
}

class GuestAdded extends GuestEvent {
  final String name;
  GuestAdded(this.name);
}

class GuestToggled extends GuestEvent {
  final String guestId;
  GuestToggled(this.guestId);
}
