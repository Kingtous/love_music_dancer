import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:duration/duration.dart';

class Lyric {
  Duration duration;
  String lyrics;

  Lyric(this.duration, this.lyrics);
}

class AudioPlayerPage extends StatefulWidget {
  const AudioPlayerPage({Key? key}) : super(key: key);

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  late AudioPlayer player;

  final url =
      "https://webfs.ali.kugou.com/202211161446/dbcde2e7231aee1d4e5412421d8ce930/KGTX/CLTX001/3163e562c700c56296bc1383bf43c109.mp3";
  final List<Lyric> lyrics = List.empty(growable: true);
  var playIndex = 0;
  bool startPlaying = false;
  final offset = 3500;

  @override
  void initState() {
    super.initState();
    player = AudioPlayer();
    Future.delayed(Duration.zero, () async {
      player.onPositionChanged.listen(onPositionChanged);
      await loadLyrics();
    });
  }

  Future<void> loadLyrics() async {
    String data = await rootBundle.loadString("assets/小城夏天.lrc");
    final lines = data.split("\n");
    for (final line in lines) {
      final bean = line.split("]");
      final time = parseTime("00:${bean[0].substring(1)}");
      final lyricString = bean[1];
      lyrics.add(Lyric(time, lyricString));
    }
    setState(() {});
  }

  @override
  void dispose() {
    player.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firstLyricsIndex = max(0, playIndex - 2);
    final lastLyricsIndex = min(lyrics.length, firstLyricsIndex + 5);
    final subLyrics = lyrics.sublist(firstLyricsIndex, lastLyricsIndex);
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: subLyrics
              .map((e) => Padding(
                    key: ValueKey(firstLyricsIndex + subLyrics.indexOf(e)),
                    padding: const EdgeInsets.all(8.0),
                    child: FadeIn(
                      child: Center(
                        child: Text(
                          e.lyrics,
                          style: TextStyle(
                              fontSize: firstLyricsIndex + subLyrics.indexOf(e) ==
                                      playIndex
                                  ? 20
                                  : 14,
                              color: firstLyricsIndex + subLyrics.indexOf(e) ==
                                      playIndex
                                  ? Colors.white70
                                  : Colors.white38),
                        ),
                      ),
                    ),
                  ))
              .toList(growable: false),
        ),
        startPlaying
            ? const Offstage()
            : GestureDetector(
                onTap: () {
                  setState(() {
                    startPlaying = true;
                    player.play(UrlSource(url));
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.play_arrow_outlined,
                    color: Colors.pinkAccent[100],
                    size: 50,
                  ),
                ),
              )
      ],
    );
  }

  void onPositionChanged(Duration event) {
    if ((lyrics[playIndex].duration.inMilliseconds + offset) -
            event.inMilliseconds <
        0) {
      setState(() {
        if (playIndex < lyrics.length - 1) {
          playIndex += 1;
        }
      });
    }
  }
}
