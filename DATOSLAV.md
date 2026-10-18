# Mimic-LR (datoslav)

A personal fork of [randallspicher/skin.mimic.lr](https://github.com/randallspicher/skin.mimic.lr) for two Kodi boxes, one
on Kodi 21 (Omega) and one on Kodi 22 (Piers). The boxes' own setup is recorded elsewhere, not in this repo.

## Branches
- `datoslav` (default): our changes, based on upstream `Omega` (the Kodi 21 branch).
- `Omega`, `master`, …: upstream, untouched.

To take upstream fixes: `git fetch upstream && git merge upstream/Omega` on `datoslav`.

## Text numbers
Every text the skin defines itself is numbered 31000 to 31999. Kodi 22 looks a skin's texts up only in that
range (`$LOCALIZE[…]`, `<label>`); other numbers come out blank. Upstream `Omega` has 69 texts at 89000 to
90962 and this fork had added more up to 90965; all were moved to 31556 to 31629, in the same order. New
texts go in a free number of the range. The 9xxxx numbers still in the XML are control ids, not texts.

## Add-on id
`skin.mimic.lr.datoslav`, so Kodi treats it as a separate skin: the official repo never overwrites it, and stock
Mimic-LR (`skin.mimic.lr`) can stay installed as a fallback. Skin settings are stored per id
(`userdata/addon_data/skin.mimic.lr.datoslav/settings.xml`).

## Deploy
`./deploy.sh` (default host 10.10.101.141, wifi; pass `10.10.101.33` for Ethernet). It copies the files git tracks,
as they are in the working tree, to `/storage/.kodi/addons/skin.mimic.lr.datoslav`, rebuilds the Skin Shortcuts menu
and reloads the skin if it is active. It refuses while something is playing.

## Textures
Upstream releases pack `media/` into `media/Textures.xbt` with Kodi's TexturePacker. This fork deploys the loose
`media/` images instead, which Kodi reads directly. If menus feel slower to load, packing them is the fix.

## Box-side dependency: Skin Shortcuts patch
The combined home menu relies on a local patch to `script.skinshortcuts` 2.0.3 on the box
(`resources/lib/skinshorcuts/xmlfunctions.py`, original kept as `.orig`). For a main entry with a submenu, the
"open submenu" `SetProperty` onclick only fires while the submenu is closed. Upstream gave it the
already-open condition, so Enter did nothing. The main entries' own action (`ClearProperty(submenuVisibility,10000)`
in `shortcuts/mainmenu.DATA.xml`) fires while it is open, so Enter toggles. An add-on update overwrites the
patch; if Enter on Filmovi stops opening its submenu, re-apply it.

## Home menu
`shortcuts/mainmenu.DATA.xml` (Filmovi, Serije, Podešavanja) and the submenus in `shortcuts/*.DATA.xml`.
Nothing is customised through the menu editor on the box; a `*.DATA.xml` in
`userdata/addon_data/script.skinshortcuts/` would override these, and keep its own labels and order.

The main entries use `DatoslavMainMenuFont` (94 in the default font set, not bold); the submenu entries
`DatoslavSubMenuFont` (53, `SubMenuFont` x1.3 plus one, which the other menus keep; at 52 one box drew a
sliver of the neighbouring glyph left of every "d"), upright and indented 52 px further,
about two characters. Rows are 105 high and the menu 760 wide, so "Započeti - Nastavi gledanje" fits without
scrolling; the menu starts 114 px higher than the original, 68 px under the top bar, so eight rows fit on screen. "Serije" is the skin's own text 31967, not Kodi's "TV shows".

The Filmovi submenu is Započeti - Nastavi gledanje, Nedavno dodati filmovi, Filmovi po žanru, Svi filmovi and
Dodaj novi film; the Serije submenu Započete - Nastavi gledanje, Nedavno dodate serije, Serije po žanru, Sve
serije and Dodaj novu seriju. The last entry of each opens the lists of the video add-on
`plugin.video.videoteka` (titles that can be requested). The entry is shown only when that add-on is installed.

"Započeti - Nastavi gledanje" opens its list only when something is in progress. Otherwise
it opens a small pop-up in the style of the film pop-up, "Nema filmova koje ste započeli" (or "serija") with one
button, Povratak (`custom_1140_NoProgress.xml`), and the home screen stays. Home holds two lists, 9311 and 9312,
fed by the same paths with `limit="1"`, one pixel in size and off the screen (Kodi fills only a visible list), so
the count is known before OK; the entries' conditional actions come from `shortcuts/overrides.xml`.

## The add-on's lists
The film and show lists of `plugin.video.videoteka` open only in KeibertzPlus: every other view in
`MyVideoNav.xml` has `<visible>!$EXP[isVideotekaList]</visible>` (Kodi requires all of a control's visible
conditions), and the expression in `xml/includes.xml` is true only in that add-on's film and show lists. Kodi keeps
a view per list address with no default for an add-on, so without this each list would open in the plain list
view. The library is not affected. The add-on's choice of lists has no content type and stays in the list view.

That choice of lists (Dodaj novi, `isVideotekaMenu`) has rows of 105 instead of 120 in the two-column list
(`View_50_List.xml`, with its own "Povratak nazad" button 9065), so all 8 rows of the films' menu fit: the panel
is 735 high, which still holds 6 rows of 120. It has no scrollbar, and Right on its right column does nothing.

