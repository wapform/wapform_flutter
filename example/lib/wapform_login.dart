// lib/wapform_login.dart
// ══════════════════════════════════════════════════════════════════
//  登入畫面 —— 對照桌面版 WapToolkit 的「WAPFORM Connect」對話框重現。
//
//  驗證邏輯【不在這個檔案裡】——全部委派給 wapform_session.dart 的
//  WapSession.login()，那裡才是唯一一份「照搬 wapform.wml 判斷邏輯」
//  的地方。這裡只管畫面與使用者互動，不重複刻一份 SQL 比對，避免兩處
//  各自為政、以後改一邊忘了改另一邊。
//
// aa ??? 安全性假設（需要你確認，不是默默決定）
//   「Remember credentials」目前只記住 USERNAME，不記住密碼明文。
//   桌面版 WapToolkit 的畫面設計看起來是全部記住（含密碼），這裡刻意收斂成
//   較安全的做法。如果要跟桌面版完全一致（含密碼），把 _CredentialStore 的
//   save() 呼叫加回 password 欄位即可，見下方標記處。
// zz ??? 安全性假設
// ══════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import 'wapform_session.dart';

// ══════════════════════════════════════════════════════════════════
//  記住登入資訊 —— 可替換的儲存介面。
//  預設是純記憶體（只在本次 App 執行期間有效，關掉重開就沒了）。
//  要跨執行期記住，換一個實作（例如包 shared_preferences）指派給
//  WapLoginCard.store 即可，介面不用改。
// ══════════════════════════════════════════════════════════════════
class WapSavedCredentials {
  final String username;
  const WapSavedCredentials({this.username = ''});
}

abstract class WapCredentialStore {
  Future<WapSavedCredentials?> load();
  Future<void> save(WapSavedCredentials cred);
  Future<void> clear();
}

/// 預設實作：只存在記憶體裡，App 重啟就消失。
/// 要換成真正跨執行期保存，實作同一個介面、包 shared_preferences 即可。
class InMemoryCredentialStore implements WapCredentialStore {
  static WapSavedCredentials? _cached;

  @override
  Future<WapSavedCredentials?> load() async => _cached;

  @override
  Future<void> save(WapSavedCredentials cred) async => _cached = cred;

  @override
  Future<void> clear() async => _cached = null;
}

// ══════════════════════════════════════════════════════════════════
//  WapLoginCard
// ══════════════════════════════════════════════════════════════════
class WapLoginCard extends StatefulWidget {
  /// 登入成功後呼叫，帶回通過驗證的 userid。
  /// 由呼叫端決定接下來要導去哪裡（例如 push WapMainMenu）。
  final void Function(BuildContext context, String username) onLoginSuccess;

  /// 視窗左下角的版本字串（對照截圖「v1.1.8840.43106」）。
  final String buildLabel;

  final WapCredentialStore store;

  const WapLoginCard({
    super.key,
    required this.onLoginSuccess,
    this.buildLabel = 'v1.1.8840.43106',
    this.store = const _StoreHolder(),
  });

  @override
  State<WapLoginCard> createState() => _WapLoginCardState();
}

// DropdownMenu 需要 const 建構子的預設值，這裡用一個小 holder 繞過
// 「不能在 const 建構子預設值裡 new 一個非 const 物件」的限制。
class _StoreHolder implements WapCredentialStore {
  const _StoreHolder();
  static final _real = InMemoryCredentialStore();
  @override
  Future<WapSavedCredentials?> load() => _real.load();
  @override
  Future<void> save(WapSavedCredentials cred) => _real.save(cred);
  @override
  Future<void> clear() => _real.clear();
}

class _WapLoginCardState extends State<WapLoginCard> {
  final _userCtl = TextEditingController();
  final _pwdCtl = TextEditingController();
  final _userFocus = FocusNode();

