# Schulen in NRW

Öffentliche und private Schulen in ganz NRW. Mit Status, Schulträger und Kontaktdaten.

## Datenquellen

* https://open.nrw/de/dataset/msw_001 ([dl-de/by-2-0](https://www.govdata.de/dl-de/by-2-0))
* http://opengeodb.org/wiki/PLZ.tab (Gemeinfrei)

## Herausforderungen

- [x] Daten von Datenquelle laden und aufbereiten *(GeoJSON als Zielformat)*
- [x] Koordinaten konvertieren *(Gauß-Krüger zu WGS84)*
- [x] Daten visualisieren
- [ ] Statistische Daten berechnen und anzeigen
- [ ] Webseite umsetzen

---

## Mitmachen

**How to:**
* [Webseite bearbeiten](#webseite-bearbeiten)

### Einrichtung / Initiale Schritte

Make sure __*ruby*__ and __*python*__ are installed.

```bash
$ git clone git@github.com:CodeforRuhrgebiet/schulen-in-nrw.git
```

```bash
$ cd schulen-in-nrw
```

```bash
$ git submodule init && git submodule update
```

```bash
$ bundle install
```
   *-> bundler not found: `gem install bundler`*

### Daten generieren

`$ ruby ./scripts/run.rb`

### Webseite bearbeiten

`$ jekyll serve -w`

alternative:

`$ bundle exec jekyll serve -w`
