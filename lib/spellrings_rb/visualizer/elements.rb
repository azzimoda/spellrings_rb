# frozen_string_literal: true

module Spellrings
  class Visualizer # rubocop:disable Style/Documentation
    private

    def draw_element(element, start, ring)
      log "element: #{element.type} #{element.content}, #{start}"

      underline_element element, start, ring
      decorate_element element, start, ring

      el_transform = element_transform start, ring.circle_length(@font, @font_size), ring.radius(@font, @font_size)

      case [element.type, element.content]
      in [:grimoire | :spell, _]
        # TODO: Draw sigil of the ring.
        # svg.text element.type.to_s[0].upcase, transform: el_transform
        draw_word Element.new(:word, element.name), start, ring
        transform = child_cicle_transform start + element.width(@font, @font_size) / 2.0, ring, element
        draw_ring element, transform: transform

      in [:word, Complex | Rational] then draw_word element.content.inspect.gsub(/[()]/, ''), start, ring
      in [:word, _] then draw_word element.content.inspect, start, ring
      in [:sigil, _] then draw_sigil element, start, ring
      in [:ritual, _] then draw_sigil(Element.new(:sigil, id: :unknown, word: 'ritual'), transform: el_transform)
      else draw_sigil Element.new(:sigil, id: :unknown, word: 'unknown'), transform: el_transform
      end
    end

    def underline_element(element, start, ring)
      radius = ring.radius(@font, @font_size) + @line_height + 2

      circle_length = ring.circle_length @font, @font_size
      element_angle = 2 * Math::PI / circle_length
      angle = element_angle * (element.width(@font, @font_size) + 1)

      transform =
        "rotate(#{-360 * start / circle_length})" \
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
      width = element.width(@font, @font_size) - @space_width
      angle = 2 * Math::PI * width / ring.circle_length(@font, @font_size)
      transform =
        "rotate(#{-360 * start / ring.circle_length(@font, @font_size)})" \
        "rotate(#{-angle * 360 / (2 * Math::PI)})"

      r0 = ring.radius(@font, @font_size)
      circle_sector r: r0 + 0.75 * @line_height, start_angle: 0, end_angle: angle, transform: transform
      circle_sector r: r0 + 0.25 * @line_height, start_angle: 0, end_angle: angle, transform: transform

      circle_length = ring.circle_length @font, @font_size
      transform = "#{element_transform(start, circle_length, r0)} rotate(90)"
      circle_sector r: 0.25 * @line_height, start_angle: 0, end_angle: Math::PI, transform: transform

      transform = "#{element_transform(start + width, circle_length, r0)} rotate(-90)"
      circle_sector r: 0.25 * @line_height, start_angle: 0, end_angle: Math::PI, transform: transform
    end

    def draw_word(word, start, ring)
      shift = 0
      word.chars.each_with_index do |char, _|
        transform =
          element_transform start + shift, ring.circle_length(@font, @font_size), ring.radius(@font, @font_size)
        svg.text char, transform: transform
        # svg.circle cx: 0, cy: 0, r: 0.5, class: 'debug', transform: transform if ENV['SPELLRING_DEBUG']
        shift += FontManager.str_width char, @font, @font_size
      end
    end

    def draw_call(element, start, ring)
      transform = element_transform start, ring.circle_length(@font, @font_size), ring.radius(@font, @font_size)
      draw_sigil :call, transform: transform
      draw_name element.content[:name], start + 1, ring
    end

    def draw_name(name, start, ring)
      name.to_s.chars.each_with_index do |char, i|
        transform = element_transform start + i, ring.circle_length(@font, @font_size), ring.radius(@font, @font_size)
        svg.text char, transform: transform
      end
    end

    def draw_sigil(element, start, ring)
      href = @sigils.include?(element.content[:id]) ? "#sigil_#{element.content[:id]}" : '#sigil_unknown'
      transform =
        if element.content[:word]
          draw_word element.content[:word].to_s, start, ring
          element_transform start + element.content[:word].size / 2,
                            ring.circle_length(@font, @font_size),
                            ring.radius(@font, @font_size)
        else
          element_transform start, ring.circle_length(@font, @font_size), ring.radius(@font, @font_size)
        end
      svg.use href: href, transform: "#{transform} #{sigil_transform}"
    end

    def sigil_transform
      "translate(#{-@sigil_viewbox_width / 2}, #{-@sigil_viewbox_width / 2})"
    end

    def child_cicle_transform(idx, parent_ring, child_ring)
      "#{rotate_transform(idx, parent_ring.circle_length(@font, @font_size))}" \
      "translate(0,#{parent_ring.radius(@font, @font_size) + child_ring.radius(@font, @font_size) + @line_height * 3})"
    end

    def element_transform(idx, size, radius)
      "#{rotate_transform(idx, size)} translate(0,#{radius + @line_height / 2})"
    end

    def rotate_transform(idx, size, angle_offset = 0)
      angle = 2 * Math::PI * idx / size
      degrees = angle_offset - 90 - angle * 180 / Math::PI
      "rotate(#{degrees})"
    end
  end
end
