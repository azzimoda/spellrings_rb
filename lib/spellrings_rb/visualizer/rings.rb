# frozen_string_literal: true

require_relative 'utils'
require_relative 'elements'

module Spellrings
  class Visualizer
    private

    def draw_ring(ring, transform: nil)
      log "ring: #{ring.name}, #{transform.inspect}"

      r = ring.size * FONT_WIDTH
      svg.g class: "ring #{ring.type} #{ring.kind}", transform: transform do
        # Decorations
        decorate_ring ring

        # Ring
        svg.circle r: r
        svg.circle r: r + LINE_HEIGHT

        # Elements
        svg.g transform: 'rotate(-90)' do
          unless ring.type == :library
            svg.line x1: 0, y1: ring.size * FONT_WIDTH + LINE_HEIGHT + 2,
                     x2: 0, y2: ring.size * FONT_WIDTH + LINE_HEIGHT * 2 - 2,
                     transform: 'rotate(-90)'
          end

          i = 0
          ring.elements.each do |el|
            draw_element el, i, ring
            i += el.chars.size + SPACE_SIZE
          end
        end
      end
    end

    def decorate_ring(ring)
      # Name
      svg.text ring.name

      # Other
      case ring.type
      when :library then decorate_library ring # TODO: Implement decorate_library
      when :grimoire then decorate_grimoire ring
      when :spell then decorate_spell ring
      end
    end

    def decorate_library(ring)
      # TODO: Implement decorate_library
    end

    def decorate_grimoire(ring)
      # TODO: Implement decorate_grimoire
      elements = ring.elements.size
      draw_star elements * 2, elements - 2, ring.size * FONT_WIDTH
    end

    def decorate_spell(ring)
      # TODO: Implement decorate_spell
    end
  end
end
