#!/usr/bin/env bash
# Lightweight pre-push sanity scan for this repository.
# Catches the common accidents: real email addresses, private keys,
# token-shaped strings, and absolute local paths.
# Usage: bash scripts/check-secrets.sh [path]
set -u
TARGET="${1:-.}"
FAIL=0

check() {
  local label="$1" pattern="$2"
  if grep -rInE --exclude-dir=.git --exclude=check-secrets.sh "$pattern" "$TARGET" >/dev/null 2>&1; then
    echo "HIT [$label]:"
    grep -rInE --exclude-dir=.git --exclude=check-secrets.sh "$pattern" "$TARGET" | head -20
    FAIL=1
  fi
}

check "email address" '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'
check "private key block" 'BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY'
check "token-like string" '(api[_-]?key|secret|token|password)[[:space:]]*[:=][[:space:]]*[A-Za-z0-9_\-]{12,}'
check "absolute local path" '(/Users/|/home/[a-z]+/|C:\\Users\\)'
# Example targets only — patterns for common shared-doc link shapes.
check "cloud doc/drive link" '(docs\.google\.com|drive\.google\.com|docs\.qq\.com)/[A-Za-z0-9_\-]{10,}'

if [ "$FAIL" -eq 0 ]; then
  echo "check-secrets: clean"
else
  echo "check-secrets: REVIEW REQUIRED before pushing"
  exit 1
fi
