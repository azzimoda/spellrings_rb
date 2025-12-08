#!ruby
# frozen_string_literal: true

require_relative '../lib/spellrings_rb'

EXAMPLES_DIR = File.expand_path('../examples', __dir__)
EXAMPLES = Dir.glob(File.join(EXAMPLES_DIR, '*')).select { |f| File.directory? f }.map { |d| File.basename d }
DEFAULT_FONT = 'Z003'

def build_example(name)
  unless EXAMPLES.include? name
    puts "Example '#{name}' not found."
    puts "Available examples: #{EXAMPLES.join(', ')}"
    exit 1
  end

  puts "Building example '#{name}'..."
  Spellrings.build_file File.join(EXAMPLES_DIR, name, "#{name}.rb")
  puts "Done! Look for example '#{name}' here: #{File.join(EXAMPLES_DIR, name, "#{name}.svg")}"
end

def build_examples
  Dir.glob(File.join(EXAMPLES_DIR, '*')).select { |f| File.directory? f }.each do |dir|
    puts "Building #{dir}..." if ENV['SPELLRING_LOG']
    Spellrings.build_file File.join(dir, "#{File.basename(dir)}.rb")
  end
  puts "Done! Look for examples here: #{EXAMPLES_DIR}"
end

def build_file(source_file, output_file = nil)
  puts "Building #{source_file}..."
  output_file ||= File.join(File.dirname(source_file), "#{File.basename(source_file, '.rb')}.svg")
  Spellrings.build_file source_file, output_file: output_file, font_family: ENV['SPELLRING_FONT'] || DEFAULT_FONT
  puts "Done! Look for output file here: #{output_file}"
end

if __FILE__ == $PROGRAM_NAME

  case ARGV
  in ['examples', 'list']        then puts "Available examples: #{EXAMPLES.join(', ')}"
  in ['examples', name]          then build_example name
  in ['examples']                then build_examples
  in ['node_types', source_file] then puts "#{source_file}:\n#{Spellrings.node_types(File.read(source_file)).to_a.sort}"
  in [source_file, *rest] if rest.size <= 1 then build_file source_file, *rest
  else
    puts <<~TEXT
      Usage:

          #{$PROGRAM_NAME} examples list
              Lists all available examples.


          #{$PROGRAM_NAME} examples [<name>]
              Builds all examples or the specified example.

          #{$PROGRAM_NAME} <source_file> [<output_file>]
              Builds the source file to the output file. If no output file is given, it will be
              written to the same directory as the source file with the same name but with a .svg
              extension.

          #{$PROGRAM_NAME} node_types <source_file>
              Prints the node types in the source file.

      Environment variables:

          SPELLRING_LOG
              default: nil
              If set, prints information about the building process.

          SPELLRING_COLOR
              default: #9B111E
              If set, uses color in the output SVG file.
    TEXT
  end
end
