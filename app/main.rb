# frozen_string_literal: true

require_relative '../lib/spellrings_rb'

EXAMPLES_DIR = File.expand_path('../examples', __dir__)

def build_examples
  Dir.glob(File.join(EXAMPLES_DIR, '*')).select { |f| File.directory? f }.each do |dir|
    puts "Building #{dir}..." if ENV['SPELLRING_LOG']
    Spellrings.build_file File.join(dir, "#{File.basename(dir)}.rb")
  end
  puts "Done! Look for examples here: #{EXAMPLES_DIR}"
end

if ARGV[0] == 'examples' then build_examples
elsif ARGV[0] == 'node_types' then Spellrings.node_types File.read ARGV[1]
elsif __FILE__ == $PROGRAM_NAME
  output_file = Spellrings.build_file ARGV[0], ARGV[1]
  puts "Done! Look for your spellrings here: #{output_file}"
else
  puts "Usage: #{$PROGRAM_NAME} [examples|source_file.rb [output_file.svg]]"
end
