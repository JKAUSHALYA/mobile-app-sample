import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:sample_app/src/bloc/player_cubit.dart' as cubit_package;
import 'package:sample_app/src/service/service_media.dart';
import 'package:transparent_image/transparent_image.dart';

final pageController = PageController(initialPage: 0);

class PlayerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Player"),
      ),
      body: _getBody(context),
    );
  }

  Widget _getBody(BuildContext context) {
    var cubit = cubit_package.PlayerCubit();
    cubit.updateImages();
    return BlocBuilder<cubit_package.PlayerCubit, cubit_package.PlayerState>(
      bloc: cubit,
      builder: (context, state) {
        return SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 7,
                child: _getGallery(context, state),
              ),
              Expanded(
                flex: 3,
                child: _getPlayer(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _getGallery(BuildContext context, cubit_package.PlayerState playerState) {
    if (playerState.mediaPages.isEmpty) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    List<Widget> images = [];
    for (var mediaPage in playerState.mediaPages) {
      for (var medium in mediaPage.items) {
        var image = FadeInImage(
          fit: BoxFit.cover,
          placeholder: MemoryImage(kTransparentImage),
          image: ThumbnailProvider(
            mediumId: medium.id,
            mediumType: MediumType.image,
            width: 400,
            height: 400,
          ),
        );
        images.add(image);
      }
    }

    return Container(
      child: PageView(
        controller: pageController,
        children: images,
      ),
    );
  }

  Widget _getPlayer(BuildContext context) {
    return Container(
      child: Player(),
    );
  }
}

class Player extends StatefulWidget {
  const Player({Key? key}) : super(key: key);

  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await player.setUrl("https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ControlButtons(player),
    );
  }
}

class ControlButtons extends StatelessWidget {
  final AudioPlayer player;

  ControlButtons(this.player);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.volume_up),
              onPressed: () {
                _showSliderDialog(
                  context: context,
                  title: "Adjust volume",
                  divisions: 10,
                  min: 0.0,
                  max: 1.0,
                  stream: player.volumeStream,
                  onChanged: player.setVolume,
                );
              },
            ),
            StreamBuilder<SequenceState?>(
              stream: player.sequenceStateStream,
              builder: (context, snapshot) => IconButton(
                icon: Icon(Icons.skip_previous),
                onPressed: player.hasPrevious ? player.seekToPrevious : null,
              ),
            ),
            StreamBuilder<PlayerState>(
              stream: player.playerStateStream,
              builder: (context, snapshot) {
                final playerState = snapshot.data;
                final processingState = playerState?.processingState;
                final playing = playerState?.playing;
                if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
                  return Container(
                    margin: EdgeInsets.all(8.0),
                    width: 64.0,
                    height: 64.0,
                    child: CircularProgressIndicator(),
                  );
                } else if (playing != true) {
                  return IconButton(
                    icon: Icon(Icons.play_arrow),
                    iconSize: 64.0,
                    onPressed: player.play,
                  );
                } else if (processingState != ProcessingState.completed) {
                  return IconButton(
                    icon: Icon(Icons.pause),
                    iconSize: 64.0,
                    onPressed: player.pause,
                  );
                } else {
                  return IconButton(
                    icon: Icon(Icons.replay),
                    iconSize: 64.0,
                    onPressed: () => player.seek(Duration.zero, index: player.effectiveIndices!.first),
                  );
                }
              },
            ),
            StreamBuilder<SequenceState?>(
              stream: player.sequenceStateStream,
              builder: (context, snapshot) => IconButton(
                icon: Icon(Icons.skip_next),
                onPressed: player.hasNext ? player.seekToNext : null,
              ),
            ),
            StreamBuilder<double>(
              stream: player.speedStream,
              builder: (context, snapshot) => IconButton(
                icon: Text("${snapshot.data?.toStringAsFixed(1)}x", style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  _showSliderDialog(
                    context: context,
                    title: "Adjust speed",
                    divisions: 10,
                    min: 0.5,
                    max: 1.5,
                    stream: player.speedStream,
                    onChanged: player.setSpeed,
                  );
                },
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<Duration>(
              stream: player.positionStream,
              builder: (context, snapshot) {
                final duration = snapshot.data;
                final durationInt = duration == null ? 0 : duration.inSeconds;
                var mediaService = MediaService();
                var timeData = mediaService.timeData;
                var page = timeData[durationInt];
                if (page != null && page != 0) {
                  pageController.jumpToPage(page);
                }
                return Text(durationInt.toString());
              },
            ),
          ],
        )
      ],
    );
  }

  void _showSliderDialog({
    required BuildContext context,
    required String title,
    required int divisions,
    required double min,
    required double max,
    String valueSuffix = '',
    required Stream<double> stream,
    required ValueChanged<double> onChanged,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, textAlign: TextAlign.center),
        content: StreamBuilder<double>(
          stream: stream,
          builder: (context, snapshot) => Container(
            height: 100.0,
            child: Column(
              children: [
                Text('${snapshot.data?.toStringAsFixed(1)}$valueSuffix',
                    style: TextStyle(fontFamily: 'Fixed', fontWeight: FontWeight.bold, fontSize: 24.0)),
                Slider(
                  divisions: divisions,
                  min: min,
                  max: max,
                  value: snapshot.data ?? 1.0,
                  onChanged: onChanged,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
