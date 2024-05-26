import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';

// 言い訳: UIはどんどん込み入ってくると分かったので実際の処理と別にしたほうが理解しやすいかもと思ったんです.

// こっちのダイアログにもVoidCallbackを導入し、75行を98行にした。main側は半分に省略できたのでヨシ！😭.
// 選択後自動で閉じさせるのに苦戦した。onPressedをブロック文にしてpopを追加→on…Pressedに()を追加→VoidCallBack?のNull許容を解除→this.をrequiredにしてようやく思った動きに。ってこれPhotoボタンと同じやん.
class FukidashiLongPressDialog extends StatelessWidget {
  const FukidashiLongPressDialog({
    super.key,
    required this.onDeleteMessagePressed,
    required this.onMoveMessageUpPressed,
    required this.onMoveMessageDownPressed,
    required this.onPlayAllBelow,
    required this.onSynthesizeAllBelow,
    required this.onAddMessageBelowPressed,
    required this.onChangeSpeakerPressed,
  });

  final VoidCallback onDeleteMessagePressed;
  final VoidCallback onMoveMessageUpPressed;
  final VoidCallback onMoveMessageDownPressed;
  final VoidCallback onPlayAllBelow;
  final VoidCallback onSynthesizeAllBelow;
  final VoidCallback onAddMessageBelowPressed;
  final VoidCallback onChangeSpeakerPressed;

  @override
  Widget build(BuildContext context) => SimpleDialog(
        title: const Text('アクション選択'),
        surfaceTintColor: Colors.green, // ずんだ色にしてみた.
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(context).pop();
              onDeleteMessagePressed();
            },
            child: const ListTile(
              leading: Icon(Icons.delete_rounded),
              title: Text('削除する'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(context).pop();
              onMoveMessageUpPressed();
            },
            child: const ListTile(
              leading: Icon(Icons.move_up_rounded),
              title: Text('上に移動する'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(context).pop();
              onMoveMessageDownPressed();
            },
            child: const ListTile(
              leading: Icon(Icons.move_down_rounded),
              title: Text('下に移動する'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(context).pop();
              onPlayAllBelow();
            },
            child: const ListTile(
              leading: Icon(Icons.playlist_play_rounded),
              title: Text('ここから先をすべて再生する'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(context).pop();
              onSynthesizeAllBelow();
            },
            child: const ListTile(
              leading: Icon(Icons.graphic_eq_rounded),
              title: Text('ここから先をすべて合成する'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(context).pop();
              onAddMessageBelowPressed();
            },
            child: const ListTile(
              leading: Icon(Icons.add_comment_rounded),
              title: Text('セリフを追加する'), // せっセリフっ…！💦synthe関数で書いたことは忘れてください.
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(context).pop();
              onChangeSpeakerPressed();
            },
            child: const ListTile(
              leading: Icon(Icons.social_distance_rounded), // 😳.
              title: Text('話者を変更する\n（入力欄の話者へ）'),
            ),
          ),
        ],
      );
}

// 本家のchat.dartを見た。mainがスッキリしていい感じ。なんていう書き方かは知らん.
// TapとPressには明確な使い分けがある的な記載を見たような見てないような….
class AppBarForChat extends StatelessWidget implements PreferredSizeWidget {
  const AppBarForChat({
    super.key,
    this.onPlayTap,
    this.onStopTap,
    this.onHamburgerPress, // 🍔はプレスするものだからPress.
  });

  final VoidCallback? onPlayTap;
  final VoidCallback? onStopTap;
  final VoidCallback? onHamburgerPress;

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) => AppBar(
        title: const Text('非公式のプロジェクト', style: TextStyle(color: Colors.black54)),
        backgroundColor: Colors.white.withAlpha(230),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20), // 逆に出っ張らせたいんやが？超難しそう？.
            bottomRight: Radius.circular(20),
          ),
        ),
        actions: [
          Tooltip(
            message: '先頭から連続再生する',
            child: IconButton(
              // ←←エディターにアイコンのプレビュー出るのヤバくね！？.
              icon: const Icon(Icons.play_arrow_rounded),
              onPressed: onPlayTap,
            ),
          ),
          Tooltip(
            message: '再生を停止する',
            child: IconButton(
              icon: const Icon(Icons.stop_rounded),
              onPressed: onStopTap,
            ),
          ),
          Tooltip(
            message: 'プロジェクトのオプションを表示する',
            child: IconButton(
              icon: const Icon(Icons.more_vert_rounded),
              onPressed: onHamburgerPress,
            ),
          ),
        ],
      );
  // SliverAppBarにしたいよね😙→2時間経過→ぜんぜんわからん！😫.
  // SliverToBoxAdapter{child: SizedBox{height: 2000,child: Chat()}}}でそれっぽいとこまでいったけど、構造上求めるものはできへんのちゃうか？😨.
}

// ハンバーガーメニュー.
class HamburgerMenuForChat extends StatelessWidget {
  const HamburgerMenuForChat({
    super.key,
    this.onExportProjectPressed,
    this.onExportAsTextPressed,
    this.onDeleteAllMessagesPressed,
    this.onImportProjectPressed,
    this.onEditTextDictionaryPressed,
  });

