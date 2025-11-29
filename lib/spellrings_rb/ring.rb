# frozen_string_literal: true

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

    def ==(other)
      unless other.is_a?(Ring)
        puts "other is not a Ring: #{other.inspect}"
        return false
      end

      unless @type == other.type && @kind == other.kind
        puts "#{type}, #{kind} != #{other.type}, #{other.kind}"
        return false
      end

      unless @name == other.name
        puts "#{name} != #{other.name}"
        return false
      end

      unless meta == other.meta
        puts "#{meta.inspect} != #{other.meta.inspect}"
        return false
      end

      unless elements.size == other.elements.size
        puts "#{elements.inspect} != #{other.elements.inspect}"
        return false
      end

      elements.zip(other.elements).all? do |a, b|
        if a != b
          puts "#{a.inspect} != #{b.inspect}"
          return false
        end
      end
      true
    end

    def meta
      @content[:meta]
    end

    def elements
      @content[:elements]
    end

    def elements_chars
      elements.map { it.chars.size + SPACE_SIZE }.sum
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
