// lib/wapform_session.dart
// ══════════════════════════════════════════════════════════════════
//  App-level login session -- keeps $username / password / default system
//  parameters (the sys table) alive for the whole App run, so they don't get reset just from switching pages.
//
//  Background: setvar()/expression()/condition()/dbquery() all operate through the
//  "currently bound" WapEvaluator + DataSetRegistry, and useEngine() swaps out this
//  global binding entirely. In the template, each card defaults to `new`ing its own
//  _ev/_reg (card.aa's `late final WapEvaluator _ev = widget.ev ?? WapEvaluator();`),
//  so "login page setvar('username',...) -> switch to the menu page -> the menu page
//  builds its own new _ev", and username disappears.
//
//  Solution: the whole App shares a single WapEvaluator/DataSetRegistry (this very
//  file). Login, and every page afterward that needs session info, calls
//  WapSession.bind() once before touching setvar/dbquery/expression, pointing the
//  global pointer back here. username/password/sys are then "set once at login,
//  present the whole time", without needing to re-login or re-query system parameters on every page.
//
// aa ??? (resolved, confirmed 2026-08-14)
//   Every constructor in main.dart's _pages lookup table now passes
//   `ev: WapSession.ev, reg: WapSession.reg` (replacing the old wapRegister mechanism),
//   so every card's `_ev`/`_reg` fields are the exact same object as WapSession.ev/reg here,
//   and engine variables like $username are still readable after switching pages. The
//   WapSessionScope helper widget below isn't actually used by main.dart at the moment;
//   it's kept around for scenarios that need to locally rebind the session (e.g. a dialog popup card).
// zz ??? (resolved)
// ══════════════════════════════════════════════════════════════════

import 'package:flutter/widgets.dart';

import 'package:wapform_flutter/lazarus_db.dart';
import 'package:wapform_flutter/lazarus_sqldb.dart';
import 'package:wapform_flutter/wapform_expression.dart'; // WapEvaluator/DataSetRegistry are defined here
import 'package:wapform_flutter/wapform_lazarus.dart';

const String _kSessionDb = 'shop'; // kept consistent with other pages' _kDb

class WapSession {
  WapSession._();

  static final WapEvaluator ev = WapEvaluator();
  static final DataSetRegistry reg = DataSetRegistry();

  static TWapSQLConnection? _conn;
  static TWapSQLConnection connection() {
    if (_conn == null) {
      final c = TWapSQLConnection(null, const WapDbBridgeDriver());
      c.databaseName = _kSessionDb;
      final tx = TSQLTransaction();
      tx.database = c;
      _conn = c;
    }
    return _conn!;
  }

  /// Call this once before using setvar/dbquery/expression/condition, to make sure
  /// the global pointer points back to the session's ev/reg, not something the caller just built on the spot.
  static void bind() => useEngine(ev, reg);

  static String get username => _var('username');
  static String get password => _var('password');
  static bool get isLoggedIn => username.isNotEmpty;

  static String _var(String name) {
    bind();
    final v = ev.getVar(name);
    return v == null ? '' : '$v';
  }

  // -- dbquery: the same logic as the page template (created once, then reused) --
  static TSQLQuery dbquery(String id, String sqlText) {
    bind();
    final existing = reg.find(id);
    TSQLQuery q;
    if (existing is TSQLQuery) {
      q = existing;
    } else {
      q = TSQLQuery();
      q.database = connection();
      q.name = id;
      reg.put(id, q);
    }
    if (sqlText.isNotEmpty) {
      final sql = expandSql(sqlText); // expands variables like $username
      if (q.active) q.close();
      q.unPrepare();
      q.sql.text = sql;
    }
    q.alwaysUpdateable = true;
    return q;
  }

  // -- Login --------------------------------------------------------------------
  // @@@ the check logic is [carried over verbatim] from this existing wapform.wml block, not swapped for a different hand-written comparison:
  //   <dbquery id="usr">select pwd from users where userid='$username'</dbquery>
  //   <if cnd="usr.count=0"><alert message="Account does not exist"/></if>
  //   <if cnd="upper(usr.pwd)<>upper(password)"><alert message="Password error"/></if>
  // Returns null on success; non-null is the error message to show the user (matching
  // <alert>'s message text exactly, so you can display it verbatim or localize it yourself).
  static Future<String?> login(String user, String pwd) async {
    bind();
    // Single-quote escaping: prevents a ' in the username/password from breaking setvar's value and the engine expression that follows.
    setvar('username', "'${user.replaceAll("'", "''")}'");
    setvar('password', "'${pwd.replaceAll("'", "''")}'");

    final usr =
        dbquery('usr', r"select pwd from users where userid='$username'");
    await usr.openAsync();

    if (usr.recordCount == 0) {
      return 'Account does not exist';
    }
    // @@@ calling condition() directly uses the exact same expression engine as <if cnd=>,
    //     with the exact same expression text -- upper()'s case-comparison rules won't drift from the desktop version.
    if (condition("upper(usr.pwd)<>upper(password)")) {
      return 'Password error';
    }

    await loadSystemParams();
    return null;
  }

  /// Default system parameters -- matches the pattern common to many pages,
  ///   if (!_sys.active) await _sys.openAsync();
  /// Here, it's loaded once after a successful login and put into the shared registry;
  /// other pages can afterward just reuse `WapSession.reg.findQuery('sys')`, without each page querying it separately.
  static Future<void> loadSystemParams() async {
    bind();
    final q = dbquery('sys', r'select * from sys');
    if (!q.active) await q.openAsync();
  }

  /// Logout: clears username/password, and releases every dataset the session holds
  /// (including usr, sys). The connection itself is not closed and is reused on the next login.
  static void logout() {
    bind();
    setvar('username', "''");
    setvar('password', "''");
    reg.releaseAll();
  }
}

// ══════════════════════════════════════════════════════════════════
//  WapSessionScope -- an optional helper widget.
//  Wrapped around the whole App (or around the outermost layer of each wapRegister page),
//  it calls WapSession.bind() before build, ensuring anything in the subtree that uses
//  setvar/dbquery/expression is talking to the session's global engine, without every page having to remember to call it itself.
//  This doesn't change a sub-page's own _ev/_reg field identity (that's still the page's own);
//  it only guarantees the "current global pointer" points at the session -- to actually make a page's
//  internal fields share the same instance as the session, main.dart still has to pass
//  widget.ev/widget.reg as WapSession.ev/WapSession.reg (see the aa/zz marker at the top of this file).
// ══════════════════════════════════════════════════════════════════
class WapSessionScope extends StatelessWidget {
  final Widget child;
  const WapSessionScope({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    WapSession.bind();
    return child;
  }
}
