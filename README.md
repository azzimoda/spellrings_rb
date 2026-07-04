# Ruby Spellrings

Visualize your Ruby code as magical circles (SVG).

Inspired by [denismm/mystical_ps](https://github.com/denismm/mystical_ps).

---

<img src="https://github.com/azzimoda/spellrings_rb/raw/main/examples/self/self.svg" alt="example" width="555px" />

---

## Installation

```sh
bundle install
```

Requires Ruby 3.x+. The default font `Z003` comes from the `gsfonts` package:

```sh
# Debian / Ubuntu
sudo apt install gsfonts
```

## Usage

### CLI

```sh
# Build all examples
bundle exec ruby app/main.rb examples

# Build a specific example
bundle exec ruby app/main.rb examples class

# Build any Ruby file
bundle exec ruby app/main.rb script.rb

# List node types in a file
bundle exec ruby app/main.rb node_types script.rb
```

### Library

```ruby
require_relative 'lib/spellrings_rb'

Spellrings.build_file 'script.rb'
```

## Environment variables

| Variable | Default | Effect |
|----------|---------|--------|
| `SPELLRING_LOG` | unset | verbose parser/visualizer logging |
| `SPELLRING_COLOR` | `#9B111E` | SVG stroke color |
| `SPELLRING_FONT` | `Z003` | font family (must be installed) |
| `SPELLRING_DEBUG` | unset | render debug bounding boxes |

## Examples

| Source | SVG |
|--------|-----|
| `class.rb` | ![class](examples/class/class.svg) |
| `functions.rb` | ![functions](examples/functions/functions.svg) |
| `module.rb` | ![module](examples/module/module.svg) |
| `script.rb` | ![script](examples/script/script.svg) |
| `self.rb` | ![self](examples/self/self.svg) |

## License

MIT
