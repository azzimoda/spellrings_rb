# AGENTS.md — Ruby Spellrings

## Project

Visualize Ruby code as magical circles (SVG). Inspired by [denismm/mystical_ps](https://github.com/denismm/mystical_ps).

## Entrypoints

- **Library**: `lib/spellrings_rb.rb` — module `Spellrings`, methods `build_file`, `node_types`
- **CLI**: `app/main.rb` — `ruby app/main.rb <source_file>`, `ruby app/main.rb examples [name]`, `ruby app/main.rb node_types <file>`
- **Lib modules**: `Parser` (Prism → Ring/Element AST), `Visualizer` (→ SVG via Victor), `FontManager` (ttfunk metrics)

## Commands

```sh
bundle exec rake test          # run all tests
bundle exec ruby app/main.rb examples    # build all example SVGs
bundle exec ruby app/main.rb examples class  # build single example
bundle exec ruby app/main.rb script.rb   # build any .rb → .svg
```

## Environment variables

| Var | Default | Effect |
|-----|---------|--------|
| `SPELLRING_LOG` | unset | verbose parser/visualizer logging |
| `SPELLRING_COLOR` | `#9B111E` | SVG stroke color |
| `SPELLRING_FONT` | `Z003` | font family (must be installed) |
| `SPELLRING_DEBUG` | unset | render debug bounding boxes |

## Architecture

**Parser** (`lib/spellrings_rb/parser.rb`):
- Uses `Prism::Translation::Parser34` → `Parser::AST::Node` → `Ring`/`Element` tree
- Ring types: `:library` (file), `:grimoire` (class/module), `:spell` (def/block)
- Element types: `:word` (literals, strings, numbers), `:sigil` (operators, calls), `:ritual` (control flow)
- Single class/module source → no `:library` wrapper (root is grimoire directly)

**Visualizer** (`lib/spellrings_rb/visualizer.rb` + `visualizer/rings.rb`, `visualizer/elements.rb`, `visualizer/utils.rb`):
- Rings: concentric circles with inner/outer border + name text
- Elements: text on arc, sigils as `<use>` references, connecting lines to child rings
- Stars: pentagram (5-point) or Schläfli star for larger sizes
- `add_defs` registers sigils — **sigil IDs in `add_defs` must match parser's `content[:id]`**

**FontManager** (`lib/spellrings_rb/fonts.rb`):
- Uses `ttfunk` to measure text width/height
- Font loaded once, cached by `@font` (TTFunk::File)

## Key conventions

- Sigil IDs: `:bool_true`, `:bool_false` (not `:true`/`:false` — rubocop flags boolean symbols)
- All measurements in SVG are computed via ttfunk, not CSS
- Default font `Z003` (gsfonts pkg: `/usr/share/fonts/gsfonts/Z003-MediumItalic.otf`)
- `.gitignore` excludes `.*` and `*.json` — do not stage dotfiles or JSON
- No formatter or typechecker configured
- Tests: Minitest, match `test/**/test_*.rb`
