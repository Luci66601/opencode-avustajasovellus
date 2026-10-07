#!/data/data/com.termux/files/usr/bin/bash
set -u

BASE="$HOME/daemeonai/opencode-avustajasovellus"

echo "=== DaemeonAI OpenCode Assistant: system check ==="
echo

echo "--- OS ---"
uname -a
command -v getprop >/dev/null 2>&1 && getprop ro.build.version.release || true
echo

echo "--- Termux ---"
command -v termux-info >/dev/null 2>&1 && termux-info 2>/dev/null || echo "termux-info ei saatavilla"
echo

echo "--- Identity ---"
id
whoami
echo

echo "--- OpenCode ---"
if command -v opencode >/dev/null 2>&1; then
    echo "OpenCode: $(command -v opencode)"
    opencode --version 2>/dev/null || true
else
    echo "OpenCode: EI LÖYDY PATHISTA"
fi
echo

echo "--- Debian tooling ---"
if command -v proot-distro >/dev/null 2>&1; then
    echo "proot-distro: $(command -v proot-distro)"
    proot-distro list 2>/dev/null || true
else
    echo "proot-distro: ei löydy"
fi

if command -v chroot >/dev/null 2>&1; then
    echo "chroot: $(command -v chroot)"
else
    echo "chroot: ei löydy"
fi
echo

echo "--- AI environments ---"
for f in \
    "$HOME/.config/daemeonai/openai.env" \
    "$HOME/daemeonai/config/gemini.env" \
    "$HOME/daemeonai/config/apify.env"
do
    if [ -f "$f" ]; then
        echo "OK: $f"
    else
        echo "MISSING: $f"
    fi
done

echo
echo "--- Project ---"
echo "$BASE"
echo "System check completed."
