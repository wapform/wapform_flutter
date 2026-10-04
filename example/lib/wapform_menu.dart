// lib/wapform_menu.dart
// ══════════════════════════════════════════════════════════════════
//  A persistent, collapsible left-side menu -- replaces wapform.wml's <mainmenu>.
//
//  The query logic is carried over as-is from wapform.wml's existing nested <while>s;
//  only the outer presentation changed this time (from a two-level MenuBar/SubmenuButton
//  dropdown to a collapsible folder list, matching the look of an open-source example
//
//  system the user specified):
//
//    Level 1 (groups): select id, title from mnu
//                     where activate=1 and sub=-1 order by id
//    Level 2 (items):  select mnu.id, mnu.title, mnu.href, login.uid, login.w
//                     from mnu left join login
//                       on mnu.id=login.id and login.uid='$username'
//                     where mnu.activate=1 and mnu.sub=$groupId
//                     order by mnu.id
//
//  Permissions: only clickable when login.w>0; no login row at all (LEFT JOIN yields NULL) counts as w<=0.
//  This matches wapform.wml's `I:=-1; if itm.w>0 then I:=itm.w; setprop enabled=0
//  if I=-1` rule -- adding a new menu item in mnu.wml automatically creates a
//  login row for every user (defaulting to w=1), so the "usable by default, disabled only when explicitly turned off" semantics stays unchanged.
//
//  Items without permission are [shown but grayed out], not hidden entirely -- matching <author/>'s
//  behavior (the widget is shown but locked); the same convention is followed here.
//
// aa ??? r68 redesign: switched to a collapsible list (was a two-level dropdown MenuBar)
//   The user specified matching the look of a minimalist open-source example system:
//   a persistent, expandable left-side folder list, folder icon + chevron, a dark-blue
//   "WapForm" top bar, with a light-gray page code (like app001) next to each item for reference.
//   The data query / permission logic (_load(), the mnu/login join, only clickable when
//   w>0) is completely untouched -- only build()'s rendering changed, to avoid accidentally breaking already-working logic.
//   The three existing interfaces hrefToPageId()/WapMenuItem/WapMenuGroup are kept, so
//   main.dart doesn't need to change how it calls this widget.
// zz ??? r68 redesign
// ══════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import 'package:wapform_flutter/lazarus_db.dart';
import 'package:wapform_flutter/lazarus_sqldb.dart';
import 'wapform_session.dart';

String _fieldStr(TDataSet ds, String name) =>
    ds.findField(name)?.asString ?? '';

int _fieldInt(TDataSet ds, String name) {
  final f = ds.findField(name);
  if (f == null || f.isNull) return 0;
  return int.tryParse(f.asString) ?? 0;
}

// -- Data model (unchanged -- main.dart depends on these types/functions) ------
class WapMenuItem {
  final String id;
  final String title;
  final String href;
  final bool enabled;
  const WapMenuItem(
      {required this.id,
      required this.title,
      required this.href,
      required this.enabled});
}

class WapMenuGroup {
  final String id;
  final String title;
  final List<WapMenuItem> items;
  const WapMenuGroup(
      {required this.id, required this.title, required this.items});
}

/// href="agp006.wml?op=cli" → "agp006"
/// Matches main.dart's _pages["agp006"], which uses exactly this key.
String hrefToPageId(String href) {
  var s = href.trim();
  final q = s.indexOf('?');
  if (q >= 0) s = s.substring(0, q);
  final slash = s.lastIndexOf('/');
  if (slash >= 0) s = s.substring(slash + 1);
  if (s.toLowerCase().endsWith('.wml')) {
    s = s.substring(0, s.length - 4);
  }
  return s;
}

// -- Layout colors -- shares the WapForm brand blue with other pages; do not invent a new palette --
const _kBlue = Color(0xFF1A6FB5);
const _kBlueLight = Color(0xFFEAF2FA);
const _kBorder = Color(0xFFE3E1DA);
const _kPageBg = Color(0xFFF2F1ED);
const _kTextMuted = Color(0xFF9A9890);

// ══════════════════════════════════════════════════════════════════
//  WapMainMenu
// ══════════════════════════════════════════════════════════════════
class WapMainMenu extends StatefulWidget {
  /// Called when a valid item is tapped, passing the page id after hrefToPageId() conversion.
  final void Function(BuildContext context, String pageId, String href)
      onNavigate;

  /// The screen's main body outside the menu (e.g. logged-in-user info / logout button), still placed below the menu list.
  final Widget body;

  const WapMainMenu({
    super.key,
    required this.onNavigate,
    required this.body,
  });

