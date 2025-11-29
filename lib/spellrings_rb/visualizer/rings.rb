# frozen_string_literal: true

require_relative 'utils'
require_relative 'elements'

module Spellrings
  class Visualizer
    private

    def draw_ring(circle, transform: nil)
      log "draw circle: #{circle.name}, #{transform.inspect}"

      r = circle.size * FONT_WIDTH
      svg.g class: "circle #{circle.type} #{circle.kind}", transform: transform do
        # Decorations
        draw_ring_decorations circle

        # Ring
        svg.circle r: r
        svg.circle r: r + LINE_HEIGHT

        # Elements
        svg.g transform: 'rotate(-90)' do
          i = 0
          circle.elements.each do |el|
            draw_element el, i, circle
            i += el.chars.size + SPACE_SIZE
          end
        end
      end
    end

    def draw_ring_decorations(circle)
      # Name
      svg.text circle.name

      # Other
      case circle.type
      when :grimoire then draw_grimoire_decorations circle
      when :spell then draw_spell_decorations circle
      end
    end

    def draw_grimoire_decorations(circle)
      # TODO: Implement draw_grimoire_decorations method.
      elements = circle.elements.size
      draw_star elements * 2, elements - 2, circle.size * FONT_WIDTH
    end

    def draw_spell_decorations(circle)
      # TODO: Implement draw_spell_decorations method.
    end
  end
end
