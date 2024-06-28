import 'dart:io';

import 'package:midi_util/midi_util.dart';

class MidifileConvert {
  static String saveMidiFile(List notesList, String path) {
    // [
    //   [0, "on", 51],
    //   [333, "on", 49]
    // ];
    List notes = [];
    for (List subnotes in notesList) {
      notes.add(subnotes.last);
    }
    print('saveMidiFile data=$notes');
    // notes = [60, 62, 64, 65, 67, 69, 71, 72]; //  # MIDI note number
    var track = 0;
    var channel = 0;
    var time = 0; //    # In beats
    var duration = 0.2; //    # In beats
    var tempo = 120; //   # In BPM
    var volume = 100; //  # 0-127, as per the MIDI standard

    MIDIFile myMIDI = MIDIFile(numTracks: 2);
    myMIDI.addTempo(
      track: track,
      time: time,
      tempo: tempo,
    );
    myMIDI.addKeySignature(
        track: track,
        time: time,
        no_of_accidentals: 0,
        accidental_mode: AccidentalMode.MAJOR,
        accidental_type: AccidentalType.SHARPS);

    List.generate(notes.length, (i) {
      // duration = (i == 0 ? 1 : notesList[i][0] - notesList[i - 1][0]) * 0.001;
      // if (duration == 0) {
      //   duration = 0.1;
      // }
      print('duration==$duration');
      myMIDI.addNote(
          track: track,
          channel: channel,
          pitch: notes[i],
          time: time + i,
          duration: duration,
          volume: volume);
    });
    String filePath = '$path/${DateTime.now().millisecondsSinceEpoch}.mid';
    var outputFile = File(filePath);
    dynamic dy = myMIDI.writeFile(outputFile);
    print('writeFile result==$dy');
    return filePath;
  }

  static void saveMidiFile2(List notesList, String path) {
    List notes = [60, 62, 64, 65, 67, 69, 71, 72]; //  # MIDI note number
    var track = 0;
    var channel = 0;
    var time = 0; //    # In beats
    var duration = 0.5; //    # In beats
    var tempo = 60; //   # In BPM
    var volume = 100; //  # 0-127, as per the MIDI standard

    MIDIFile myMIDI = MIDIFile(numTracks: 2);
    myMIDI.addTempo(
      track: track,
      time: time,
      tempo: tempo,
    );
    myMIDI.addKeySignature(
        track: track,
        time: time,
        no_of_accidentals: 0,
        accidental_mode: AccidentalMode.MAJOR,
        accidental_type: AccidentalType.SHARPS);

    List.generate(notes.length, (i) {
      myMIDI.addNote(
          track: track,
          channel: channel,
          pitch: notes[i],
          time: time + i,
          duration: duration,
          volume: 100);
    });

    var outputFile = File('$path/${DateTime.now().millisecondsSinceEpoch}.mid');
    myMIDI.writeFile(outputFile);
  }

  static String testExportMidi(String path) {
    List notes = [60, 62, 64, 65, 67, 69, 71, 72]; //  # MIDI note number
    var track = 0;
    var channel = 0;
    var time = 0; //    # In beats
    var duration = 0.2; //    # In beats
    var tempo = 120; //   # In BPM
    var volume = 100; //  # 0-127, as per the MIDI standard

    MIDIFile myMIDI = MIDIFile(numTracks: 2);
    myMIDI.addTempo(
      track: track,
      time: time,
      tempo: tempo,
    );
    myMIDI.addKeySignature(
        track: track,
        time: time,
        no_of_accidentals: 0,
        accidental_mode: AccidentalMode.MAJOR,
        accidental_type: AccidentalType.SHARPS);

    List.generate(notes.length, (i) {
      myMIDI.addNote(
          track: track,
          channel: channel,
          pitch: notes[i],
          time: time + i,
          duration: duration,
          volume: 100);
    });

    var outputFile = File('$path/${DateTime.now().millisecondsSinceEpoch}.mid');
    myMIDI.writeFile(outputFile);
    return outputFile.path;
  }
}
