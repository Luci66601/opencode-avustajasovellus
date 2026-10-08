#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail

BASE="${DAEMEONAI_BASE:-$HOME/daemeonai}"
ROOT="$BASE/opencode-avustajasovellus"
OC="$ROOT/opencode.jsonc"
GUARD="$ROOT/security/command-guard.sh"
SAFETY="$ROOT/tests/opencode-safety-regression.sh"
WRAPPER="$ROOT/bin/dai-opencode"
PUBLISHER="$ROOT/bin/dai-opencode-publish"
UPDATER="$ROOT/bin/dai-opencode-update"
LIMIT="$BASE/ai/adapters/daily-file-limit.sh"
PUBGATE="$BASE/ai/adapters/publication-gate.sh"
SECGATE="$BASE/ai/adapters/public-secret-gate.sh"

PASS=0
FAIL=0

pass() { printf '[PASS] %s\n' "$1"; PASS=$((PASS+1)); }
fail() { printf '[FAIL] %s\n' "$1"; FAIL=$((FAIL+1)); }

echo "=================================================="
echo "DaemeonAI OpenCode Policy Consistency Test"
echo "=================================================="

echo "--- FILES ---"
for f in "$OC" "$GUARD" "$SAFETY" "$WRAPPER" "$PUBLISHER" "$UPDATER" "$LIMIT" "$PUBGATE" "$SECGATE"; do
    if [ -f "$f" ]; then
        pass "exists: $f"
    else
        fail "missing: $f"
    fi
done

echo
echo "--- OPENCODE PERMISSIONS ---"

grep -q '"git push": "allow"' "$OC" \
    && pass "git push allowed" \
    || fail "git push is not explicitly allowed"

grep -q '"git push \*": "allow"' "$OC" \
    && pass "git push wildcard allowed" \
    || fail "git push wildcard is not allowed"

grep -q '"rm": "deny"' "$OC" \
    && pass "rm denied" \
    || fail "rm deny missing"

grep -q '"rm -rf": "deny"' "$OC" \
    && pass "rm -rf denied" \
    || fail "rm -rf deny missing"

grep -q '"dd \*": "deny"' "$OC" \
    && pass "dd denied" \
    || fail "dd deny missing"

grep -q '"shutdown \*": "deny"' "$OC" \
    && pass "shutdown denied" \
    || fail "shutdown deny missing"

grep -q '"reboot \*": "deny"' "$OC" \
    && pass "reboot denied" \
    || fail "reboot deny missing"

grep -q '"\*wallet\*": "deny"' "$OC" \
    && pass "wallet denied" \
    || fail "wallet deny missing"

grep -q '"\*payment\*": "deny"' "$OC" \
    && pass "payment denied" \
    || fail "payment deny missing"

grep -q '"\*transfer\*": "deny"' "$OC" \
    && pass "transfer denied" \
    || fail "transfer deny missing"

echo
echo "--- COMMAND GUARD ---"

bash -n "$GUARD" \
    && pass "command guard syntax" \
    || fail "command guard syntax"

"$GUARD" "git status" >/dev/null 2>&1 \
    && pass "safe git command allowed" \
    || fail "safe git command blocked"

if "$GUARD" "rm -rf /tmp/dai-policy-test" >/dev/null 2>&1; then
    fail "rm -rf was allowed"
else
    pass "rm -rf blocked"
fi

if "$GUARD" "dd if=/dev/zero of=/dev/null bs=1 count=1" >/dev/null 2>&1; then
    fail "dd was allowed"
else
    pass "dd blocked"
fi

if "$GUARD" "transfer payment" >/dev/null 2>&1; then
    fail "payment was allowed"
else
    pass "payment blocked"
fi

if "$GUARD" "cat $HOME/.config/daemeonai/openai.env" >/dev/null 2>&1; then
    fail "secret exposure was allowed"
else
    pass "secret exposure blocked"
fi

echo
echo "--- DAILY LIMIT ---"
LIMIT="$BASE/ai/adapters/daily-file-limit.sh"
LIMIT_OUT="$("$LIMIT" 10 2>&1)" || true
if printf "%s\n" "$LIMIT_OUT" | grep -q "REQUESTED=10" && printf "%s\n" "$LIMIT_OUT" | grep -q "LIMIT=50"; then
    pass "daily limit is 50 files"
