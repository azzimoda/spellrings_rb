# frozen_string_literal: true

require 'matrix'
require_relative 'element'

module Spellrings
  SPACE_SIZE = 2

  # Represents a file, class, module, method, or block.
  class Ring < Element
    def initialize(type, kind, name, meta = {}, &block)
      super type, { meta: meta, elements: [] }
      # type: :library, :grimoire (kind: :class, :module), :spell (kind: :method, :block)

      @kind = kind
      @name = name
      @measures = nil

      return unless block_given?

      instance_eval(&block)
    end
    attr_accessor :kind, :name

    def meta
      @content[:meta]
    end

    def elements
      @content[:elements]
    end

    def elements_chars
      elements.map { it.chars.size + SPACE_SIZE }.sum
    end

    def peak_points(center: Vector[0, 0], start_angle: 0)
      radius = size * Visualizer::FONT_WIDTH
      full_radius = radius + Visualizer::LINE_HEIGHT

      points = [center,
                center + Vector[full_radius, 0],
                center + Vector[0, full_radius],
                center - Vector[full_radius, 0],
                center - Vector[0, full_radius]]

      i = 0
      elements.each do |element|
        unless element.is_a?(Ring)
          i += element.chars.size + SPACE_SIZE
          next
        end

        child_center_distance = full_radius + element.size * Visualizer::FONT_WIDTH + Visualizer::LINE_HEIGHT * 2
        angle = start_angle - Math::PI / 2 - 2 * Math::PI * (i + element.chars.size / 2.0) / elements_chars
        child_center = center + Vector[child_center_distance * Math.cos(angle),
                                       child_center_distance * Math.sin(angle)]
        points += element.peak_points(center: child_center, start_angle: -Math::PI / 2 + angle)

        i += element.chars.size + SPACE_SIZE
      end

      points
    end

    def size
      [elements_chars / (2 * Math::PI), name.to_s.size / 2.0 + 1].max
    end

    def <<(element)
      elements << element
    end

    def element(...)
      elements << Element.new(...)
    end

    def ring(...)
      elements << Ring.new(...)
    end

    def to_h
      { class: :ring, type: @type, kind: @kind, name: @name, content: @content }
    end

    def to_json(*args, **kwargs)
      to_h.to_json(*args, **kwargs)
    end
  end
end
