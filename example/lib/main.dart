// lib/main.dart
// ══════════════════════════════════════════════════════════════════
//  App entry point -- login -> dynamic menu.
//
//  The menu is [fully dynamic]: how many levels, how many groups, which items,
//  their order, titles, and who can use them are all driven by the mnu / login
//  tables (matching wapform.wml's <mainmenu> behavior). Changing the menu only
//
//  means changing data -- this file never needs to change.
//
//  The one thing that has to be hardcoded here is the _pages lookup table below --
//  Dart has no runtime reflection (dart:mirrors is disabled in Flutter), so a string
//  like "app006" cannot be turned into an instance of its class, so the string-to-
//  constructor binding has to exist at compile time. This is what Flutter's
//  tree-shaking depends on -- not a design choice that can be worked around.
//  Adding a new page means adding a line to this table (or generating this block with a batch tool).
//
// aa ??? old architecture retired
//   wap_routes.dart (wapRegister/wapRoutes/wapOpenPage) and wapform.dart
//   (the hand-written card-style icon menu) have been replaced by this file's
//   _pages lookup table and wapform_menu.dart's WapMainMenu (the dropdown menu).
//   The two implementations should not coexist (to avoid them drifting apart when one
//   is edited and the other is forgotten). Please delete these two files from the
//   project directly -- nothing references them anymore.
// zz ??? old architecture retired
//
// aa ??? class names updated to the App* prefix
//   The previous version used the Agp* prefix here, a leftover from a rename that
//   did not get synced. This time each of the 12 newly-exported files' class names has
//   been confirmed correct (App001CardP, App003CardP... no longer all colliding into
//   one), and all of them have been changed to App* to match the actual file contents.
//   app002 is also no longer a placeholder mock page -- it is real exported content now
//   (it has ev/reg parameters), so it is wired in too. app012's report dbquery() was
//   already fixed in r63; confirmed the new file really has that method, so it is wired
//   back in. app006.dart's main card class is App006CardP (the file itself has 18
//   classes -- it is a large multi-card/report file, and only the main card is wired here).
// zz ???
//
// aa ??? app901/app902 wired back in (formerly user.wml/menu.wml, renamed)
//   What was previously diagnosed as a "cross-card scope issue" was actually a
//   misdiagnosis -- the real root cause was two bugs in the generator, flutter.pas
//   (fixed in r65):
//   (1) FindOutput mistook an <output> nested inside <onevent> for the card body's
//       report, causing the entire <dbtable>/<datasource> edit screen to be skipped
//       (the P card was missing fields like _usersSrc/_mnuSrc/_loginSrc)
//   (2) In DoReplace, EVENT_METHODS was computed before DO_BUTTONS, so a
//       <go href="#Pn"/> only generated the callers _goPn(), not the method body
//       (the P1 card's Print button).
//   Wiring this back in assumes wap.exe has already been recompiled with r65's
//   flutter.pas, and app901.dart/app902.dart re-exported. If these are still files
//   exported by the old version, both symptoms will reappear as-is -- that is not a
//   mistake in this wiring.
// zz ???
// ══════════════════════════════════════════════════════════════════
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

import 'wapform_login.dart';
import 'wapform_menu.dart';
import 'wapform_session.dart';

// -- Pages (corresponding to mnu.href, the 12 rows with active=1) --------------
import 'app001.dart';
import 'app002.dart';
import 'app003.dart';
import 'app004.dart';
import 'app005.dart';
import 'app006.dart';
import 'app007.dart';
import 'app012.dart';
import 'app023.dart';
import 'app037.dart';
import 'app901.dart';
import 'app902.dart';
import 'function.dart'; // WapForm expression engine self-test report (function.wml)

/// String -> page constructor. The key is mnu.href with .wml and any ?query stripped.
///
/// ev/reg are always passed WapSession's shared instance: if each page created its own
/// WapEvaluator/DataSetRegistry, it would not be the same one setvar('username',...) wrote
/// to at login, and any $username usage inside the page would fail to read the value.
final Map<String, WidgetBuilder> _pages = {
  'app001': (_) => App001CardP(ev: WapSession.ev, reg: WapSession.reg),
  'app002': (_) => App002CardP(ev: WapSession.ev, reg: WapSession.reg),
  'app003': (_) => App003CardP(ev: WapSession.ev, reg: WapSession.reg),
  'app004': (_) => App004CardP(ev: WapSession.ev, reg: WapSession.reg),
  'app005': (_) => App005CardP(ev: WapSession.ev, reg: WapSession.reg),
  'app006': (_) => App006CardP(ev: WapSession.ev, reg: WapSession.reg),
  'app007': (_) => App007CardP(ev: WapSession.ev, reg: WapSession.reg),
  'app012': (_) => App012CardP(ev: WapSession.ev, reg: WapSession.reg),
  'app023': (_) => App023CardP(ev: WapSession.ev, reg: WapSession.reg),
  'app037': (_) => App037CardP(ev: WapSession.ev, reg: WapSession.reg),
  'app901': (_) => App901CardP(ev: WapSession.ev, reg: WapSession.reg),
  'app902': (_) => App902CardP(ev: WapSession.ev, reg: WapSession.reg),
  // Not a real mnu.href row -- a dev/diagnostic page (the expression-engine self-test
  // report from function.wml). Not menu-driven, so it needs its own opening path;
  // see the debug-only entry point wired in below.
  'function': (_) => FunctionCardP1(ev: WapSession.ev, reg: WapSession.reg),
};

void main() => runApp(const WapApp());

class WapApp extends StatelessWidget {
  const WapApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
        title: 'WapForm',
        debugShowCheckedModeBanner: false,
        home: _AppRoot(),
      );
}

// -- Login -> main menu --------------------------------------------------------
// wapform.wml's original checks (does the account exist? is the password right?) run
// as-is inside WapSession.login(); this file only handles screen switching and logout.
class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  bool _loggedIn = false;

  void _openPage(BuildContext context, String pageId, String href) {
    final builder = _pages[pageId];
    if (builder == null) {
      // When a menu item cannot be linked to a page, it needs to be visible, not fail
      // silently -- if the mnu table's href does not match an actual filename
      // (e.g. a missed conversion or a typo), this says exactly which one it is.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Page not found: $pageId (href=$href)'),
        backgroundColor: Colors.red.shade700,
      ));
      return;
    }
    showDialog(context: context, barrierDismissible: false, builder: builder);
  }

  void _logout() {
    WapSession.logout();
    setState(() => _loggedIn = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loggedIn) {
      return WapLoginCard(
        onLoginSuccess: (_, __) => setState(() => _loggedIn = true),
      );
    }
    return WapMainMenu(
      onNavigate: _openPage,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${WapSession.username}, please choose an action from the menu above'),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: _logout, child: const Text('Log Out')),
            // Debug-only: 'function' has no mnu.href row (it's the expression-engine
            // self-test report, not a real menu item), so it can't be reached through
            // WapMainMenu's normal onNavigate/mnu-table-driven path. This button is the
            // entry point promised in the _pages comment above -- stripped out of
            // release builds by kDebugMode, same as any other debug-only affordance.
            if (kDebugMode) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _openPage(context, 'function', 'function.wml'),
                child: const Text('[debug] Function self-test report'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
