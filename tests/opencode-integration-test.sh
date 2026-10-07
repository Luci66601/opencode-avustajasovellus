#!/data/data/com.termux/files/usr/bin/bash
set -u

BASE="$HOME/daemeonai/opencode-avustajasovellus"
GUARD="$BASE/security/command-guard.sh"
FIXTURE="$BASE/tests/integration-fixture"
LOG="$BASE/logs/opencode-integration-test.log"

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

{
    echo "=================================================="
    echo "DaemeonAI OpenCode Integration Test"
    echo "=================================================="
    date
    echo

    rm -rf "$FIXTURE"
    mkdir -p "$FIXTURE"

    echo "=== 1. CREATE SIMULATED PROJECT ==="

    cat > "$FIXTURE/app.conf" <<'CONFIG'
APP_NAME=DaemeonAI-Test
APP_MODE=test
REQUIRED_VALUE=CORRECT
CONFIG

    pass "Simulated project created"

    echo
    echo "=== 2. INJECT SIMULATED ERROR ==="

    sed -i 's/REQUIRED_VALUE=CORRECT/REQUIRED_VALUE=BROKEN/' \
        "$FIXTURE/app.conf"

    if grep -q '^REQUIRED_VALUE=BROKEN$' "$FIXTURE/app.conf"; then
        pass "Simulated application error created"
    else
        fail "Could not create simulated error"
    fi

    echo
    echo "=== 3. SIMULATE OPENCODE DIAGNOSTIC COMMAND ==="

    DIAG_CMD="grep '^REQUIRED_VALUE=' '$FIXTURE/app.conf'"
    RESULT="$("$GUARD" "$DIAG_CMD" 2>&1)"

    if [[ "$RESULT" == ALLOW\|* ]]; then
        pass "Diagnostic command allowed by guard"
    else
        fail "Diagnostic command blocked: $RESULT"
    fi

    echo
    echo "=== 4. DETECT ERROR ==="

    CURRENT="$(grep '^REQUIRED_VALUE=' "$FIXTURE/app.conf" | cut -d= -f2-)"

    if [ "$CURRENT" = "BROKEN" ]; then
        pass "OpenCode-style diagnosis detected broken value"
    else
        fail "Broken value was not detected"
    fi

    echo
    echo "=== 5. SIMULATE SAFE REPAIR ==="

    REPAIR_CMD="sed -i 's/^REQUIRED_VALUE=BROKEN$/REQUIRED_VALUE=CORRECT/' '$FIXTURE/app.conf'"
    RESULT="$("$GUARD" "$REPAIR_CMD" 2>&1)"

    if [[ "$RESULT" == ALLOW\|* ]]; then
        pass "Repair command allowed by guard"
    else
        fail "Repair command blocked: $RESULT"
    fi

    # Execute only after guard allowed it.
    if [ "$RESULT" = ALLOW\|SAFE_DEVELOPMENT_COMMAND ]; then
        sed -i 's/^REQUIRED_VALUE=BROKEN$/REQUIRED_VALUE=CORRECT/' \
            "$FIXTURE/app.conf"
    fi

    echo
    echo "=== 6. VERIFY REPAIR ==="

    CURRENT="$(grep '^REQUIRED_VALUE=' "$FIXTURE/app.conf" | cut -d= -f2-)"

    if [ "$CURRENT" = "CORRECT" ]; then
        pass "Repair restored correct configuration"
    else
        fail "Repair verification failed"
    fi

    echo
    echo "=== 7. VERIFY DANGEROUS COMMAND IS BLOCKED ==="

    DANGER_CMD="rm -rf '$FIXTURE'"
    RESULT="$("$GUARD" "$DANGER_CMD" 2>&1)"

    if [[ "$RESULT" == BLOCK\|* ]]; then
        pass "Dangerous command blocked"
    else
        fail "Dangerous command was not blocked: $RESULT"
    fi

    echo
    echo "=== 8. FINAL FIXTURE CHECK ==="

    if [ -f "$FIXTURE/app.conf" ]; then
        pass "Test fixture remained intact"
    else
        fail "Test fixture was unexpectedly removed"
    fi

    echo
    echo "=================================================="
    echo "RESULT"
    echo "=================================================="
    echo "PASS=$PASS"
    echo "FAIL=$FAIL"
    echo

    if [ "$FAIL" -eq 0 ]; then
        echo "INTEGRATION-TEST: PASS"
        exit 0
    else
        echo "INTEGRATION-TEST: FAIL"
        exit 1
    fi
} | tee "$LOG"
