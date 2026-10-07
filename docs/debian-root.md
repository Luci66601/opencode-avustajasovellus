# Debian root -yhteys

## Tavoite

OpenCode-avustaja tarvitsee hallitun tavan suorittaa Debian-ympäristössä tehtäviä.

## Ennen toteutusta selvitetään

1. Onko Debian jo asennettu?
2. Käytetäänkö proot-distroa?
3. Onko kyseessä oikea chroot?
4. Missä Debianin root filesystem sijaitsee?
5. Miten Debian käynnistetään?
6. Tarvitaanko root-oikeuksia vai riittääkö Debianin käyttäjäympäristö?
7. Miten OpenCode kutsuu Debian-komentoja?
8. Miten pääsy estetään vaarallisiin komentoihin?

## Periaate

OpenCode -> DaemeonAI safety layer -> Debian command runner -> Debian

OpenCode ei saa ohittaa safety layeria.

## Ei oletusarvoista root-autonomiaa

Root-oikeuksia ei anneta OpenCodelle pysyvästi.

Kriittiset komennot vaativat käyttäjän hyväksynnän.
