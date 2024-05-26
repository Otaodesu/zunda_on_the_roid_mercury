# zunda_on_the_roid_mercury
- チャットアプリ風のUI上で、VOICEVOXによる音声合成を試すことができます。
- 完全非公式です。
- GitHubなるものの練習を兼ねています。
- noteにて、このアプリの[スクリーンショットを見られます](https://note.com/iseudondes/n/nea9229a4b897)。

## 使用している技術は？
- メイン言語: Dart/Flutter
- チャットUI: [flutter_chat_ui 🇺🇦](https://pub.dev/packages/flutter_chat_ui)
- 音声合成: [voicevox_flutter](https://github.com/char5742/voicevox_flutter)

## ライセンスは？
- ソースコード本体は、flutter_chat_uiにならってApache license 2.0とします。誰か続きを作ってくれ！
- 合成した音声の利用規約は、[こちら](https://voicevox.hiroshiba.jp/)を確認してください。
- キャラクター名などの権利は、各団体等に帰属します。

## ビルドまでの手順
簡単で す！

### 1. 準備するもの
  - [ ] Flutterの開発環境
    -  サンプルアプリ（カウンターのやつ）がビルドできるようにしてください。
  - [ ] Androidの実機
    -  arm64ライブラリを使用するため、AndroidStudioに付属するx86_64の仮想マシンでは動作しません（私は気づくのに3日かかりましたが何か？）

### 2. ダウンロードする
  - [ ] zunda_on_the_roid_mercury（このリポジトリ）

  - [ ] voicevox_flutter  
https://github.com/char5742/voicevox_flutter/tree/dependency-voicevox_core-v0.15.0-preview.13

  - [ ] "voicevox_coreのAndroid向けライブラリ"  
https://github.com/VOICEVOX/voicevox_core/releases/download/0.15.0-preview.13/voicevox_core-android-arm64-cpu-0.15.0-preview.13.zip

  - [ ] "VOICEVOX コア音声モデル"  
 https://github.com/VOICEVOX/voicevox_core/releases/download/0.15.0-preview.13/model-0.15.0-preview.13.zip

### 3. ファイルを配置する
  - [ ] `voicevox_flutter-dependency-voicevox_core-v0.15.0-preview.13/example/android/app/src/main/jniLibs/arm64-v8a/libc++_shared.so` を `zunda_on_the_roid_mercury/android/app/src/main/jniLibs/arm64-v8a`にコピー
 
  - [ ] `voicevox_flutter-dependency-voicevox_core-v0.15.0-preview.13/example/assets/open_jtalk_dic_utf_8-1.11` の中身すべてを `zunda_on_the_roid_mercury/assets/open_jtalk_dic_utf_8-1.11` にコピー

  - [ ] `voicevox_core-android-arm64-cpu-0.15.0-preview.13/libvoicevox_core.so` を `zunda_on_the_roid_mercury/android/app/src/main/jniLibs/arm64-v8a` にコピー

  - [ ] `model-0.15.0-preview.13` の中身すべてを `zunda_on_the_roid_mercury/assets/model` にコピー

### 4. voicevox_flutterを紐づける
  - [ ] `zunda_on_the_roid_mercury/pubspec.yaml`を開き、以下の部分を `voicevox_flutter-dependency-voicevox_core-v0.15.0-preview.13` のフォルダパスに書き換えてください

>   voicevox_flutter:  
>     path: **../voicevox_flutter-dependency-voicevox_core-v0.15.0-preview.13**  
>     # 😆ビルドする前に、voicevox_flutterライブラリのフォルダパスに書き換えてください

### 5. 依存関係を解決する
  - [ ] `zunda_on_the_roid_mercury/` に移動して、`flutter pub get` を行います

以上でapkファイルがビルドできるようになるはずです！おつかれさまでした！
