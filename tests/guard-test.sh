#!/data/data/com.termux/files/usr/bin/bash
set -u

BASE="$HOME/daemeonai/opencode-avustajasovellus"
GUARD="$BASE/security/command-guard.sh"
LOG="$BASE/logs/guard-test.log"

PASS=0
FAIL=0

pass() {
    echo "[PASS] $1"
    PASS=$((PASS + 1))
}

fail() {
    echo "[FAIL] $1"
    FAIL=$((FAIL + 1))
}

expect_allow() {
    local description="$1"
    shift
    local result
    result="$("$GUARD" "$@" 2>&1)"
    if [[ "$result" == ALLOW\|* ]]; then
        pass "$description"
    else
        fail "$description -> $result"
    fi
}

expect_block() {
    local description="$1"
    shift
    local result
    result="$("$GUARD" "$@" 2>&1)"
    if [[ "$result" == BLOCK\|* ]]; then
        pass "$description"
    else
        fail "$description -> $result"
    fi
}

{
    echo "=================================================="
    echo "DaemeonAI Command Guard - SIMULATED TEST"
    echo "=================================================="
    date
    echo

    echo "=== SAFE DEVELOPMENT COMMANDS ==="

    expect_allow \
        "Git status" \
        git status

    expect_allow \
        "Git diff" \
        git diff

    expect_allow \
        "Python test" \
        python3 -m pytest

    expect_allow \
        "Node syntax check" \
        node --check app.js

    expect_allow \
        "NPM test" \
        npm test

    expect_allow \
        "Directory listing" \
        ls -la

    expect_allow \
        "Read source file" \
        cat src/app.py

    echo
    echo "=== DESTRUCTIVE COMMANDS ==="

    expect_block \
        "Recursive force delete" \
        rm -rf ./test-directory

    expect_block \
        "Filesystem creation" \
        mkfs.ext4 /dev/test-device

    expect_block \
        "Disk overwrite" \
        dd if=/dev/zero of=/dev/test-device

    expect_block \
        "System reboot" \
        reboot

    expect_block \
        "System shutdown" \
        shutdown -h now

    echo
    echo "=== FINANCIAL COMMANDS ==="

    expect_block \
        "Wallet operation" \
        monero-wallet-cli transfer

    expect_block \
        "Financial transfer" \
        transfer money

    echo
    echo "=== SECRET EXPOSURE ==="

    expect_block \
        "OpenAI environment exposure" \
        cat "$HOME/.config/daemeonai/openai.env"

    expect_block \
        "Generic secret exposure" \
        printenv OPENAI_API_KEY

    echo
    echo "=================================================="
    echo "RESULT"
    echo "=================================================="
    echo "PASS=$PASS"
    echo "FAIL=$FAIL"
    echo

    if [ "$FAIL" -eq 0 ]; then
        echo "GUARD-TEST: PASS"
        exit 0
    else
        echo "GUARD-TEST: FAIL"
        exit 1
    fi
} | tee "$LOG"
