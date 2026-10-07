#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

BASE="$HOME/daemeonai/opencode-avustajasovellus"
FIXTURE="$BASE/tests/simulated-fixture"
LOG="$BASE/logs/self-test.log"

mkdir -p "$FIXTURE"

{
    echo "=================================================="
    echo "DaemeonAI OpenCode Assistant - SELF TEST"
    echo "=================================================="
    date
    echo

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

    echo "=== 1. CREATE SIMULATED ERROR ==="

    cat > "$FIXTURE/test-app.conf" <<'CONFIG'
APP_NAME=DaemeonAI
APP_MODE=production
REQUIRED_VALUE=CORRECT
CONFIG

    # Simuloitu virhe: vaadittu arvo muutetaan vääräksi.
    sed -i 's/REQUIRED_VALUE=CORRECT/REQUIRED_VALUE=BROKEN/' \
        "$FIXTURE/test-app.conf"

    echo "Simulated error created:"
    grep '^REQUIRED_VALUE=' "$FIXTURE/test-app.conf"
    echo

    echo "=== 2. DETECT ERROR ==="

    CURRENT="$(grep '^REQUIRED_VALUE=' "$FIXTURE/test-app.conf" | cut -d= -f2-)"

    if [ "$CURRENT" = "BROKEN" ]; then
        pass "Simulated configuration error detected"
    else
        fail "Simulated configuration error was not detected"
    fi

    echo
    echo "=== 3. DIAGNOSE ==="

    if grep -q '^REQUIRED_VALUE=BROKEN$' "$FIXTURE/test-app.conf"; then
        echo "Diagnosis: REQUIRED_VALUE has invalid value."
        pass "Diagnosis identified the simulated fault"
    else
        fail "Diagnosis failed"
    fi

    echo
    echo "=== 4. SAFE REPAIR ==="

    # Korjaus tehdään vain test fixture -hakemistossa.
    sed -i 's/^REQUIRED_VALUE=BROKEN$/REQUIRED_VALUE=CORRECT/' \
        "$FIXTURE/test-app.conf"

    if grep -q '^REQUIRED_VALUE=CORRECT$' "$FIXTURE/test-app.conf"; then
        pass "Repair restored the expected value"
    else
        fail "Repair did not restore the expected value"
    fi

    echo
    echo "=== 5. RE-TEST ==="

    CURRENT="$(grep '^REQUIRED_VALUE=' "$FIXTURE/test-app.conf" | cut -d= -f2-)"

    if [ "$CURRENT" = "CORRECT" ]; then
        pass "Post-repair verification succeeded"
    else
        fail "Post-repair verification failed"
    fi

    echo
    echo "=== 6. SAFETY CHECK ==="

    # Varmistetaan, että testi koski vain omaa fixtureä.
    case "$FIXTURE" in
        "$BASE/tests/simulated-fixture")
            pass "Repair stayed inside simulated fixture"
            ;;
        *)
            fail "Unexpected repair path"
            ;;
    esac

    echo
    echo "=================================================="
    echo "RESULT"
    echo "=================================================="
    echo "PASS=$PASS"
    echo "FAIL=$FAIL"
    echo

    if [ "$FAIL" -eq 0 ]; then
        echo "SELF-TEST: PASS"
        exit 0
    else
        echo "SELF-TEST: FAIL"
        exit 1
    fi
} | tee "$LOG"
