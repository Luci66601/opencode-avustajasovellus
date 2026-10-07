#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

BASE="$HOME/daemeonai/opencode-avustajasovellus"
OPENAI_ENV="$HOME/.config/daemeonai/openai.env"
GEMINI_ENV="$HOME/daemeonai/config/gemini.env"
APIFY_ENV="$HOME/daemeonai/config/apify.env"

echo "=== DaemeonAI OpenCode Debian Runner ==="
echo

# Load only trusted local environment files.
[ -f "$OPENAI_ENV" ] && . "$OPENAI_ENV"
[ -f "$GEMINI_ENV" ] && . "$GEMINI_ENV"
[ -f "$APIFY_ENV" ] && . "$APIFY_ENV"

echo "--- Termux environment ---"
printf 'OpenAI: '
[ -n "${OPENAI_API_KEY:-}" ] && echo "SET" || echo "NOT_SET"

printf 'Gemini: '
[ -n "${GEMINI_API_KEY:-}" ] && echo "SET" || echo "NOT_SET"

printf 'Apify: '
[ -n "${APIFY_API_TOKEN:-}" ] && echo "SET" || echo "NOT_SET"

echo
echo "--- Debian ---"

if ! command -v proot-distro >/dev/null 2>&1; then
    echo "ERROR: proot-distro not found."
    exit 1
fi

if ! proot-distro list -q | grep -qx 'debian'; then
    echo "ERROR: Debian container not found."
    exit 1
fi

proot-distro login debian -- /bin/bash -lc '
echo "Debian: OK"
printf "User: "; whoami
printf "Home: %s\n" "$HOME"
printf "OpenCode: "

if [ -x /root/.opencode/bin/opencode ]; then
    /root/.opencode/bin/opencode --version
else
    echo "NOT_FOUND"
fi
'

echo
echo "Runner test completed."
echo "OpenCode was NOT started."
echo "No API key values were displayed."