  final VoidCallback? onExportProjectPressed;
  final VoidCallback? onDeleteAllMessagesPressed;
  final VoidCallback? onExportAsTextPressed;
  final VoidCallback? onImportProjectPressed;
  final VoidCallback? onEditTextDictionaryPressed;

  @override
  Widget build(BuildContext context) => SimpleDialog(
        title: const Text('アクション選択'),
        surfaceTintColor: Colors.green,
        children: [
          SimpleDialogOption(
            onPressed: onExportAsTextPressed,
            child: const ListTile(
              leading: Icon(Icons.list_alt_rounded),
              title: Text('テキストとして書き出す（.txt）'),
            ),
          ),
          SimpleDialogOption(
            onPressed: onExportProjectPressed,
            child: const ListTile(
              leading: Icon(Icons.output_rounded),
              title: Text('プロジェクトを書き出す（.zrproj）'),
            ),
          ),
          SimpleDialogOption(
            onPressed: onImportProjectPressed,
            child: const ListTile(
              leading: Icon(Icons.exit_to_app_rounded),
              title: Text('プロジェクトを読み込む（.zrproj）'),
            ),
          ),
          SimpleDialogOption(
            onPressed: onEditTextDictionaryPressed,
            child: const ListTile(
              leading: Icon(Icons.import_contacts_rounded),
              title: Text('読み方辞書を開く'),
            ),
          ),
          SimpleDialogOption(
            onPressed: onDeleteAllMessagesPressed,
            child: const ListTile(
              leading: Icon(Icons.delete_forever_rounded),
              title: Text('すべて削除する'),
            ),
          ),
        ],
      );
}

// ファイル書き出し機能のかわりに表示することにしたUI😖.
class AlterateOfKakidashi extends StatelessWidget {
  const AlterateOfKakidashi({
    super.key,
    required this.whatYouWantShow,
    required this.whatYouWantSetTitle,
  });
  final String whatYouWantShow;
  final String whatYouWantSetTitle;

  void _saveOnClipboard() async {
    await Clipboard.setData(ClipboardData(text: whatYouWantShow));
    await Fluttertoast.showToast(msg: 'クリップボードにコピーしました');
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(
          whatYouWantSetTitle,
          overflow: TextOverflow.fade,
          softWrap: false,
        ),
        surfaceTintColor: Colors.green,
        content: SelectableText(
          whatYouWantShow,
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          Tooltip(
            message: 'すべてコピーする',
            child: IconButton(
              onPressed: _saveOnClipboard,
              icon: const Icon(Icons.copy_rounded),
            ),
          ),
          Tooltip(
            message: '全文を共有する',
            child: IconButton(
              onPressed: () => Share.share(whatYouWantShow, subject: '$whatYouWantSetTitle.json'),
              icon: const Icon(Icons.share_rounded),
            ),
          ),
        ],
      );
} // GoogleKeepへの保存やコピー機能を搭載したがそういう処理はここに書かないはずだったのでは…？🤔.

// ↑の書き出し代替ダイアログを呼び出す関数.
void showAlterateOfKakidashi(
  BuildContext context,
  String exportingText, [
  String dialogTitle = 'はいっ、書き出した！🤔',
]) {
  showDialog<String>(
    context: context,
    builder: (_) => AlterateOfKakidashi(
      whatYouWantShow: exportingText,
      whatYouWantSetTitle: dialogTitle,
    ),
  );
}

// 入力ダイアログ。プロジェクトのインポートとかに使う。『ダイアログでもテキスト入力がしたい』🥰.
class TextEditingDialog extends StatefulWidget {
  const TextEditingDialog({super.key, this.text});
  final String? text;

  @override
  State<TextEditingDialog> createState() => _TextEditingDialogState();
}

class _TextEditingDialogState extends State<TextEditingDialog> {
  final controller = TextEditingController();
  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    controller.text = widget.text ?? ''; // TextFormFieldに初期値を代入する.
    focusNode.addListener(
      () {
        // フォーカスが当たったときに文字列が選択された状態にする.
        if (focusNode.hasFocus) {
          controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: controller.text.length,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        content: TextFormField(
          autofocus: true, // ダイアログが開いたときに自動でフォーカスを当てる.
          focusNode: focusNode,
          controller: controller,
          maxLines: null, // Nullにすると複数行の入力ができる。《セリフを追加する》のためにnullにしたがJSONインポート時はごちゃつく.
          onFieldSubmitted: (_) {
            // エンターを押したときに実行される.
            Navigator.of(context).pop(controller.text);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(controller.text);
            },
            child: const Text('完了'),
          ),
        ],
      );
}

// ↑の入力ダイアログを呼び出す関数.
Future<String?> showEditingDialog(BuildContext context, String text) async {
  final whatYouImputed = await showDialog<String>(
    context: context,
    builder: (context) => TextEditingDialog(text: text),
  );

  return whatYouImputed;
}
