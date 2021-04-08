import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:io';

import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:just_audio/just_audio.dart';

// ignore: must_be_immutable
class MusicPlayer extends StatefulWidget {
  SongInfo songInfo;
  Function changeTracks;
  final GlobalKey<MusicPlayerState> key;
  MusicPlayer({this.songInfo, this.changeTracks, this.key}) : super(key: key);
  @override
  MusicPlayerState createState() => MusicPlayerState();
}

class MusicPlayerState extends State<MusicPlayer> {
  double minValue = 0.0, maxValue = 0.0, currentValue = 0.0;
  String currentTime = "", endTime = "";
  bool isPlaying = false;

  final AudioPlayer audioPlayer = AudioPlayer();

  void initstate() {
    super.initState();
    setSong(widget.songInfo);
  }

  void dispose() {
    super.dispose();
    audioPlayer?.dispose();
  }

  void setSong(SongInfo songInfo) async {
    widget.songInfo = songInfo;
    await audioPlayer.setUrl(widget.songInfo.uri);
    currentValue = minValue;
    maxValue = audioPlayer.duration.inMilliseconds.toDouble();
    setState(() {
      currentTime = getDuration(currentValue);
      endTime = getDuration(maxValue);
    });
    isPlaying = false;
    changeStatus();
    audioPlayer.positionStream.listen((duration) {
      currentValue = duration.inMilliseconds.toDouble();
      setState(() {
        currentTime = getDuration(currentValue);
      });
    });
  }

  void changeStatus() {
    setState(() {
      isPlaying = !isPlaying;
    });
    isPlaying ? audioPlayer.play() : audioPlayer.pause();
  }

  String getDuration(double value) {
    Duration duration = Duration(milliseconds: value.round());

    return [duration.inMinutes, duration.inSeconds]
        .map((element) => element.remainder(60).toString().padLeft(2, '0'))
        .join(":");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Text(
          'Now Playing',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(5, 40, 5, 0),
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: widget.songInfo.albumArtwork == null
                  ? AssetImage('assets/images/bg_gradient.jpg')
                  : FileImage(File(
                      widget.songInfo.albumArtwork,
                    )),
              radius: 95,
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Text(
                widget.songInfo.title,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
            ),
            Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 15),
                child: Text(
                  widget.songInfo.artist,
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400),
                )),
            Slider(
              inactiveColor: Colors.black12,
              activeColor: Colors.black,
              max: maxValue,
              min: minValue,
              value: currentValue,
              onChanged: (value) {
                currentValue = value;
                audioPlayer.seek(Duration(milliseconds: currentValue.round()));
              },
            ),
            Container(
              transform: Matrix4.translationValues(0, -5, 0),
              margin: EdgeInsets.fromLTRB(5, 0, 5, 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currentTime,
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    endTime,
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Row(
                children: [
                  GestureDetector(
                    child: Icon(
                      Icons.skip_previous,
                      color: Colors.black,
                      size: 55,
                    ),
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      widget.changeTracks(false);
                    },
                  ),
                  GestureDetector(
                    child: Icon(
                      isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_fill_outlined,
                      color: Colors.black,
                      size: 75,
                    ),
                    behavior: HitTestBehavior.translucent,
                    onTap: () {},
                  ),
                  GestureDetector(
                    child: Icon(
                      Icons.skip_next,
                      color: Colors.black,
                      size: 55,
                    ),
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      widget.changeTracks(true);
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
