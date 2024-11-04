/// 当前使用的模型类型
enum ModelType {
  ncnn, //iOS手机只有这个ncnn
  qnn, //pc端包括ncnn和qnn
  mtk, // android手机包括三者
}

enum DownloadStatus {
  start,
  downloading,
  finish,
  fail,
}

const String appVersion = 'ncnn_1.6.0_20241030';

var qnnSoList = [
  'libQnnDspV66Skel.so',
  'libQnnHtp.so',
  'libQnnHtpNetRunExtensions.so',
  'libQnnHtpPrepare.so',
  'libQnnHtpV68Skel.so',
  'libQnnHtpV68Stub.so',
  'libQnnHtpV69Skel.so',
  'libQnnHtpV69Skel.so',
  'libQnnHtpV73Skel.so',
  'libQnnHtpV73Stub.so',
  'libQnnHtpV75Skel.so',
  'libQnnHtpV75Stub.so',
  'libQnnSystem.so',
];

const kNoteState = [
  "4",
  "2",
  "1",
  "/2",
  "/4",
  "/8",
  "/16",
  "z4",
  "z2",
  "z1",
  "z/2",
  "z/4",
];

List<String> keyboardOptions = [
  'Simulate keyboard',
  'Midi keyboard',
];
List<String> prompts = [
  "Lost time is never found again",
  "Soft Spring Rain",
  "Happy Waltz",
  "Flower Picking Elf",
  "Babbling Stream",
  "Galloping Steed",
  "Pink Girl Heart",
  "Harmonious Relationship",
  "Mountain Valley",
  "Partner in Crime",
  "Tiptoe Dance",
  "Heroic Story",
  "Breeze Blowing",
  "Celebration Preparation",
  "Hidden Crisis",
  "A calm daily routine",
  "Sudden Shower",
  "Age Of Peace",
  "Recalling the past",
  "Parade welcome",
  "I want to tell you",
  "Plotting",
  "When the clouds part",
  "The Way Home",
  "Harvest Season",
  "Open one's own heart wide",
  "Silent Protection",
  "Joyful Mood",
  "Visit the maternal family",
  "Get away from it all",
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

List<String> instruments = [
  'piano',
  'violin',
  'ocarina',
  'cello',
  'guitar',
];

List<String> timeSignatures = [
  '2/4',
  '3/4',
  '4/4',
  '3/8',
  '6/8',
];

List<String> promptsAbc = [
  r'''
S:2
B:25
E:5
B:26
L:1/4
M:4/4
K:D
"D" A F F''',
  r'''
S:2
B:9
E:5
B:9
L:1/8
M:2/4
K:Emin
"Em" (Be) (d''',
  r'''
S:2
B:8
E:6
B:8
L:1/8
M:4/4
K:D
"D" A2 A>F"Bm"''',
  r'''
S:2
B:10
E:4
B:8
L:1/8
M:2/4
K:none
[K:C]"C" gg g>''',
  r'''
S:2
B:17
E:6
B:16
L:1/8
M:6/8
K:Bb
 B, |"Bb" B,D''',
  r'''
S:2
B:9
E:8
B:9
L:1/4
M:2/2
K:Ddor
 d |"Am" c A''',
  r'''
S:2
B:9
E:5
B:8
L:1/8
M:3/4
K:Bb
 F |"Bb" B>A"Gm"''',
  r'''
S:2
B:8
E:5
B:8
L:1/8
M:4/4
K:D
"D" A3 B A''',
  r'''
S:2
B:8
E:3
B:8
L:1/8
M:4/4
K:G
"G" G,A,B,''',
  r'''
S:2
B:16
E:5
B:17
L:1/8
M:2/4
K:A
"A" a2{f} e2 |{d} c2''',
  r'''
S:2
B:9
E:7
B:9
L:1/8
M:6/8
K:A
 E |"A" A>G''',
  r'''
S:2
B:8
E:8
B:8
L:1/8
M:4/4
K:Ab
"Ab" c3 B A3''',
  r'''
S:2
B:9
E:4
B:9
L:1/8
M:4/4
K:Ab
 C>D |"Ab" E2''',
  r'''
S:2
B:16
E:4
B:16
L:1/8
M:2/4
K:F
"F" cc"C7" B''',
  r'''
S:2
B:9
E:4
B:12
L:1/8
M:4/4
K:Ador
"Am" a3 g e''',
  r'''
S:2
B:9
E:5
B:8
L:1/8
M:3/4
K:Db
 DF |"Db" A3''',
  r'''
S:2
B:9
E:8
B:10
L:1/8
M:6/8
K:D
 A/F/ |"D" D''',
  r'''
S:2
B:9
E:8
B:9
L:1/8
M:4/4
K:G
 GA |"G" B2''',
  r'''
S:2
B:17
E:5
B:16
L:1/8
M:3/4
K:none
 ec |"Am" A4''',
  r'''
S:2
B:9
E:6
B:9
L:1/8
M:4/4
K:G
 (3def''',
  r'''
S:2
B:9
E:8
B:9
L:1/8
M:6/8
K:A
 A/B/ |"A" c2''',
  r'''
S:2
B:8
E:6
B:8
L:1/8
M:6/8
K:Ador
"Am" eAA''',
  r'''
S:2
B:9
E:6
B:9
L:1/8
M:6/8
K:Amin
 e |"Am" c2 A''',
  r'''
S:2
B:17
E:4
B:10
L:1/8
M:3/4
K:C
 G2 |"C" G6 | G2''',
  r'''
S:2
B:16
E:6
B:16
L:1/4
M:3/4
K:G
"G" D3/2 E/ D''',
  r'''
S:2
B:9
E:4
B:8
L:1/8
M:12/8
K:Bb
 F |"Bb" d3 d3''',
  r'''
S:2
B:9
E:5
B:10
L:1/8
M:6/8
K:G
 D |"G" G2 G''',
  r'''
S:2
B:9
E:5
B:9
L:1/8
M:6/8
K:F
 c |"F" FA''',
  r'''
S:2
B:8
E:6
B:8
L:1/8
M:2/2
K:D
"D" f2 A2 f2''',
  r'''
S:2
B:1
E:0
B:29
L:1/8
M:4/4
K:G
 D GB |:"G"''',
];
