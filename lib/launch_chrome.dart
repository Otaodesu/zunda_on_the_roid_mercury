import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

// 分ける意味ある？🐺
// →こういう系の処理を固める「その他」な場所にする予定.
// →こういう系の処理増えてきた.

// URLを入れたらChromeが起動するよ！っていう関数.
void launchChrome(String targetUrl) async {
  final url = Uri.parse(targetUrl);
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch $url');
  }
}

// テキスト形式でエクスポートするときの内容を作るよ！っていう関数。名前適当すぎやろ.
String makeText(List<types.Message> messages) {
  final thisIsIterable = messages.reversed; // 再生中にリストに変更が加わると例外になるためコピーする.
  final targetMessages = thisIsIterable.toList(); // なおもIterableのため固定する.

  // 本家VOICEVOXの「テキスト読み込み」機能と互換性のあるテキストを作っていく😎.
  final compatibleTexts = <String>[];
  for (var pickedMessage in targetMessages) {
    if (pickedMessage is types.TextMessage) {
      final texts = pickedMessage.text.split('\n'); // 本家さまで読めるように複数行のテキストを分割する.
      for (var pickedText in texts) {
        final compatibleText = '${pickedMessage.author.firstName}(${pickedMessage.author.lastName}),$pickedText';
        print('${DateTime.now()}🤔$compatibleText');
        compatibleTexts.add(compatibleText);
      }
    }
  }

  final compatibleOutput = compatibleTexts.join('\n');
  return compatibleOutput;
}

// インポートしようとしてるJSONテキストともとのメッセージsから新しいメッセージsを作る。エラーならもとのメッセージsを返す.
List<types.Message> combineMessagesFromJson(String? jsonText, List<types.Message> beforeMessages) {
  if (jsonText == null) {
    return beforeMessages;
  }

  var additionalMessages = <types.Message>[];

  try {
    additionalMessages =
        (jsonDecode(jsonText) as List).map((e) => types.Message.fromJson(e as Map<String, dynamic>)).toList();
  } catch (e) {
    print('キャッチ！🤗$eとのことです。なんか見たことあるなこれ。');
    return beforeMessages;
  }

  final updatedMessages = <types.Message>[];

  // 新しいUUIDを振りなおす。なぜ気づかなかったんだ…😵！PADの時すら理解していたというのに…！.
  for (var pickedMessage in additionalMessages) {
    // ↓ここに入ってくるのはテキストメッセージだけじゃない.
    final updatedMessage = (pickedMessage).copyWith(
      id: const Uuid().v4(), // この際だから時刻も振り直します？←くれぐれもupdatedAtはいじるなよ🤬.
    );
    updatedMessages.add(updatedMessage);
  }

  updatedMessages.addAll(beforeMessages);

  return updatedMessages; // こんなんで動くんでしょうか？私はそうは思わにあ😹←←まったくもってそうですね.
}

// 長文を分割する関数。RAM6GBの端末では470文字前後でクラッシュした (モデルのオンデマンド読み込み改造後) 快適な分割方法は要研究.
Future<List<String>> splitTextIfLong(String text) async {
  // 分割したい位置に改行を追加しておく.
  text = text.replaceAll('。', '。\n'); // 句点で改行する。.
  // text = text.replaceAll(RegExp(r'\. '), '.\n'); // ピリオドで改行する。小数点や "Mr. Ohtani" の考慮が必要.

  final splittedTexts = text.split('\n');

  // それでも各インデックスが長文の場合、思い切ってカットしてしまう…があえてコメントアウトした。限界にチャレンジしよう！.
  // for (var i = 0; i <= splittedTexts.length - 1; i++) {
  //   if (splittedTexts[i].length > 1010) {
  //     splittedTexts[i] = splittedTexts[i].substring(0, 1000); // 文字列が存在する必要がある。厳格や.
  //   }
  // }

  for (var i = splittedTexts.length - 1; i >= 0; i--) {
    if (splittedTexts[i] == '' || splittedTexts[i] == ' ') {
      splittedTexts.removeAt(i);
    }
  }

  if (splittedTexts.length > 1) {
    Fluttertoast.showToast(msg: '👺分割します');
  }

  return splittedTexts;
}

// キャラクター辞書を読み込む関数.
Future<List<List<types.User>>> loadCharactersDictionary() async {
  final honkeAsText = await rootBundle.loadString('assets/charactersDictionary.json');
  // ここで例外なら『［Flutter］Assets （テキスト、画像）の利用方法』。700msくらいかかってる.
  final honkeAsDynamic = json.decode(honkeAsText);

  // 本家のjsonを二重リストに変換していく。mainの_userと同じにすること😹.
  final charactersDictionary = <List<types.User>>[];
  for (var i = 0; i < honkeAsDynamic.length; i++) {
    final styles = <types.User>[];
    for (var j = 0; j < honkeAsDynamic[i]['styles'].length; j++) {
      final styleAsUser = types.User(
        id: honkeAsDynamic[i]['speaker_uuid'],
        firstName: honkeAsDynamic[i]['name'],
        lastName: honkeAsDynamic[i]['styles'][j]['name'],
        updatedAt: honkeAsDynamic[i]['styles'][j]['id'],
      );
      styles.add(styleAsUser);
    }
    charactersDictionary.add(styles);
  }
  return charactersDictionary;
}
