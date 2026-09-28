#!/usr/bin/env bash
# Copy this skin (the files git tracks, as they are in the working tree) to the Kodi box and reload it.
#   ./deploy.sh [host]        default host: 10.10.101.141 (wifi); Ethernet is 10.10.101.33
# Refuses while something is playing. Needs root SSH to the box with ~/.ssh/id_rsa.
set -euo pipefail
cd "$(dirname "$0")"

HOST=${1:-10.10.101.141}
ID=skin.mimic.lr.datoslav
SSH=(ssh -i ~/.ssh/id_rsa -o BatchMode=yes "root@$HOST")

# Runs on the box, with the skin tarball on stdin.
read -r -d '' REMOTE <<'EOF' || true
set -euo pipefail
rpc() { printf '%s' "$1" | nc -w 3 127.0.0.1 9090; }
case "$(rpc '{"jsonrpc":"2.0","id":1,"method":"Player.GetActivePlayers"}')" in
  *playerid*) echo "deploy: something is playing, not touching the skin" >&2; exit 1 ;;
esac
dir=/storage/.kodi/addons/$ID
rm -rf "$dir.new" && mkdir "$dir.new"
tar -xzf - -C "$dir.new"
rm -rf "$dir.old"; [ -d "$dir" ] && mv "$dir" "$dir.old"
mv "$dir.new" "$dir" && rm -rf "$dir.old"
# Skin Shortcuts writes its generated menu into the skin folder; drop the hash so it rebuilds it.
rm -f "/storage/.kodi/userdata/addon_data/script.skinshortcuts/$ID.hash"
kodi-send -a "UpdateLocalAddons" >/dev/null
sleep 3
case "$(rpc '{"jsonrpc":"2.0","id":2,"method":"Settings.GetSettingValue","params":{"setting":"lookandfeel.skin"}}')" in
  # Build the menu now (Home.xml would only do it on its next load); Skin Shortcuts reloads the skin itself.
  *"\"$ID\""*) kodi-send -a "RunScript(script.skinshortcuts,type=buildxml&mode=single&mainmenuID=9000&group=mainmenu|quicknav)" >/dev/null
                 echo "deployed $ID, menu rebuilding and skin reloading" ;;
  *) echo "deployed $ID (not the active skin, nothing reloaded)" ;;
esac
EOF

# The box has no base64, so the script goes over first and the tarball second.
printf '%s\n' "$REMOTE" | "${SSH[@]}" "cat > /tmp/deploy-$ID.sh"

# Repo-only files stay out of the add-on.
git ls-files -z | grep -zvE '^(deploy\.sh|DATOSLAV\.md|\.gitignore|\.github/)' |
  COPYFILE_DISABLE=1 tar --null -T - -czf - |
  "${SSH[@]}" "ID=$ID bash /tmp/deploy-$ID.sh; rc=\$?; rm -f /tmp/deploy-$ID.sh; exit \$rc"