  bool _remember = true;
  bool _obscure = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _restore();
    // 對照截圖：USERNAME 欄位一進畫面就是焦點（反白的 "admin"）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _userFocus.requestFocus();
    });
  }

  Future<void> _restore() async {
    final saved = await widget.store.load();
    if (saved == null || !mounted) return;
    setState(() {
      if (saved.username.isNotEmpty) _userCtl.text = saved.username;
    });
  }

  @override
  void dispose() {
    _userCtl.dispose();
    _pwdCtl.dispose();
    _userFocus.dispose();
    super.dispose();
  }

  // ── 驗證：委派給 WapSession（唯一一份判斷邏輯）──────────────────
  Future<void> _connect() async {
    final username = _userCtl.text.trim();
    final password = _pwdCtl.text;
    if (username.isEmpty) {
      setState(() => _error = '請輸入帳號');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final err = await WapSession.login(username, password);
      if (err != null) {
        setState(() => _error = err);
        return;
      }

      if (_remember) {
        // aa ??? 安全性假設：只存 username，密碼明文不落地。
        //     要比照桌面版存密碼，在這裡加 password 欄位即可。
        await widget.store.save(WapSavedCredentials(username: username));
        // zz ??? 安全性假設
      } else {
        await widget.store.clear();
      }

      if (!mounted) return;
      widget.onLoginSuccess(context, username);
    } catch (e) {
      if (mounted) setState(() => _error = '連線失敗：$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _cancel() {
    // 桌面版對話框的 Cancel 是關視窗；Flutter 頁面沒有等價動作時，
    // 交給呼叫端決定（例如 pop，如果是被 push 進來的）。
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  // ── 版面 ──────────────────────────────────────────────────────
  static const _labelStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: .4,
    color: Color(0xFF5F5E5A),
  );

  Widget _field({
    required String label,
    required Widget child,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: _labelStyle),
            const SizedBox(height: 4),
            child,
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4F0),
      // @@@ 手機跳出鍵盤時可用高度會變小，登入卡片（標題+欄位+checkbox+
      //     按鈕）原本固定貼在畫面中間、沒辦法自動收縮，鍵盤跳出就會把
      //     內容往上推、超出螢幕底部（overflowed by 109 pixels on the
      //     bottom）。用 SingleChildScrollView 包起來，鍵盤跳出時改用捲動。
      //
      // @@@ 2026-08-22：但單純包 SingleChildScrollView 會讓內容高度變成
      //     「依內容而定」，裡面的 Center 沒有多餘空間可用，卡片就貼到
      //     畫面頂端去了。改用 LayoutBuilder 取得可用高度，再用
      //     ConstrainedBox(minHeight) 把捲動內容撐到至少滿一頁——
      //     空間夠時 Center 有空間可以垂直置中；鍵盤跳出、空間不夠時，
      //     內容超過 minHeight 就照常捲動，兩種情況都成立。
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                    child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 標題列 ──
                  const Row(
                    children: [
                      Icon(Icons.dns_outlined,
                          size: 20, color: Color(0xFF1A6FB5)),
                      SizedBox(width: 8),
                      Text('WAPFORM Connect',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // ── USERNAME ──
                  _field(
                    label: 'USERNAME',
                    child: TextField(
                      controller: _userCtl,
                      focusNode: _userFocus,
                      onSubmitted: (_) => _connect(),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),

                  // ── PASSWORD ──
                  _field(
                    label: 'PASSWORD',
                    child: TextField(
                      controller: _pwdCtl,
                      obscureText: _obscure,
                      onSubmitted: (_) => _connect(),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          iconSize: 18,
                          icon: Icon(_obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),
                  ),

                  // ── Remember credentials ──
                  InkWell(
                    onTap: () => setState(() => _remember = !_remember),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: _remember,
                          visualDensity: VisualDensity.compact,
                          onChanged: (v) =>
                              setState(() => _remember = v ?? true),
                        ),
                        const Text('Remember credentials',
                            style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(_error!,
                        style: const TextStyle(
                            color: Colors.red, fontSize: 12.5)),
                  ],

                  const SizedBox(height: 18),

                  // ── 底部：版本字串 + Connect / Cancel ──
                  Row(
                    children: [
                      // @@@ 手機窄螢幕（例如 344px 可用寬度）下，版本字串+
                      //     兩個按鈕加起來會超出，用 Flexible 讓版本字串
                      //     可以縮小/省略，不要逼 Row 溢出。
                      Flexible(
                        child: Text(widget.buildLabel,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 10.5, color: Color(0xFFB3B1A9))),
                      ),
                      const Spacer(),
                      OutlinedButton(
                        onPressed: _busy ? null : _cancel,
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _busy ? null : _connect,
                        child: _busy
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Connect'),
                      ),
                    ],
                  ),
                ],
              ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
