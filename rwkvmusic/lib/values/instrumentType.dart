class InstrumentType {
  static const int ACOUSTIC_GRAND_PIANO = 0;
  static const int BRIGHT_ACOUSTIC_PIANO = 1;
  static const int ELECTRIC_GRAND_PIANO = 2;
  static const int HONKY_TONK_PIANO = 3;
  static const int ELECTRIC_PIANO_1 = 4;
  static const int ELECTRIC_PIANO_2 = 5;
  static const int HARPSICHORD = 6;
  static const int CLAVINET = 7;
  static const int CELESTA = 8;
  static const int GLOCKENSPIEL = 9;
  static const int MUSIC_BOX = 10;
  static const int VIBRAPHONE = 11;
  static const int MARIMBA = 12;
  static const int XYLOPHONE = 13;
  static const int TUBULAR_BELLS = 14;
  static const int DULCIMER = 15;
  static const int DRAWBAR_ORGAN = 16;
  static const int PERCUSSIVE_ORGAN = 17;
  static const int ROCK_ORGAN = 18;
  static const int CHURCH_ORGAN = 19;
  static const int REED_ORGAN = 20;
  static const int ACCORDION = 21;
  static const int HARMONICA = 22;
  static const int TANGO_ACCORDION = 23;
  static const int ACOUSTIC_GUITAR_NYLON = 24;
  static const int ACOUSTIC_GUITAR_STEEL = 25;
  static const int ELECTRIC_GUITAR_JAZZ = 26;
  static const int ELECTRIC_GUITAR_CLEAN = 27;
  static const int ELECTRIC_GUITAR_MUTED = 28;
  static const int OVERDRIVEN_GUITAR = 29;
  static const int DISTORTION_GUITAR = 30;
  static const int GUITAR_HARMONICS = 31;
  static const int ACOUSTIC_BASS = 32;
  static const int ELECTRIC_BASS_FINGER = 33;
  static const int ELECTRIC_BASS_PICK = 34;
  static const int FRETLESS_BASS = 35;
  static const int SLAP_BASS_1 = 36;
  static const int SLAP_BASS_2 = 37;
  static const int SYNTH_BASS_1 = 38;
  static const int SYNTH_BASS_2 = 39;
  static const int VIOLIN = 40;
  static const int VIOLA = 41;
  static const int CELLO = 42;
  static const int CONTRABASS = 43;
  static const int TREMOLO_STRINGS = 44;
  static const int PIZZICATO_STRINGS = 45;
  static const int ORCHESTRAL_HARP = 46;
  static const int TIMPANI = 47;
  static const int STRING_ENSEMBLE_1 = 48;
  static const int STRING_ENSEMBLE_2 = 49;
  static const int SYNTH_STRINGS_1 = 50;
  static const int SYNTH_STRINGS_2 = 51;
  static const int CHOIR_AAHS = 52;
  static const int VOICE_OOHS = 53;
  static const int SYNTH_VOICE = 54;
  static const int ORCHESTRA_HIT = 55;
  static const int TRUMPET = 56;
  static const int TROMBONE = 57;
  static const int TUBA = 58;
  static const int MUTED_TRUMPET = 59;
  static const int FRENCH_HORN = 60;
  static const int BRASS_SECTION = 61;
  static const int SYNTH_BRASS_1 = 62;
  static const int SYNTH_BRASS_2 = 63;
  static const int SOPRANO_SAX = 64;
  static const int ALTO_SAX = 65;
  static const int TENOR_SAX = 66;
  static const int BARITONE_SAX = 67;
  static const int OBOE = 68;
  static const int ENGLISH_HORN = 69;
  static const int BASSOON = 70;
  static const int CLARINET = 71;
  static const int PICCOLO = 72;
  static const int FLUTE = 73;
  static const int RECORDER = 74;
  static const int PAN_FLUTE = 75;
  static const int BLOWN_BOTTLE = 76;
  static const int SHAKUHACHI = 77;
  static const int WHISTLE = 78;
  static const int OCARINA = 79;
  static const int LEAD_1_SQUARE = 80;
  static const int LEAD_2_SAWTOOTH = 81;
  static const int LEAD_3_CALLIOPE = 82;
  static const int LEAD_4_CHIFF = 83;
  static const int LEAD_5_CHARANG = 84;
  static const int LEAD_6_VOICE = 85;
  static const int LEAD_7_FIFTHS = 86;
  static const int LEAD_8_BASS_LEAD = 87;
  static const int PAD_1_NEW_AGE = 88;
  static const int PAD_2_WARM = 89;
  static const int PAD_3_POLYSYNTH = 90;
  static const int PAD_4_CHOIR = 91;
  static const int PAD_5_BOWED = 92;
  static const int PAD_6_METALLIC = 93;
  static const int PAD_7_HALO = 94;
  static const int PAD_8_SWEEP = 95;
  static const int FX_1_RAIN = 96;
  static const int FX_2_SOUNDTRACK = 97;
  static const int FX_3_CRYSTAL = 98;
  static const int FX_4_ATMOSPHERE = 99;
  static const int FX_5_BRIGHTNESS = 100;
  static const int FX_6_GOBLINS = 101;
  static const int FX_7_ECHOES = 102;
  static const int FX_8_SCI_FI = 103;
  static const int SITAR = 104;
  static const int BANJO = 105;
  static const int SHAMISEN = 106;
  static const int KOTO = 107;
  static const int KALIMBA = 108;
  static const int BAGPIPE = 109;
  static const int FIDDLE = 110;
  static const int SHANAI = 111;
  static const int TINKLE_BELL = 112;
  static const int AGOGO = 113;
  static const int STEEL_DRUMS = 114;
  static const int WOODBLOCK = 115;
  static const int TAIKO_DRUM = 116;
  static const int MELODIC_TOM = 117;
  static const int SYNTH_DRUM = 118;
  static const int REVERSE_CYMBAL = 119;
  static const int GUITAR_FRET_NOISE = 120;
  static const int BREATH_NOISE = 121;
  static const int SEASHORE = 122;
  static const int BIRD_TWEET = 123;
  static const int TELEPHONE_RING = 124;
  static const int HELICOPTER = 125;
  static const int APPLAUSE = 126;
  static const int GUNSHOT = 127;

  static const int DEFAULT_INSTRUMENT = VIOLIN;
  static const int DEFAULT_INSTRUMENT_FOR_KEYBOARD = ACOUSTIC_GRAND_PIANO;

  static const List<String> INSTRUMENT_NAMES = [
    "acoustic_grand_piano",
    "bright_acoustic_piano",
    "electric_grand_piano",
    "honky_tonk_piano",
    "electric_piano_1",
    "electric_piano_2",
    "harpsichord",
    "clavinet",
    "celesta",
    "glockenspiel",
    "music_box",
    "vibraphone",
    "marimba",
    "xylophone",
    "tubular_bells",
    "dulcimer",
    "drawbar_organ",
    "percussive_organ",
    "rock_organ",
    "church_organ",
    "reed_organ",
    "accordion",
    "harmonica",
    "tango_accordion",
    "acoustic_guitar_nylon",
    "acoustic_guitar_steel",
    "electric_guitar_jazz",
    "electric_guitar_clean",
    "electric_guitar_muted",
    "overdriven_guitar",
    "distortion_guitar",
    "guitar_harmonics",
    "acoustic_bass",
    "electric_bass_finger",
    "electric_bass_pick",
    "fretless_bass",
    "slap_bass_1",
    "slap_bass_2",
    "synth_bass_1",
    "synth_bass_2",
    "violin",
    "viola",
    "cello",
    "contrabass",
    "tremolo_strings",
    "pizzicato_strings",
    "orchestral_harp",
    "timpani",
    "string_ensemble_1",
    "string_ensemble_2",
    "synth_strings_1",
    "synth_strings_2",
    "choir_aahs",
    "voice_oohs",
    "synth_voice",
    "orchestra_hit",
    "trumpet",
    "trombone",
    "tuba",
    "muted_trumpet",
    "french_horn",
    "brass_section",
    "synth_brass_1",
    "synth_brass_2",
    "soprano_sax",
    "alto_sax",
    "tenor_sax",
    "baritone_sax",
    "oboe",
    "english_horn",
    "bassoon",
    "clarinet",
    "piccolo",
    "flute",
    "recorder",
    "pan_flute",
    "blown_bottle",
    "shakuhachi",
    "whistle",
    "ocarina",
    "lead_1_square",
    "lead_2_sawtooth",
    "lead_3_calliope",
    "lead_4_chiff",
    "lead_5_charang",
    "lead_6_voice",
    "lead_7_fifths",
    "lead_8_bass_lead",
    "pad_1_new_age",
    "pad_2_warm",
    "pad_3_polysynth",
    "pad_4_choir",
    "pad_5_bowed",
    "pad_6_metallic",
    "pad_7_halo",
    "pad_8_sweep",
    "fx_1_rain",
    "fx_2_soundtrack",
    "fx_3_crystal",
    "fx_4_atmosphere",
    "fx_5_brightness",
    "fx_6_goblins",
    "fx_7_echoes",
    "fx_8_sci_fi",
    "sitar",
    "banjo",
    "shamisen",
    "koto",
    "kalimba",
    "bag_pipe",
    "fiddle",
    "shanai",
    "tinkle_bell",
    "agogo",
    "steel_drums",
    "woodblock",
    "taiko_drum",
    "melodic_tom",
    "synth_drum",
    "reverse_cymbal",
    "guitar_fret_noise",
    "breath_noise",
    "seashore",
    "bird_tweet",
    "telephone_ring",
    "helicopter",
    "applause",
    "gunshot"
  ];

  static String getInstrumentDirName(int instrument) {
    return "${INSTRUMENT_NAMES[instrument]}-mp3";
  }
}
