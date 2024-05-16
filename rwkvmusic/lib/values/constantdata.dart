List<String> keyboardOptions = [
  'Simulate keyboard',
  'Midi keyboard',
];
List<String> prompts = [
  "Busy Cowboy",
  "Night Song",
  "Greatest Work",
  "Way North",
  // "jazz4",
  // "jazz5",
  // "Galloping Steed",
  // "Pink Girl Heart",
  // "Harmonious Relationship",
  // "Mountain Valley",
  // "Partner in Crime",
  // "Tiptoe Dance",
  // "Heroic Story",
  // "Breeze Blowing",
  // "Celebration Preparation",
  // "Hidden Crisis",
  // "A calm daily routine",
  // "Sudden Shower",
  // "Age Of Peace",
  // "Recalling the past",
  // "Parade welcome",
  // "I want to tell you",
  // "Plotting",
  // "When the clouds part",
  // "The Way Home",
  // "Harvest Season",
  // "Open one's own heart wide",
  // "Silent Protection",
  // "Joyful Mood",
  // "Visit the maternal family",
  // "Get away from it all",
];

Map<String, String> soundEffect = {
  "Piano": 'acoustic_grand_piano-mp3',
  "Violin": 'violin-mp3',
  "Ocarina": 'ocarina-mp3',
  "Cello": 'cello-mp3',
  "Guitar": 'acoustic_guitar_steel-mp3',
};

Map<String, int> soundEffectInt = {
  "Piano": 0,
  "Violin": 40,
  "Ocarina": 79,
  "Cello": 42,
  "Guitar": 25,
};

Map midiGenerateMap = {
  'Busy Cowboy': {
    'temperature': 2.0,
    'top_k': 18,
    'top_p': 0.8,
  },
  'Night Song': {
    'temperature': 2.0,
    'top_k': 5,
    'top_p': 0.8,
  },
  'Greatest Work': {
    'temperature': 2.0,
    'top_k': 20,
    'top_p': 0.8,
  },
  'Way North': {
    'temperature': 3.7,
    'top_k': 30,
    'top_p': 0.9,
  },
  // 'jazz4': {
  //   'temperature': 1.0,
  //   'top_k': 8,
  //   'top_p': 0.8,
  // },
  // 'jazz5': {
  //   'temperature': 1.0,
  //   'top_k': 8,
  //   'top_p': 0.8,
  // },
};

List<String> promptsAbc = [
  "Busy Cowboy.mid",
  "Night Song.mid",
  "Greatest Work.mid",
  "Way North.mid",
  // "jazz4.midi",
  // "jazz5.midi",
//   r'''
// L:1/4
// M:4/4
// K:D
// "D" A F F''',
//   r'''
// L:1/8
// M:2/4
// K:Emin
// "Em" (Be) (d''',
//   r'''
// L:1/8
// M:4/4
// K:D
// "D" A2 A>F"Bm"''',
//   r'''
// L:1/8
// M:2/4
// K:none
// [K:C]"C" gg g>''',
//   r'''
// L:1/8
// M:6/8
// K:Bb
//  B, |"Bb" B,D''',
//   r'''
// L:1/4
// M:2/2
// K:Ddor
//  d |"Am" c A''',
//   r'''
// L:1/8
// M:3/4
// K:Bb
//  F |"Bb" B>A"Gm"''',
//   r'''
// L:1/8
// M:4/4
// K:D
// "D" A3 B A''',
//   r'''
// L:1/8
// M:4/4
// K:G
// "G" G,A,B,''',
//   r'''
// L:1/8
// M:2/4
// K:A
// "A" a2{f} e2 |{d} c2''',
//   r'''
// L:1/8
// M:6/8
// K:A
//  E |"A" A>G''',
//   r'''
// L:1/8
// M:4/4
// K:Ab
// "Ab" c3 B A3''',
//   r'''
// L:1/8
// M:4/4
// K:Ab
//  C>D |"Ab" E2''',
//   r'''
// L:1/8
// M:2/4
// K:F
// "F" cc"C7" B''',
//   r'''
// L:1/8
// M:4/4
// K:Ador
// "Am" a3 g e''',
//   r'''
// L:1/8
// M:3/4
// K:Db
//  DF |"Db" A3''',
//   r'''
// L:1/8
// M:6/8
// K:D
//  A/F/ |"D" D''',
//   r'''
// L:1/8
// M:4/4
// K:G
//  GA |"G" B2''',
//   r'''
// L:1/8
// M:3/4
// K:none
//  ec |"Am" A4''',
//   r'''
// L:1/8
// M:4/4
// K:G
//  (3def''',
//   r'''
// L:1/8
// M:6/8
// K:A
//  A/B/ |"A" c2''',
//   r'''
// L:1/8
// M:6/8
// K:Ador
// "Am" eAA''',
//   r'''
// L:1/8
// M:6/8
// K:Amin
//  e |"Am" c2 A''',
//   r'''
// L:1/8
// M:3/4
// K:C
//  G2 |"C" G6 | G2''',
//   r'''
// L:1/4
// M:3/4
// K:G
// "G" D3/2 E/ D''',
//   r'''
// L:1/8
// M:12/8
// K:Bb
//  F |"Bb" d3 d3''',
//   r'''
// L:1/8
// M:6/8
// K:G
//  D |"G" G2 G''',
//   r'''
// L:1/8
// M:6/8
// K:F
//  c |"F" FA''',
//   r'''
// L:1/8
// M:2/2
// K:D
// "D" f2 A2 f2''',
//   r'''
// L:1/8
// M:4/4
// K:G
//  D GB |:"G"''',
];