else
    fail "daily limit configuration is not 50"
fi
if printf "%s\n" "$LIMIT_OUT" | grep -q "PUBLICATION_LIMIT=5"; then
    pass "publication limit is 5 per day"
else
    fail "publication limit configuration is not 5"
fi

echo "--- ENVIRONMENT POLICY ---"

[ -r "$BASE/config/gemini.env" ] \
    && pass "Gemini env exists" \
    || fail "Gemini env missing"

[ -r "$BASE/config/apify.env" ] \
    && pass "Apify env exists" \
    || fail "Apify env missing"

[ -r "$HOME/.config/daemeonai/openai.env" ] \
    && pass "OpenAI env exists" \
    || fail "OpenAI env missing"

echo
echo "--- RUNTIME ---"

if proot-distro login debian -- bash -lc '[ -x "$HOME/.opencode/bin/opencode" ]' >/dev/null 2>&1; then
    pass "Debian OpenCode runtime exists"
else
    fail "Debian OpenCode runtime missing"
fi

if "$WRAPPER" help >/dev/null 2>&1; then
    pass "OpenCode wrapper works"
else
    fail "OpenCode wrapper failed"
fi

if grep -RInE --exclude='policy-consistency-test.sh' --exclude='dai-opencode' -- '(^|[[:space:]])(/root/\.opencode/bin/opencode|opencode)([[:space:]].*)?[[:space:]]--auto([[:space:]]|$)' "$UPDATER" "$PUBLISHER" "$ROOT/scripts" "$ROOT/tests" 2>/dev/null; then
    fail "OpenCode --auto execution found"
else
    pass "OpenCode --auto not used"
fi

echo
echo "--- TESTS ---"

"$ROOT/tests/self-test.sh" >/dev/null 2>&1 \
    && pass "self-test" \
    || fail "self-test"

"$ROOT/tests/guard-test.sh" >/dev/null 2>&1 \
    && pass "guard-test" \
    || fail "guard-test"

"$ROOT/tests/opencode-integration-test.sh" >/dev/null 2>&1 \
    && pass "integration-test" \
    || fail "integration-test"

echo
echo "--- GITHUB ---"

cd "$ROOT"

[ "$(git branch --show-current)" = "main" ] \
    && pass "main branch" \
    || fail "not on main branch"

REMOTE="$(git remote get-url origin 2>/dev/null || true)"

case "$REMOTE" in
    https://github.com/*|git@github.com:*)
        pass "GitHub origin configured"
        ;;
    *)
        fail "GitHub origin missing"
        ;;
esac

echo
echo "--- PUBLISHING ---"

[ -x "$PUBLISHER" ] \
    && pass "publisher executable" \
    || fail "publisher not executable"

[ -x "$PUBGATE" ] \
    && pass "publication gate executable" \
    || fail "publication gate not executable"

[ -x "$SECGATE" ] \
    && pass "public secret gate executable" \
    || fail "public secret gate not executable"

echo
echo "--- UPDATER POLICY ---"

if grep -q 'dai-opencode" update' "$UPDATER"; then
    fail "updater calls unsupported dai-opencode update command"
else
    pass "updater does not call unsupported wrapper update command"
fi

if grep -q 'Do not push directly' "$UPDATER"; then
    fail "updater still contains obsolete no-push policy"
else
    pass "updater has no obsolete no-push policy"
fi

if grep -q 'Automatically publish successful changes to GitHub' "$UPDATER"; then
    pass "updater requires automatic GitHub publication"
else
    fail "updater GitHub publication policy missing"
fi

echo
echo "=================================================="
printf 'PASS=%s\n' "$PASS"
printf 'FAIL=%s\n' "$FAIL"
echo "=================================================="

if [ "$FAIL" -eq 0 ]; then
    echo "POLICY-CONSISTENCY: PASS"
    exit 0
fi

echo "POLICY-CONSISTENCY: FAIL"
exit 1
