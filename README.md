# DaemeonAI OpenCode -avustajasovellus

Tämän projektin tarkoitus on tarjota DaemeonAI:n yhteyteen hallittu OpenCode-avustajasovellus, joka voi käyttää Debian root -ympäristöä tarvittaessa.

## Ympäristö

Ensisijainen käyttöympäristö:
- Android
- Termux
- DaemeonAI: $HOME/daemeonai
- OpenCode
- Debian root -ympäristö (toteutustapa tarkistetaan ennen käyttöönottoa)

## Turvallisuus

- Ei automaattisia tuhoavia komentoja.
- Ei `rm -rf`, `dd`, `mkfs`, `shutdown`, `reboot` tai vastaavia ilman erillistä hyväksyntää.
- Ei automaattisia maksuja tai rahansiirtoja.
- Root-oikeuksia käytetään vain silloin, kun tehtävä niitä aidosti tarvitsee.
- Ennen muutoksia suoritetaan järjestelmä- ja ympäristötarkistus.
- API-avaimia ei kirjoiteta projektin lokitiedostoihin.

## Tavoite

OpenCode-avustaja toimii DaemeonAI:n aliprojektina ja dokumentoi:
1. käytössä olevan käyttöjärjestelmän
2. Termux-ympäristön
3. Debian root -ympäristön
4. OpenCode-asennuksen
5. tarvittavat paketit
6. verkko- ja käyttöoikeusvaatimukset
7. AI/API-ympäristömuuttujat
8. turvalliset käynnistys- ja pysäytystavat
9. vianmäärityksen

Katso docs/requirements.md ennen asennuksia.
