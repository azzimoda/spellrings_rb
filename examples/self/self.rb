require_relative '../../lib/spellrings_rb'

def build_myself
  puts 'I am building myself'
  Spellrings.build_file($PROGRAM_NAME)
end

build_myself if __FILE__ == $PROGRAM_NAME
