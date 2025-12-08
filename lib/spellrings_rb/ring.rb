# frozen_string_literal: true

require 'matrix'
require_relative 'element'
require_relative 'fonts'

module Spellrings
  SPACE_SIZE = 2

  # Represents a file, class, module, method, or block.
  class Ring < Element
    def initialize(type, kind, name, content = {}, &block)
      super type, content
      # type: :library, :grimoire (kind: :class, :module), :spell (kind: :method, :block)

      @kind = kind
      @name = name
      @measures = nil

      return unless block_given?

      instance_eval(&block)
    end
    attr_accessor :kind, :name

    def elements
      @content[:elements] ||= []
    end

    def radius(font, font_size)
      [circle_length(font, font_size) / (2 * Math::PI),
       FontManager.str_width(@name.to_s, font, font_size) / 2.0 + 1].max
    end

    def circle_length(font, font_size)
      space_width = FontManager.str_width ' ', font, font_size
      elements.map { FontManager.str_width(it.chars.join, font, font_size) + space_width }.sum
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