The top bar shows the add-on's own heading for the list (its plugin category, such as "Videoteka: Filmovi",
"Popularno" or "Pretraga: matrix") in place of "Movies", "TV Shows" or the add-on's name (`BreadcrumbsVar` in
`xml/variables.xml`). A list without a heading keeps the old label.

KeibertzPlus's poster layout draws the add-on's `badge` property as the same coloured strip as the "more like
this" row (`BadgeStrips` in `Includes_CommonValues.xml`), and the right-hand panel, where the library shows the
top actors, shows it again as a large strip. Library items have no badge, so nothing changes there. The strips
read Dostupno, Naručeno, U pripremi (videoteka's "accepted") and Odbijeno.

KeibertzPlus's line under the title (`KeibertzPlusInfoLine` in `variables.xml`) reads year, "Ocena: 8.5" and
genres, in every list, the library's too, and draws a "•" only between two of them.

The home screen shows no widgets (the cards beside the menu): the widget group is taken out of both home
layouts in `xml/Includes_Home.xml`. Skin Shortcuts still attaches a widget to every row; nothing draws it.

## Film pop-up
Opening a film's info (`DialogVideoInfo.xml`) shows a pop-up of actions first: play, or play from the beginning
and resume for a part-watched film; trailer, or a grey "Film nema najavu"; and "Više o ovom filmu...", which
shows the details page. It is the last group in that file, drawn over the page for films only, so it appears in
every view. A skin cannot change what Enter does in one view.

- The pop-up's buttons click Kodi's own buttons on the page underneath: 8 (play), 9 (resume), 11 (trailer).
  Button 9 is the fork's addition; while it exists Kodi makes 8 always start from the beginning instead of
  asking. That also holds for episodes.
- "Details" sets the window property `datoslav.details` on `movieinformation`; it is cleared when the page closes.
- Back on the details page returns to the pop-up on its last row (include `FilmDetailsBack`, on the page's lists,
  scrollbars and button group). It needs both a move to that row and `allowhiddenfocus` on the pop-up: with
  only actions, Kodi runs them and closes the page anyway, and a hidden group refuses focus.
- The pop-up always opens on its first row; the page's `onload` focuses it by id.
- Each selectable row is a group holding the include `FilmPopupRow`: the button with its own text made
  invisible, the text drawn over it (regular, or bold with focus, which a button cannot do itself) and
  `FilmPopupFocusMarks` (white frame and pointers). The button's actions are written inside the include tag and
  land at `<nested />`, which Kodi fills only when it is a direct child of a top-level control of the include.
- Up and down moves are written on every button. Left to the group list, focus would not step over the grey
  row, which is a picture and text, not a button.

## Details page
The details page (`DialogVideoInfo.xml`) is cut down to what you read before choosing what to watch next. A
film's, show's or episode's page has no poster: the info lines sit on the left and the description, which
scrolls by itself, on the right, side by side; the "more like this" row runs along the bottom under the heading
"Možda će ti se svideti i ovo", which shows only once the row holds this title's suggestions. Its posters are
225 x 337 with their names in `font16`. The film's or show's title, bold in `font30`, starts about 72 px under the top
bar; a title too long for the left column is cut with "…" rather than scrolled, so the page stays still. The info
lines start under it (list 62 at 204). The row starts at 546, so that its
two-line titles end 72 px above the bottom of the screen, the same space as under the top bar, and the description
(textbox 400) is 425 high and scrolls by itself. The focused poster has
an 18 px frame (a plate of `listselect_fo.png` 18 px larger than the poster on each side). A panel clips its items
at its own edges, so `MoreLikeThisItem` sets the poster 18 px in and 3 px down and the panel sits that much further
out; otherwise the first poster's frame is cut off on the left. The backdrop is dimmed by the same overlay as the
lists (`CommonBackground`). Playing, resuming
and the trailer are in the film pop-up.

- The info lines differ per type: a film shows year, length, rating, genre and director; a show its premiere,
  rating, genre and a seasons line ("1 sezona · 8 epizoda · 8 neodgledano", with the Serbian plural from
  `MltSeasonsWord` and `MltEpisodesWord` in `variables.xml`); an episode its premiere, length and rating.
- The row (panel 350) is filled by the video add-on `plugin.video.videoteka`, whose item paths open its own
  pop-up. Each item has the properties `badge` (`available`, `requested`, `accepted`, `declined` or empty, drawn
  as a coloured strip) and `row.for`. The row is always visible, because Kodi does not fill a hidden list; an
  empty one draws nothing.
- Kodi keeps the previous title's items until the new list arrives. The page sets `datoslav.rowfor` on
  `movieinformation` to `<type>-<dbid>` when it opens, and an item is drawn only when its `row.for` matches.
- Focus starts on the row. "Više o ovom filmu..." in the film pop-up puts focus on the row, or on the invisible
  button 9600 when the row is empty, so Back still returns to the pop-up.
- A show's page has one button, "Ostale sezone" (9601), which opens the add-on's pop-up for the show itself.
  Up from the row goes to it, down from it to the row. When the row loads empty, the timer in `Timers.xml`
  moves focus to it.
- The description gets the full height once the row has loaded empty (textbox 401 instead of 400).
- KeibertzPlus draws no name above the posters in the videoteka add-on's lists (`isVideotekaList`); the
  library's show lists keep theirs.
- Kodi's own buttons (grouplist 9000) are hidden, not removed: the film pop-up clicks 8, 9 and 11, and the
  page's `onload` clicks 5.
