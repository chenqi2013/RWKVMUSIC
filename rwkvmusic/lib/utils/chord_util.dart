import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

class ChordUtil {
  static List<String> getTopIndices(Map<int, double> dict, int n) {
    List<MapEntry<int, double>> items = dict.entries.toList();
    items.sort((a, b) => b.value.compareTo(a.value));
    return items.sublist(0, n).map((item) => item.key.toString()).toList();
  }

  static String getChord(String strArray) {
    print("getChord strArray: $strArray");
    List<int> src = List<int>.from(jsonDecode(strArray));
    for (int i = 0; i < src.length; i++) {
      src[i] = src[i] % 12;
    }

    const int chordBegin = 1;
    const int chordEnd = 6;

    final Map<int, String> chordName = {
      1: "C",
      2: "Dm",
      3: "Em",
      4: "F",
      5: "G",
      6: "Am",
    };
    final Map<int, List<int>> scoreNote = {
      1: [0, 4, 7],
      2: [2, 5, 9],
      3: [4, 7, 11],
      4: [5, 9, 0],
      5: [7, 11, 2],
      6: [9, 0, 4],
    };
    final Map<int, Map<int, double>> scoreProg0 = {
      1: {1: 24, 2: 2, 3: 2, 4: 39, 5: 20, 6: 35},
      2: {1: 35, 2: 2, 3: 1, 4: 4, 5: 86, 6: 4},
      3: {1: 40, 2: 5, 3: 0, 4: 85, 5: 20, 6: 8},
      4: {1: 20, 2: 1, 3: 1, 4: 1, 5: 76, 6: 1},
      5: {1: 70, 2: 1, 3: 2, 4: 13, 5: 1, 6: 14},
      6: {1: 5, 2: 25, 3: 1, 4: 49, 5: 39, 6: 1},
    };
    for (int c1 = chordBegin; c1 <= chordEnd; c1++) {
      const int BIAS = 1;
      double sum = 0;
      for (int c2 = chordBegin; c2 <= chordEnd; c2++) {
        sum += scoreProg0[c1]![c2]! + BIAS;
      }
      for (int c2 = chordBegin; c2 <= chordEnd; c2++) {
        scoreProg0[c1]![c2] = (log((scoreProg0[c1]![c2]! + BIAS) / sum));
      }
    }

    int chordLen = (src.length / 4).ceil();
    List<String> out = List<String>.filled(chordLen, "");
    List<Map<int, double>> score = List<Map<int, double>>.generate(
      chordLen,
      (index) => index == 0
          ? {1: 0.6, 2: 0.2, 3: 0.1, 4: 0.5, 5: 0.4, 6: 0.3}
          : {1: 0.4, 2: 0.2, 3: 0.1, 4: 0.5, 5: 0.6, 6: 0.3},
    );
    List<List<int>> candidate = List<List<int>>.filled(chordLen, []);

    for (int i = 0; i < chordLen; i++) {
      for (int c = chordBegin; c <= chordEnd; c++) {
        for (int n = i * 4; n < min(i * 4 + 4, src.length); n++) {
          int s = src[n];
          if (scoreNote[c]!.contains(s)) {
            score[i][c] = score[i][c]! + 1;
            if (scoreNote[c]![0] == s) {
              score[i][c] = score[i][c]! + [0.2, 0, 0.1, 0][n % 4];
            }
          } else {
            score[i][c] = score[i][c]! - [0.4, 0, 0.2, 0][n % 4];
          }
        }
      }
    }

    for (int i = 0; i < chordLen; i++) {
      List<String> best = getTopIndices(score[i], 2);
      candidate[i] = best.map((item) => int.parse(item)).toList();
    }

    double bestScore = -1e10;
    String bestPlan = "";
    for (int i = 0; i < pow(2, chordLen); i++) {
      String plan = i.toRadixString(2).padLeft(chordLen, "0");
      double sum = 0;
      for (int j = 0; j < chordLen; j++) {
        int c1 = candidate[j][int.parse(plan[j])];
        sum += score[j][c1]! * 0.5;
        if (j < chordLen - 1) {
          int c2 = candidate[j + 1][int.parse(plan[j + 1])];
          sum += scoreProg0[c1]![c2]!;
        }
      }
      if (sum > bestScore) {
        bestScore = sum;
        bestPlan = plan;
      }
    }

    for (int i = 0; i < chordLen; i++) {
      int chordIndex = candidate[i][int.parse(bestPlan[i])];
      out[i] = chordName[chordIndex]!;
    }
    String result = jsonEncode(out);
    print('getChord result==$result');
    return result;
  }