  @override
  State<WapMainMenu> createState() => _WapMainMenuState();
}

class _WapMainMenuState extends State<WapMainMenu> {
  bool _loading = true;
  String? _error;
  List<WapMenuGroup> _groups = const [];

  // Which groups are currently expanded -- multiple groups can be expanded at once, not an accordion-style exclusive toggle.
  final Set<String> _expanded = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  // -- Data loading: identical to before the redesign, this logic was not touched --------
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    TSQLQuery? groupQ;
    try {
      groupQ = WapSession.dbquery('mnuGroups',
          'select id, title from mnu where activate=1 and sub=-1 order by id');
      await groupQ.openAsync();

      final groups = <WapMenuGroup>[];

      while (!groupQ.eof) {
        final gid = _fieldStr(groupQ, 'id');
        final gtitle = _fieldStr(groupQ, 'title');

        final itemQ = WapSession.dbquery('mnuItems', '''
          select mnu.id, mnu.title, mnu.href, login.uid, login.w
          from mnu left join login
            on mnu.id = login.id and login.uid = '\$username'
          where mnu.activate = 1 and mnu.sub = $gid
          order by mnu.id
        ''');
        try {
          await itemQ.openAsync();
          final items = <WapMenuItem>[];
          while (!itemQ.eof) {
            final w = _fieldInt(itemQ, 'w');
            items.add(WapMenuItem(
              id: _fieldStr(itemQ, 'id'),
              title: _fieldStr(itemQ, 'title'),
              href: _fieldStr(itemQ, 'href'),
              enabled: w > 0, // @@@ no login row (LEFT JOIN NULL) -> w=0 -> grayed out
            ));
            itemQ.next();
          }
          if (items.isNotEmpty) {
            groups.add(WapMenuGroup(id: gid, title: gtitle, items: items));
          }
        } finally {
          itemQ.close();
        }

        groupQ.next();
      }

      if (mounted) setState(() => _groups = groups);
    } catch (e) {
      if (mounted) setState(() => _error = 'Failed to load menu: $e');
    } finally {
      groupQ?.close();
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toggle(String groupId) {
    setState(() {
      if (_expanded.contains(groupId)) {
        _expanded.remove(groupId);
      } else {
        _expanded.add(groupId);
      }
    });
  }

  // -- Top bar: dark-blue "WapForm" + refresh button top-right --------------------
  PreferredSizeWidget _buildAppBar() => AppBar(
        backgroundColor: _kBlue,
        elevation: 0,
        titleSpacing: 20,
        title: const Text('WapForm',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            tooltip: 'Refresh menu',
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loading ? null : _load,
          ),
          const SizedBox(width: 8),
        ],
      );

  // -- A single group (folder row + item list when expanded) -----------------------
  Widget _buildGroup(WapMenuGroup g) {
    final open = _expanded.contains(g.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: open ? _kBlue : _kBorder, width: open ? 1.4 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => _toggle(g.id),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: open ? _kBlue : _kBlueLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      open ? Icons.folder : Icons.folder_outlined,
                      size: 16,
                      color: open ? Colors.white : _kBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(g.title,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                  Text('${g.items.length}',
                      style: const TextStyle(fontSize: 13, color: _kTextMuted)),
                  const SizedBox(width: 6),
                  Icon(
                    open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: _kTextMuted,
                  ),
                ],
              ),
            ),
          ),
          if (open)
            Column(
              children: [
                for (final it in g.items) _buildItem(it),
              ],
            ),
        ],
      ),
    );
  }

  // -- A single item row (only visible once expanded) ------------------------------
  Widget _buildItem(WapMenuItem it) {
    final pageId = hrefToPageId(it.href);
    final color = it.enabled ? const Color(0xFF2C2C2A) : _kTextMuted;
    return InkWell(
      onTap: it.enabled
          ? () => widget.onNavigate(context, pageId, it.href)
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: _kBorder)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 40), // aligns with the folder icon's indent
            Icon(Icons.chevron_right,
                size: 18, color: it.enabled ? _kBlue : _kTextMuted),
            const SizedBox(width: 6),
            Expanded(
              child: Text(it.title,
                  style: TextStyle(fontSize: 14, color: color)),
            ),
            if (pageId.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEEE9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  pageId,
                  style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: _kTextMuted),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: _buildAppBar(),
        backgroundColor: _kPageBg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: _buildAppBar(),
        backgroundColor: _kPageBg,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              FilledButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: _kPageBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final g in _groups) _buildGroup(g),
                const SizedBox(height: 16),
                widget.body,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
