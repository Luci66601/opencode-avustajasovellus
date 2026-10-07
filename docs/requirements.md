# Järjestelmävaatimukset

## 1. Käyttöjärjestelmä

Nykyinen kohdeympäristö on Android + Termux.

Tarkista:

    uname -a
    getprop ro.build.version.release
    termux-info

## 2. Termux

Tarkistettavat paketit:

    bash
    coreutils
    git
    curl
    openssh
    python
    nodejs

Paketit asennetaan vasta erillisessä hyväksytyssä asennusvaiheessa.

## 3. OpenCode

Tarkista:

    command -v opencode
    opencode --version

OpenCodea ei asenneta automaattisesti tämän projektin alustuksen yhteydessä.

## 4. Debian root

Ensin selvitetään käytössä oleva Debian-ratkaisu.

Tarkista:

    command -v proot-distro
    command -v chroot
    id
    whoami

Jos Debian on proot-distro:

    proot-distro list

Root-yhteyttä ei oleteta ennen kuin ympäristö on tunnistettu.

## 5. AI-API:t

Ensisijainen OpenAI-konfiguraatio:

    ~/.config/daemeonai/openai.env

Gemini:

    ~/daemeonai/config/gemini.env

Apify:

    ~/daemeonai/config/apify.env

API-avaimia ei kopioida tähän projektiin.

## 6. Verkko

Tarkista:

    curl -I https://api.openai.com
    curl -I https://github.com

## 7. Käyttöoikeudet

Projektin tiedostot:

    chmod 700 scripts

Salaiset ympäristötiedostot:

    chmod 600 ~/.config/daemeonai/openai.env
    chmod 600 ~/daemeonai/config/gemini.env
    chmod 600 ~/daemeonai/config/apify.env

## 8. Turvallisuus

Root-komennot eivät saa olla oletusarvoisesti automaattisesti sallittuja.

Kaikki mahdollisesti tuhoavat toiminnot pitää pysäyttää ennen suorittamista ja pyytää käyttäjän hyväksyntä.
