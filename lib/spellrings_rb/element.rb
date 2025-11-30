# frozen_string_literal: true

module Spellrings
  # Represents any token which can be part of expression, e.g. method call, operator, variable, etc.
  class Element
    def initialize(type, content = {})
      # types:
      # - :word (method names, variable names, literals), content is a String, Numeric, etc.;
      # - :sigil (operators, special methods), content is like { id: String, word: String | nil };
      # - :ritual (flow control), content is like {
      #     type: :if | :unless | :case | :while | :until | :for | :rescue,
      #     condition: Element | Ring,
      #     body: [{
      #       # condition is for elsif, when/in, rescue.
      #       condition: Element | Ring | nil,
      #       elements: [Element | Ring]
      #     }]
      #   }
      @type = type
      @content = content
    end
    attr_accessor :type, :content

    def ==(other)
      @type == other.type && @content == other.content
    end

    def to_h
      { class: :element, type: @type, content: @content }
    end

    def to_json(*args, **kwargs)
      to_h.to_json(*args, **kwargs)
    end

    def size
      chars.size
    end

    def chars
      case [@type, @content]
      in [:grimoire | :spell, _] then @name.nil? ? [' '] : @name.to_s.chars
      in [:word, Complex | Rational] then @content.inspect.gsub(/[()]/, '').chars # @content.inspect.chars
      in [:word, _] then @content.inspect.chars
      in [:sigil, _] then @content[:word]&.to_s&.chars || [@content[:id].to_s[0]]
      in [:ritual, _] then ['R'] # TODO: Return special sigil.
      else
        # puts "Unknown element type: #{inspect}"
        [' '] # TODO: Return special sigil.
      end
    end
  end
end
