// lib/wap/wapform_filter.dart
//
// @@@ 2026-08-10: renamed from lib/widgets/wap_filter.dart and wired into
// the WML→Flutter generator. <dbfilter result="R"><item field= size=/>…
// <onevent type="onfilter"><dbquery>...</dbquery></onevent></dbfilter>
// now translates to this widget (see EmitDbFilter in flutter.pas). Field
// labels come from the dataset's displaylabel automatically; sqlTemplate
// is taken verbatim from the onfilter handler's <dbquery> text, which
// already contains the literal "$R" token this widget's onQuery/onSearch
// logic replaces.
import 'package:flutter/material.dart';

class FilterItem {
  final String field;
  final String label;
  final int size;

  const FilterItem({
    required this.field,
    required this.label,
    this.size = 16,
  });
}

class WapFilter extends StatefulWidget {
  final double? width; // nullable: can be omitted by the caller
  final List<FilterItem> items;
  final String sqlTemplate;
  final Function(String sql) onQuery;
  final Color borderColor;

  const WapFilter({
    Key? key,
    this.width, // no default of 700 -- left for the caller to decide; fills automatically if unset
    required this.items,
    required this.sqlTemplate,
    required this.onQuery,
    this.borderColor = const Color(0xFFD3D1C7),
  }) : super(key: key);

  @override
  State<WapFilter> createState() => _WapFilterState();
}

class _WapFilterState extends State<WapFilter> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (var item in widget.items) {
      _controllers[item.field] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleClear() {
    setState(() {
      for (var controller in _controllers.values) {
        controller.clear();
      }
    });
    widget.onQuery(widget.sqlTemplate.replaceAll('\$R', '1=1'));
  }

  /// Escapes single quotes -- a user typing ' into a search box would
  /// otherwise break the SQL string literal, at best causing a query
  /// error and at worst letting them construct a malicious condition.
  /// The same escaping WML's SQL_WHERE does via REPLACE().
  String _sq(String v) => v.replaceAll("'", "''");

  void _handleSearch() {
    List<String> conditions = [];

    _controllers.forEach((field, controller) {
      String value = controller.text.trim();
      if (value.isNotEmpty) {
        if (value.contains('~')) {
          final parts = value.split('~');
          String start = parts.isNotEmpty ? _sq(parts[0].trim()) : '';
          String end = parts.length > 1 ? _sq(parts[1].trim()) : '';

          if (start.isNotEmpty && end.isNotEmpty) {
            conditions.add("($field >= '$start' and $field <= '$end')");
          } else if (start.isNotEmpty && end.isEmpty) {
            conditions.add("$field >= '$start'");
          } else if (start.isEmpty && end.isNotEmpty) {
            conditions.add("$field <= '$end'");
          }
        } else if (value.contains('%')) {
          conditions.add("$field like '${_sq(value)}'");
        } else {
          conditions.add("$field = '${_sq(value)}'");
        }
      }
    });

    String rSubstitution = conditions.isNotEmpty ? conditions.join(' and ') : '1=1';
    String finalSql = widget.sqlTemplate.replaceAll('\$R', rSubstitution);
    widget.onQuery(finalSql);
  }

  @override
  Widget build(BuildContext context) {
    const kLabel = Color(0xFF888780);
    const kBlue = Color(0xFF1A6FB5);

    // @@@ 2026-08-22 layout changed to match the desktop version
    // (Delphi/Lazarus TCard._dbfilter).
    //
    //   Matching the original source's placement:
    //     Btn (search)     Left := Q                       <- leftmost, first row
    //     CLR (clear)      Left := Q + Btn.Width + 10
    //     curLabel (hint)  Left := Q + Btn.Width + CLR.Width + Q*2
    //                      Top  := PrevTop + (Btn.Height - Height) div 2 + 1
    //                      Font.Size := LabelFont.Size - 1   <- one size smaller than the field labels
    //     fields           start only after PrevTop := PrevTop + Btn.Height + 5
    //
    //   The previous version placed the buttons *after* the fields, with
    //   the hint text on its own line -- inconsistent with the desktop
    //   version (see the side-by-side screenshots). Changed to the same
    //   structure: row one is Search/Clear/hint text, row two onward is
    //   the search fields.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Container(
        // uses widget.width if given, otherwise fills the parent form
        width: widget.width ?? double.infinity,
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F4F0),
          border: Border.all(color: widget.borderColor),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // -- Row one: Search / Clear / syntax hint (same row as the desktop version) --
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _filterBtn(
                    label: 'Search',
                    icon: Icons.search,
                    color: kBlue,
                    onPressed: _handleSearch),
                const SizedBox(width: 10), // Pascal: Left := Q + Btn.Width + 10
                _filterBtn(
                    label: 'Clear',
                    icon: Icons.clear,
                    color: const Color(0xFF6B6B6B),
                    onPressed: _handleClear),
                const SizedBox(width: 20), // Pascal: + Q*2
                // @@@ Text content and segment order follow the Pascal
                //     original -- don't reorder it:
                //     '| A = equals | A~Z = range | A~ = from | ~Z = to || %A% = contains | A% = starts with | %A = ends with |'
                const Expanded(
                  child: Text(
                    '| A = equals | A~Z = range | A~ = from | ~Z = to '
                    '|| %A% = contains | A% = starts with | %A = ends with |',
                    style: TextStyle(fontSize: 10, color: kLabel),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5), // Pascal: PrevTop + Btn.Height + 5

            // -- Row two onward: search fields (label on top, edit below) --
            Wrap(
              spacing: 5.0, // Pascal: curLineWidth + … + 5
              runSpacing: 10.0, // Pascal: +5 +5 on wrap
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                ...widget.items.map((item) {
                  return SizedBox(
                    width: _fieldWidth(item.size),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(item.label,
                            style:
                                const TextStyle(fontSize: 11, color: kLabel)),
                        const SizedBox(height: 3),
                        SizedBox(
                          height: 30,
                          child: TextField(
                            controller: _controllers[item.field],
                            style: const TextStyle(fontSize: 13),
                            onSubmitted: (_) => _handleSearch(),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 0),
                              border: _ob(widget.borderColor),
                              enabledBorder: _ob(widget.borderColor),
                              focusedBorder: _ob(kBlue, focused: true),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Field width -- follows Pascal's formula exactly, don't invent a
  /// different one:
  ///   curFieldDisplayWidth := Round(Siz * 2)   field length doubled
  ///   clamped between 10 and 30
  ///   curFieldEditWidth := (width + 1) * 7 + 3    7px per character
  double _fieldWidth(int size) {
    var w = (size * 2).round();
    if (w > 30) w = 30;
    if (w < 10) w = 10;
    return (w + 1) * 7.0 + 3;
  }

  Widget _filterBtn({required String label, required IconData icon, required Color color, required VoidCallback onPressed}) =>
    SizedBox(height: 30,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 14),
        label: Text(label, style: const TextStyle(fontSize: 13)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color, foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          elevation: 0),
      ),
    );

  OutlineInputBorder _ob(Color color, {bool focused = false}) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(4),
    borderSide: BorderSide(color: color, width: focused ? 1.5 : 1.0),
  );
}