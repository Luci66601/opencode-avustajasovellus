#!/data/data/com.termux/files/usr/bin/bash
set -u

echo "Debian root -ympäristön tunnistus"
echo

if command -v proot-distro >/dev/null 2>&1; then
    echo "proot-distro löytyi:"
    proot-distro list 2>/dev/null || true
else
    echo "proot-distro ei löytynyt."
fi

echo
echo "Tämä skripti ei asenna, poista eikä käynnistä Debiania."
echo "Seuraava vaihe tehdään vasta ympäristön tunnistamisen jälkeen."
