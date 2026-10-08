#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail

P="${HOME}/daemeonai/opencode-avustajasovellus"
OC="$P/opencode.jsonc"
GUARD="$P/security/command-guard.sh"

PASS=0
FAIL=0

pass() {
    echo "PASS $1"
    PASS=$((PASS+1))
}

fail() {
    echo "FAIL $1"
    FAIL=$((FAIL+1))
}

expect_permission() {
    local name="$1"
    local rule="$2"
    local expected="$3"

    if grep -Fq "\"$rule\": \"$expected\"" "$OC"; then
        pass "$name"
    else
        fail "$name"
    fi
}

expect_guard_block() {
    local name="$1"
    local command="$2"

    if "$GUARD" "$command" >/dev/null 2>&1; then
        fail "DENY: $name"
    else
        pass "DENY: $name"
    fi
}

expect_guard_allow() {
    local name="$1"
    local command="$2"

    if "$GUARD" "$command" >/dev/null 2>&1; then
        pass "ALLOW: $name"
    else
        fail "ALLOW: $name"
    fi
}

echo "=== OPENCODE SAFETY REGRESSION ==="

echo "--- OPENCODE PERMISSION POLICY ---"

expect_permission "ALLOW: git push" "git push" "allow"
expect_permission "ALLOW: git push wildcard" "git push *" "allow"

expect_permission "DENY: rm" "rm" "deny"
expect_permission "DENY: rm *" "rm *" "deny"
expect_permission "DENY: rm -rf" "rm -rf" "deny"
expect_permission "DENY: rm -rf *" "rm -rf *" "deny"
expect_permission "DENY: dd" "dd *" "deny"
expect_permission "DENY: mkfs" "mkfs *" "deny"
expect_permission "DENY: shutdown" "shutdown *" "deny"
expect_permission "DENY: reboot" "reboot *" "deny"
expect_permission "DENY: poweroff" "poweroff *" "deny"
expect_permission "DENY: wallet" "*wallet*" "deny"
expect_permission "DENY: payment" "*payment*" "deny"
expect_permission "DENY: transfer" "*transfer*" "deny"
expect_permission "DENY: crypto transfer" "*crypto*transfer*" "deny"

echo "--- COMMAND GUARD POLICY ---"

expect_guard_allow "safe development" "git status"
expect_guard_allow "safe diff" "git diff"
expect_guard_allow "safe Python" "python3 --version"

expect_guard_block "rm -rf" "rm -rf /tmp/dai-safety-test"
expect_guard_block "dd device write" "dd if=/dev/zero of=/dev/null bs=1 count=1"
expect_guard_block "shutdown" "shutdown now"
expect_guard_block "reboot" "reboot"
expect_guard_block "wallet" "wallet send"
expect_guard_block "payment" "transfer payment"
expect_guard_block "financial transfer" "transfer money"
expect_guard_block "secret OpenAI env" "cat $HOME/.config/daemeonai/openai.env"
expect_guard_block "secret Gemini env" "cat $HOME/daemeonai/config/gemini.env"
expect_guard_block "secret Apify env" "cat $HOME/daemeonai/config/apify.env"
expect_guard_block "environment secret exposure" "printenv OPENAI_API_KEY"

echo
echo "PASS=$PASS"
echo "FAIL=$FAIL"

if [ "$FAIL" -eq 0 ]; then
    echo "SAFETY-REGRESSION: PASS"
    exit 0
fi

echo "SAFETY-REGRESSION: FAIL"
exit 1
