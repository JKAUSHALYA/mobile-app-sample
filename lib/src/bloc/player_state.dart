part of 'player_cubit.dart';

@immutable
abstract class PlayerState {
  final List<MediaPage> mediaPages;
  PlayerState(this.mediaPages);
}

class PlayerInitial extends PlayerState {
  PlayerInitial() : super([]);
}

class PlayerWithMediaPages extends PlayerState {
  PlayerWithMediaPages(List<MediaPage> mediaPages) : super(mediaPages);
}
