import 'dart:convert';
import 'dart:io';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import 'text_dictionary_editor.dart';
import 'service.dart';

class MeteorSpecSynthesizer {
  MeteorSpecSynthesizer() {
    _initialize();
  }

  final service = NativeVoiceService();
  bool _isNativeVoiceServiceReady = false; // .initializeが完了するまでは合成リクエストを出さないようにする。手動切り替え👻

  var _synthesizeWaitingList = <String>[]; // チャット画面の送信順になるように制御すること😦.

  final _playlistPlayer = AudioPlayer();
  final _playlist = ConcatenatingAudioSource(children: []);

  // 😆主役のメソッド。実態は順番待ちコントローラー。audioQueryを返す.
  Future<Map<String, dynamic>> synthesizeFromText({
    required String text,
    int? speakerId,
    required String messageId,
  }) async {
    speakerId = speakerId ?? 3;

    // 順番待ちシステム。合成できなくなったらまず疑うこと😹.
    _synthesizeWaitingList.add(messageId); // オーダーが通ったら必ず自分のIDを消しましょう！！😹😹😹.
    while (_synthesizeWaitingList[0] != messageId || !_isNativeVoiceServiceReady) {
      await Future.delayed(const Duration(seconds: 1));

      // 整理システム搭載により、いつのまにかリストから消える可能性が出てきた。無限待機になる前にmainに帰る.
      if (!_synthesizeWaitingList.contains(messageId)) {
        return {'success': false, 'errorMessage': '順番待ちから消えてます！😭'}; // 禍根: audioQuery以外を返している
      }
    }

    final serif = await convertTextToSerif(text); // 読み方辞書を適用する.
    final query = await service.audioQuery(serif, speakerId); // audioQueryを生成してもらう
    final wavPath = await service.synthesis(query, speakerId); // 音声を生成してもらう

    _synthesizeWaitingList.remove(messageId); // 生成できたので順番を進める😸 整理システムにより順番が変わるのでremoveAtから変更した.

    await _playlist.add(AudioSource.file(wavPath));
    _playlistPlayer.play();

    return json.decode(query);
  }

  // 🤔順番待ちリストを整理し、順番入れ替えや合成キャンセルが行えるメソッド。引数は優先度高い順。好きなタイミングで発動していいし、発動しなくてもいい.
  void organizeWaitingOrders(List<String> messageIDs) {
    final updatedList = <String>[];
    for (final pickedItem in messageIDs) {
      if (_synthesizeWaitingList.contains(pickedItem)) {
        updatedList.add(pickedItem);
      }
    }
    print('👻${DateTime.now()} 順番待ち列を整理しました！${updatedList.length - _synthesizeWaitingList.length}個');
    _synthesizeWaitingList = updatedList; // 引数に含まれないIDはなくなる.
  }

  // 🧐すでに順番待ち列に並んでいるか確認できるメソッド。重複オーダー防止にご活用ください.
  bool isMeAlreadyThere(String messageId) {
    if (_synthesizeWaitingList.contains(messageId)) {
      return true;
    }
    return false;
  }

  // 😚このクラスのインスタンスが作成されたとき動かす初期化処理.
  void _initialize() async {
    await _playlistPlayer.setAudioSource(_playlist); // .setAudioSourceするたびリスト先頭に戻るため1回だけ行う.
    print('${DateTime.now()}😋NativeVoiceServiceを起動します…');
    await service.initialize(); // voicevox_flutterを起動する
    print('${DateTime.now()}🥰NativeVoiceServiceが起動しました！');
    _isNativeVoiceServiceReady = true;
  }
}
// （下ほど新しいコメント）.
// DateTime.now()の方が書きやすいし見やすい～（ハチワレ）.
// 読み方辞書機能によって安定性低下の要因である英単語のスペル読みが解消（できるようになった）。じゃんじゃん登録しよう！！.
// クラス化すればプレイリストが空になってもplayerオブジェクトはクラス変数として保持されているので好きなタイミングでプレイリストに追加すれば再生される！Streamなんていらんかったんや！.
// .setAudioSourceするとその都度[0]から再生になる（?付き引数になっている）.
// プレイリストが空のとき.playするとプレイリストに追加されるまで待つモードになる。アプリの外からは再生中として扱われるので待ちかねてYouTube見始めると追加しても鳴り始めない.
// 順番待ちシステムができた！長文分割投稿システムとのシナジー効果大爆発（WaitingListの制御から目をそらしながら）.
// ユーザーが入力したものは「テキスト」、音声合成に最適化したものは「セリフ」。辞書機能の追加時とか[いつ？]区別しやすくなる。…と当初は思ってました.
// 読み方辞書を用いたテキスト→セリフ変換をこっちに持ってきた。辞書の変更がリアルタイムに反映されるようになるが流用性は薄れる.
// オーダーをmessageIDで待つことにしたので、同じmessageIDが「佐藤さ～ん」「「はい」」のように動き出す可能性がある.
// 2重オーダー防止のため、すでに列に並んでいるか確認可能にした。_orderWaitingListのプライベートを解除すればよかったのでは…？.
// _orderWaitingListがいつどんな状態に変化しようと動き続ける仕組みが必要になってしまった。でもこれによってメッセージ削除と並び替えに連動できるようになる！たぶん！！.
// 2重オーダー防止チェック、こんなことしてると「リストに載っているが人はいない」状態になったら詰んでしまわへんか？.
// voicevox_flutterを導入！ストレージ2GB、RAM2.5GBを消費する最強アプリとなった。mercuryどころかjupiter.
// MeteorSpecSynthesizer. 語感のカッコよさだけで命名
// service = NativeVoiceService()のくだり、voicevox_flutterサンプルではmainに入っていたがここに置いてみた。マルチスレッド関連の理由がある可能性大だが…
// cpuNumThreadsと同時オーダー数の組み合わせは結局デフォのcpuNumThreads: 4、同時オーダーなしがベター。同時2オーダーで2.5%速くなったけども
// 推奨環境はSnapdragon865、RAM6GB。長文の分割合成時にかろうじて追いつかずに生成できる
// service.dartを改造して、モデルを必要になったタイミングでRAMにロードするようにした。生成中2.5GBが1.2GBまで軽量化！
// Perfetto UIでCPUコアの駆動状況が見れる。以下はcpuNumThreads: 4、同時オーダー数: 1での音声合成してそうなコア数
// TensorG1 (big2+mid2+little4)… big2+mid2
// Snapdragon865 (big1+mid3+little4)… big1+mid3
// Snapdragon765G (big1+mid1+little6)… big1(だけ！？)
// Snapdragon680 (mid4+little4)… mid4
// Snapdragon720G (mid2+little6)… mid2(だけ！？)
// Snapdragon450 (mid8)… mid4
// Snapdragon808 (mid2+little4)… mid2+little2
// Snapdragon820 (mid2+little2)… mid2

