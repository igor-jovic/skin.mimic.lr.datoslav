# Mimic-LR (datoslav)

A personal fork of [randallspicher/skin.mimic.lr](https://github.com/randallspicher/skin.mimic.lr) for the x96mini Kodi box
(LibreELEC 12 / Kodi 21 Omega). The box's setup lives in the `x96mini` repo, `kodi/SETUP.md`.

## Branches
- `datoslav` (default): our changes, based on upstream `Omega` (the Kodi 21 branch).
- `Omega`, `master`, …: upstream, untouched.

To take upstream fixes: `git fetch upstream && git merge upstream/Omega` on `datoslav`.

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
