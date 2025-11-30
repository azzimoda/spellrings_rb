# frozen_string_literal: true

module Spellrings
  class Visualizer # rubocop:disable Style/Documentation
    private

    def draw_element(element, start, ring)
      log "element: #{element.type} #{element.content}, #{start}"

      underline_element element, start, ring
      decorate_element element, start, ring

      el_transform = element_transform(start, ring.elements_chars, ring.size)

      case [element.type, element.content]
      in [:grimoire | :spell, _]
        # TODO: Draw sigil of the ring.
        # svg.text element.type.to_s[0].upcase, transform: el_transform
        draw_word Element.new(:word, element.name), start, ring
        draw_ring element, transform: child_cicle_transform(start + element.chars.size / 2.0, ring, element)

      in [:word, Complex | Rational] then draw_word element.content.inspect.gsub(/[()]/, ''), start, ring
      in [:word, _] then draw_word element.content.inspect, start, ring
      in [:sigil, _] then draw_sigil element, start, ring
      in [:ritual, _] then draw_sigil(Element.new(:sigil, id: :unknown, word: 'ritual'), transform: el_transform)
      else draw_sigil Element.new(:sigil, id: :unknown, word: 'unknown'), transform: el_transform
      end
    end

    def underline_element(element, start, ring)
      radius = ring.size * FONT_WIDTH + LINE_HEIGHT + 2
      element_angle = 2 * Math::PI / ring.elements_chars
      angle = 2 * Math::PI * (element.chars.size + 1) / ring.elements_chars
      transform =
        "rotate(#{-360 * start / ring.elements_chars})" \
        "rotate(#{(-angle + element_angle) * 360 / (2 * Math::PI)})"
      circle_sector r: radius, start_angle: 0, end_angle: angle, transform: transform
    end

    def decorate_element(element, start, ring)
      case [element.type, element.content]
      in [:word, String] then decorate_string element, start, ring
        # in [:word, Symbol] then decorate_symbol element, start, ring
        # in [:word, Regexp] then decorate_regexp element, start, ring
      else
      end
    end

    def decorate_string(element, start, ring)
      angle = 2 * Math::PI * (element.chars.size - 1) / ring.elements_chars
      transform =
        "rotate(#{-360 * start / ring.elements_chars})" \
        "rotate(#{-angle * 360 / (2 * Math::PI)})"

      r0 = ring.size * FONT_WIDTH
      circle_sector r: r0 + 0.75 * LINE_HEIGHT, start_angle: 0, end_angle: angle, transform: transform
      circle_sector r: r0 + 0.25 * LINE_HEIGHT, start_angle: 0, end_angle: angle, transform: transform

      transform = "#{element_transform(start, ring.elements_chars, ring.size)} rotate(90)"
      circle_sector r: 0.25 * LINE_HEIGHT, start_angle: 0, end_angle: Math::PI, transform: transform

      transform = "#{element_transform(start + element.chars.size - 1, ring.elements_chars, ring.size)} rotate(-90)"
      circle_sector r: 0.25 * LINE_HEIGHT, start_angle: 0, end_angle: Math::PI, transform: transform
    end

    def draw_word(word, start, ring)
      word.chars.each_with_index do |char, i|
        transform = element_transform(start + i, ring.elements_chars, ring.size)
        svg.text char, transform: transform
      end
    end

    def draw_call(element, start, ring)
      draw_sigil :call, transform: element_transform(start, ring.elements_chars, ring.size)
      draw_name element.content[:name], start + 1, ring
    end

    def draw_name(name, start, ring)
      name.to_s.chars.each_with_index do |char, i|
        svg.text char, transform: element_transform(start + i, ring.elements_chars, ring.size)
      end
    end

    def draw_sigil(element, start, ring)
      href = @sigils.include?(element.content[:id]) ? "#sigil_#{element.content[:id]}" : '#sigil_unknown'
      if element.content[:word]
        draw_word element.content[:word].to_s, start, ring
        transform = element_transform start + element.content[:word].size / 2, ring.elements_chars, ring.size
      else
        transform = element_transform start, ring.elements_chars, ring.size
      end
      svg.use href: href, transform: "#{transform} #{sigil_transform}"
    end

    def sigil_transform
      "translate(#{-SIGIL_VIEWBOX_WIDTH / 2}, #{-SIGIL_VIEWBOX_WIDTH / 2})"
    end

    def child_cicle_transform(idx, parent_ring, child_ring)
      "#{rotate_transform(idx, parent_ring.elements_chars)}" \
      "translate(0,#{(parent_ring.size + child_ring.size) * FONT_WIDTH + LINE_HEIGHT * 3})"
    end

    def element_transform(idx, size, radius)
      "#{rotate_transform(idx, size)} translate(0,#{radius * FONT_WIDTH + LINE_HEIGHT / 2})"
    end

    def rotate_transform(idx, size, angle_offset = 0)
      angle = 2 * Math::PI * idx / size
      degrees = angle_offset - 90 - angle * 180 / Math::PI
      "rotate(#{degrees})"
    end
  end
end
