# UnitsDB YAML Schemas

This directory contains JSON Schema definitions for all YAML files in the UnitsDB repository. These schemas provide validation, documentation, and IDE support for the structured data files.

## Schema Files

### Core Data Schemas

- **`units-schema.yaml`** - Schema for `units.yaml`
  - Defines physical units with their symbols, definitions, and relationships
  - Includes conversion factors, dimension references, and unit systems

- **`quantities-schema.yaml`** - Schema for `quantities.yaml`
  - Defines physical quantities with their dimensional analysis
  - Links quantities to their fundamental dimensions

- **`dimensions-schema.yaml`** - Schema for `dimensions.yaml`
  - Defines fundamental physical dimensions (length, mass, time, etc.)
  - Includes dimensional components and mathematical symbols

- **`prefixes-schema.yaml`** - Schema for `prefixes.yaml`
  - Defines unit prefixes (kilo, mega, micro, etc.)
  - Includes base/power notation and symbol representations

- **`scales-schema.yaml`** - Schema for `scales.yaml`
  - Defines measurement scales and their properties
  - Includes scale types and conversion relationships

- **`unit_systems-schema.yaml`** - Schema for `unit_systems.yaml`
  - Defines coherent systems of units (SI, CGS, etc.)
  - Includes base units and derived unit relationships

## Features

### Validation
All schemas provide comprehensive validation for:
- Required fields and data types
- Enumerated values for controlled vocabularies
- Pattern matching for identifiers and codes
- Cross-references between related entities

### Documentation
Each schema includes:
- Detailed descriptions for all fields
- Examples of valid values
- Explanations of relationships between entities

### IDE Support
The schemas enable:
- Auto-completion in YAML editors
- Real-time validation feedback
- Hover documentation for fields
- Error highlighting and suggestions

## Usage

### In VSCode
The YAML files automatically reference their schemas via the `yaml-language-server` directive at the top of each file:

```yaml
# yaml-language-server: $schema=schemas/units-schema.yaml
```

### Programmatic Validation
Use the provided validation script:

```bash
ruby validate_schemas.rb
```

### Manual Validation
You can validate individual files using any JSON Schema validator that supports YAML, such as:
- `ajv-cli`
- `jsonschema` (Python)
- Online validators like jsonschemavalidator.net

## Schema Structure

All schemas follow a consistent structure:

```yaml
$schema: "http://json-schema.org/draft-06/schema#"
$id: "https://unitsml.org/schemas/[schema-name].yaml"
title: "[Human Readable Title]"
description: "[Detailed description]"

type: object
required: ["schema_version", "[main_array]"]
properties:
  schema_version:
    type: string
    pattern: "^\\d+\\.\\d+\\.\\d+$"
  [main_array]:
    type: array
    items:
      $ref: "#/definitions/[MainType]"

definitions:
  # Type definitions...
```

## Common Definitions

### Identifier
All entities use a consistent identifier structure:
```yaml
type: object
required: ["type", "id"]
properties:
  type:
    type: string
    enum: ["nist", "unitsml", "si-digital-framework", ...]
  id:
    type: string
```

### Name
Multilingual names follow this pattern:
```yaml
type: object
required: ["value", "lang"]
properties:
  value:
    type: string
  lang:
    type: string
    pattern: "^[a-z]{2}(-[A-Z]{2})?$"
```

### Symbol
Mathematical symbols are represented as:
```yaml
type: object
required: ["latex", "unicode", "ascii", "html", "id", "mathml"]
properties:
  latex: { type: string }
  unicode: { type: string }
  ascii: { type: string }
  html: { type: string }
  id: { type: string }
  mathml: { type: string }
```

## Validation Results

✅ All schemas successfully validate their corresponding YAML files
✅ Cross-references and relationships are properly defined
✅ Enumerated values match actual data usage
✅ Required fields are correctly identified

## Maintenance

When updating the YAML data files:
1. Ensure changes conform to the existing schemas
2. Update schemas if new fields or structures are added
3. Run validation to verify compatibility
4. Update this documentation if schema structure changes

For questions or issues with the schemas, please refer to the main repository documentation or open an issue.
