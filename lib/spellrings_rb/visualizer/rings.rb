# frozen_string_literal: true

require_relative 'utils'
require_relative 'elements'

module Spellrings
  class Visualizer
    private

    def draw_ring(ring, transform: nil)
      log "ring: #{ring.name}, #{transform.inspect}"

      radius = ring.radius @font, @font_size
      svg.g class: "ring #{ring.type} #{ring.kind}", transform: transform do
        # Decorations
        decorate_ring ring

        # Ring
        svg.circle r: radius
        svg.circle r: radius + @line_height

        # Elements
        svg.g transform: 'rotate(-90)' do
          unless ring.type == :library
            log ring.type
            svg.line x1: 0, y1: radius + @line_height + 2,
                     x2: 0, y2: radius + @line_height * 2 - 2,
                     transform: 'rotate(-90)'
          end

          i = 0
          ring.elements.each do |el|
            draw_element el, i, ring
            i += el.width(@font, @font_size) + @space_width
          end
        end
      end
    end

    def decorate_ring(ring)
      # Name
      svg.text ring.name

      # Other
      case ring.type
      when :library  then decorate_library  ring
      when :grimoire then decorate_grimoire ring
      when :spell    then decorate_spell    ring
      end
    end

    def decorate_library(ring)
      # TODO: Implement decorate_library
    end

    def decorate_grimoire(ring)
      draw_star ring.radius(@font, @font_size), ring.elements.size
    end

    def decorate_spell(ring)
      # TODO: Implement decorate_spell
    end
  end
end
