# Mimic-LR (datoslav)

A personal fork of [randallspicher/skin.mimic.lr](https://github.com/randallspicher/skin.mimic.lr) for the x96mini Kodi box
(LibreELEC 12 / Kodi 21 Omega). The box's setup lives in the `x96mini` repo, `kodi/SETUP.md`.

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