// メッセージ再再生関連を一挙に制御するクラス作りかえたった！.
class AudioReplayManager {
  List<AudioPlayer> _playerObjects = []; // 連打に対応するため複数のプレーヤーインスタンスを格納する🫨.

  // メッセージ単発を再生するメソッド。再生できたらtrueを返す
  Future<bool> replayFromMessage(final types.Message message) async {
    if (message.metadata?['query'] == null) {
      print('audioQueryがないのでまだ合成していないようです。現場からは以上です。');
      return false;
    }
    final Map<String, dynamic> audioQuery = message.metadata?['query']; // この文脈ではnullなはずがないのに？

    final wavFile = await _navigateWavLocation(audioQuery);

    _playerObjects.add(AudioPlayer()); // 『[flutter]just_audioで音を再生する』.
    final index = _playerObjects.length - 1; // 連打すると位置がずれるので.last.playとかにしない.
    try {
      _playerObjects[index]
        ..setAudioSource(AudioSource.file(wavFile.path))
        ..play(); // カスケード記法。[_playerObjects.length - 1]にしたら1行ごとに更新するんですかね🤔
    } catch (e) {
      print('キャッチ！🤗${wavFile.path}は$eのためアクセスできませんでした。現場からは以上です。');
      return false; // 他のデバイスからzrprojをインポートしたとき.wavファイルは無いのでこうなる.
    }
    return true;
  }

  // 連続再生するメソッド.
  Future<void> replayFromMessages(List<types.Message> messages) async {
    // 公式pub.devのReadme #Working with gapless playlists.
    final playlist = ConcatenatingAudioSource(
      // useLazyPreparation: false, API使うわけではないのでデフォでいいよね？
      children: [],
    );

    for (var pickedMessage in messages) {
      if (pickedMessage.metadata?['query'] == null) {
        continue;
      }
      final Map<String, dynamic> audioQuery = pickedMessage.metadata?['query'];

      final wavFile = await _navigateWavLocation(audioQuery);
      if (!File(wavFile.path).existsSync()) {
        continue; // 単発再生のようにcatchだけするとwavある→ない→ある のとき2個めで再生が止まるため
      }
      playlist.add(AudioSource.file(wavFile.path));
    }

    if (playlist.length == 0) {
      Fluttertoast.showToast(msg: '🔰ふきだしをタップするか、メッセージを送信して音声合成してください'); // 長い🙊.
      return;
    }

    _playerObjects.add(AudioPlayer()); // 2つの "リスト" にご注意🙈.
    final index = _playerObjects.length - 1;

    _playerObjects[index]
      ..setAudioSource(
        playlist,
        preload: true,
      )
      ..play(); // アクセスできんファイルがあると例外出るっぽい🙉.
    // ぬるぽ出すタイミングがなくなった。コイツだけ再生されへんなーってのは自力で発見すべし.
  }

  // すべてストップするメソッド.
  void stop() {
    // Pickした場合コピーに対する操作になるのでstopが効かない。直接指定するとヨシ😹.
    for (var i = 0; i < _playerObjects.length; i++) {
      _playerObjects[i].dispose();
    }
    _playerObjects = [];
  }

  // service.dartと同じ仕組みにすること！😇 案内された先にファイルがあるとは限らない
  Future<File> _navigateWavLocation(Map<String, dynamic> audioQuery) async {
    final asString = json.encode(audioQuery);
    return File('${(await getApplicationDocumentsDirectory()).path}/${asString.hashCode}.wav');
  }
} // 再生再生再生成（再生成はここでは行わない）
