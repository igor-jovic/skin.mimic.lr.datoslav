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
`shortcuts/mainmenu.DATA.xml` (Filmovi, TV serije, Podešavanja) and the submenus in `shortcuts/*.DATA.xml`.
Nothing is customised through the menu editor on the box; a `mainmenu.DATA.xml` in
`userdata/addon_data/script.skinshortcuts/` would override these.

The Filmovi and TV serije submenus end with "Dodaj novi", which opens the lists of the video add-on
`plugin.video.videoteka` (titles that can be requested). The entry is shown only when that add-on is installed.

## The add-on's lists
The film and show lists of `plugin.video.videoteka` open only in KeibertzPlus: every other view in
`MyVideoNav.xml` has `<visible>!$EXP[isVideotekaList]</visible>` (Kodi requires all of a control's visible
conditions), and the expression in `xml/includes.xml` is true only in that add-on's film and show lists. Kodi keeps
a view per list address with no default for an add-on, so without this each list would open in the plain list
view. The library is not affected. The add-on's choice of lists has no content type and stays in the list view.

KeibertzPlus's poster layout draws the add-on's `badge` property as the same coloured strip as the "more like
this" row (`BadgeStrips` in `Includes_CommonValues.xml`). Library items have no badge, so nothing changes
there.

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
The details page (`DialogVideoInfo.xml`) is cut down to what you read before choosing what to watch next: info
lines that fit one page, a description of about 4 lines that scrolls by itself, and a "more like this" row of
suggested titles at the bottom. Playing, resuming and the trailer are in the film pop-up.

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
- Kodi's own buttons (grouplist 9000) are hidden, not removed: the film pop-up clicks 8, 9 and 11, and the
  page's `onload` clicks 5.
