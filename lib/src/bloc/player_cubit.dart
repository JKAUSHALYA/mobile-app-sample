import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:photo_gallery/photo_gallery.dart';

part 'player_state.dart';

class PlayerCubit extends Cubit<PlayerState> {
  PlayerCubit() : super(PlayerInitial());

  Future<void> updateImages() async {

    final List<Album> imageAlbums = await PhotoGallery.listAlbums(
      mediumType: MediumType.image,
    );

    List<MediaPage> mediaPages = [];
    for (var imageAlbum in imageAlbums) {
      final MediaPage imagePage = await imageAlbum.listMedia();
      mediaPages.add(imagePage);
    }

    var newState = PlayerWithMediaPages(mediaPages);
    emit(newState);
  }

  void initializePlayer() {


  }
}
