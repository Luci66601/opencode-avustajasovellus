#!/data/data/com.termux/files/usr/bin/bash
set -u

# DaemeonAI OpenCode Command Guard
#
# Exit codes:
#   0 = ALLOW
#   10 = BLOCK
#
# This guard classifies commands. It does NOT execute them.

command="${*:-}"

if [ -z "$command" ]; then
    echo "BLOCK|EMPTY_COMMAND"
    exit 10
fi

# Normalize only for classification.
normalized="$(printf '%s' "$command" | tr '\n' ' ' | tr -s ' ')"

# Hard-block destructive / system-dangerous operations.
blocked_patterns=(
    '(^|[;&|[:space:]])rm[[:space:]]+-[^[:space:]]*[rR][^[:space:]]*[fF]'
    '(^|[;&|[:space:]])rm[[:space:]]+-[^[:space:]]*[fF][^[:space:]]*[rR]'
    '(^|[;&|[:space:]])dd[[:space:]].*(of=)?/dev/'
    '(^|[;&|[:space:]])mkfs([.[:space:]]|$)'
    '(^|[;&|[:space:]])mkswap([.[:space:]]|$)'
    '(^|[;&|[:space:]])fdisk([[:space:]]|$)'
    '(^|[;&|[:space:]])parted([[:space:]]|$)'
    '(^|[;&|[:space:]])shutdown([[:space:]]|$)'
    '(^|[;&|[:space:]])reboot([[:space:]]|$)'
    '(^|[;&|[:space:]])poweroff([[:space:]]|$)'
    '(^|[;&|[:space:]])halt([[:space:]]|$)'
    '(^|[;&|[:space:]])wipefs([[:space:]]|$)'
    '(^|[;&|[:space:]])cryptsetup[[:space:]]+(erase|luksErase|luksFormat)'
    '(^|[;&|[:space:]])mount[[:space:]]+.*(/dev/|/system|/vendor)'
    '(^|[;&|[:space:]])umount[[:space:]]+.*(/dev/|/system|/vendor)'
)

for pattern in "${blocked_patterns[@]}"; do
    if printf '%s\n' "$normalized" | grep -Eiq -- "$pattern"; then
        echo "BLOCK|DESTRUCTIVE_OPERATION"
        exit 10
    fi
done

# Block obvious financial / wallet automation.
financial_patterns=(
    'wallet'
    'send[[:space:]]+.*(money|payment|fund)'
    'transfer[[:space:]]+.*(money|payment|fund)'
    'monero.*transfer'
    'bitcoin.*send'
    'crypto.*transfer'
)

for pattern in "${financial_patterns[@]}"; do
    if printf '%s\n' "$normalized" | grep -Eiq -- "$pattern"; then
        echo "BLOCK|FINANCIAL_OPERATION"
        exit 10
    fi
done

# Block attempts to expose configured secrets.
secret_patterns=(
    'cat[[:space:]].*(openai\.env|gemini\.env|apify\.env)'
    'cat[[:space:]].*(\.env|credentials|secret)'
    'printenv[[:space:]]+.*(KEY|TOKEN|SECRET|PASSWORD)'
    'env[[:space:]]*\|.*(KEY|TOKEN|SECRET|PASSWORD)'
)

for pattern in "${secret_patterns[@]}"; do
    if printf '%s\n' "$normalized" | grep -Eiq -- "$pattern"; then
        echo "BLOCK|SECRET_EXPOSURE"
        exit 10
    fi
done

# Allow ordinary development / diagnostics automatically.
echo "ALLOW|SAFE_DEVELOPMENT_COMMAND"
exit 0
