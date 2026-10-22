# Proposal: ISO 4217 currencies as first-class entities in unitsdb

**Status: draft for maintainer review — not yet filed anywhere.**

## Motivation

Legal metrology controls monetary quantities. OIML R117 verifies fuel
dispensers on the *price computation and display* (approval characteristics
state `maximum_unit_price` ≤ 9.999 EUR/L, `maximum_price_to_pay` ≤ 9999.99
EUR); OIML R21 taximeters approve fares denominated in authority-defined
fare units. Certificates of conformity therefore carry monetary values as
metrologically controlled data, and today unitsdb cannot express them —
downstream registries bolt on side fields or invent placeholder units
(our register carries `u:customary_unit` purely because unitsml had no
currency).

Prior art treats currency as unit-like:

- **UCUM** incorporates the ISO 4217 codes as units.
- **QUDT** models a `CurrencyUnit` class.
- **ISO 4217** itself is the code list, with minor-unit exponents that are
  exactly display-rounding facts (the thing R117 legislates).

Money behaves unit-like in every algebraic sense that matters here:
amounts add, scalars multiply, and rates compose — EUR/L, EUR/kWh, EUR/km.
Denomination is not measurement, but the OIML domain *does* measure and
verify money displays, which makes currency a quantity in this domain.

## Design

New collection `currencies.yaml` alongside `units.yaml` / `prefixes.yaml`:

```yaml
currencies:
- identifiers:
  - { type: iso4217, id: EUR }
  names:
  - { value: "Euro", lang: en }
  symbols:
  - { unicode: "€", ascii: "EUR" }
  minor_unit_exponent: 2
  unit_system_reference:
  - { type: unitsml, id: iso-4217 }
  quantity_references:
  - { type: unitsml, id: q:monetary_value }
```

Key decisions:

1. **Own namespace `cur:`** for ids (`cur:EUR`), mirroring `u:`/`p:`, so
   nothing downstream mistakes a denomination for a physical unit.
2. **No `root_units`, ever.** Each currency is its own base. Cross-currency
   conversion factors float (exchange rates); a unitsml-style factor table
   would silently compute wrong prices. All codes share one dimension
   (`{currency}`) for dimensional analysis; numeric conversion stays an
   application concern (rate service). This is the same split QUDT makes.
3. **`minor_unit_exponent`** carried as data — display rounding is exactly
   what price-display clauses legislate.
4. **Code-list versioning**: the collection tracks an ISO 4217 edition;
   historic codes (NLG, DEM) remain resolvable for legacy documents —
   pre-euro certificates do exist.

## Integration

- unitsdb gem: model classes + loader for the collection; the existing
  `find_by_symbol`-style API extended with `find_by_code`.
- unitsml-ruby: currency atoms accepted by composition, so
  `cur:EUR`/`u:liter` is a first-class composed unit for price-per-volume.
- Consumer registries (e.g. the OIML-CS certificate register's compound
  resolver) gain currency atoms through the ordinary signature-matching
  machinery — no special-cased currency path.

## Migration sketch (OIML-CS certificate register)

`EURO/L` resolves as the composition `cur:EUR`/`u:liter` through the
generic compound path; the interim `currency:` side field becomes a
denormalized display convenience. `u:customary_unit` stays — it is
authority-defined, not a specific currency.

## Open questions for the maintainer

1. Namespace: `cur:EUR` vs registering under `u:` with an `iso-4217`
   unit system?
2. One shared `{currency}` dimension vs per-currency dimensions?
3. Do historic/withdrawn codes belong in the main collection or a
   companion `currencies-historic.yaml`?
4. UnitsML serialization: a new top-level element, or currency units
   inside the existing `Units` element with a system discriminator?