  static findDifferent() async {
    File file = File(
        'C:\\Users\\bay13\\RWKVMUSIC\\rwkvmusic\\lib\\utils\\chordresult_HTML.log');
    String data = await file.readAsString();
    // print('file length == $data');
    // 去除字符串中的所有空格
    data = data.replaceAll(' ', '');

    // 分割字符串得到子数组字符串列表
    List<String> arrayStrings = data.split('],[');

    File file22 = File(
        'C:\\Users\\bay13\\RWKVMUSIC\\rwkvmusic\\lib\\utils\\chordresult_dart1.log');
    String data22 = await file22.readAsString();
    // print('file length == $data');
    // 去除字符串中的所有空格
    data22 = data22.replaceAll(' ', '');

    // 分割字符串得到子数组字符串列表
    List<String> arrayStrings22 = data22.split('],[');
    for (int i = 0; i < arrayStrings.length; i++) {
      if (arrayStrings22[i] != arrayStrings[i]) {
        print('dart=${arrayStrings22[i]},js=${arrayStrings[i]},i==$i');
      }
    }
    print(
        'length11== ${arrayStrings.length},length22== ${arrayStrings22.length}');
  }

  static checkContentIsSame() async {
    File file11 = File(
        'C:\\Users\\bay13\\RWKVMUSIC\\rwkvmusic\\lib\\utils\\chordresult_dart1.log');
    File file22 = File(
        'C:\\Users\\bay13\\RWKVMUSIC\\rwkvmusic\\lib\\utils\\chordresult_HTML.log');
    String data11 = await file11.readAsString();
    String data22 = await file22.readAsString();
    if (data11 == data22) {
      print('chord is same');
    } else {
      print('chord is not same=${data11.length},,${data22.length}');
    }
  }

  static void getResult() {
    Isolate.spawn(calResult, '');
  }

  static void calResult(String param) async {
    File file = File(
        'C:\\Users\\bay13\\RWKVMUSIC\\rwkvmusic\\lib\\utils\\notedata.log');
    if (await file.exists()) {
      String data = await file.readAsString();
      // print('file length == $data');
      // 去除字符串中的所有空格
      data = data.replaceAll(' ', '');

      // 分割字符串得到子数组字符串列表
      List<String> arrayStrings = data.split('],[');

      // 去除每个子数组字符串中的 '[' 和 ']'
      arrayStrings = arrayStrings
          .map((str) => str.replaceAll('[', '').replaceAll(']', ''))
          .toList();

      // 将每个子数组字符串转换为整数数组并添加到主列表中
      List<List<int>> arrays = [];
      for (var str in arrayStrings) {
        List<int> array = str.split(',').map((s) => int.parse(s)).toList();
        arrays.add(array);
      }

      // 输出整数数组列表
      StringBuffer sb = StringBuffer();
      for (var arr in arrays) {
        sb.write(getChord(jsonEncode(arr)));
        sb.write(',');
      }
      File fileResult = File(
          'C:\\Users\\bay13\\RWKVMUSIC\\rwkvmusic\\lib\\utils\\chordresult_dart1.log');
      fileResult.writeAsString(sb.toString());
    } else {
      print('file not exists');
    }
  }

// 随机生成 1~30 长度的10000段检验
  static void testData() async {
    List<List<int>> data = generateData(10000, 1, 30, 21, 108);
    List<String> jsonData = data.map((list) => jsonEncode(list)).toList();
    print('jsonData==$jsonData');
  }

  static List<List<int>> generateData(
      int count, int minLength, int maxLength, int minValue, int maxValue) {
    List<List<int>> result = [];
    Random random = Random();
    for (int i = 0; i < count; i++) {
      int length = random.nextInt(maxLength - minLength + 1) + minLength;
      List<int> array = List.generate(
          length, (_) => random.nextInt(maxValue - minValue + 1) + minValue);
      result.add(array);
    }
    return result;
  }
}
