# frozen_string_literal: true

require 'prism'
require_relative 'ring'
require_relative 'element'

module Spellrings
  # Parses a Ruby source file and returns a Library object.
  module Parser
    RING_TOKENS = %i[module class def].freeze

    module_function

    def parse_file(file_path)
      ast = Prism::Translation::Parser34.parse_file file_path
      lib_name = File.basename file_path, '.rb'
      on_ring ast, lib: lib_name
    end

    def parse(source)
      on_ring Prism::Translation::Parser34.parse(source), name: 'Library'
    end

    def log(*args)
      @log ||= ENV['SPELLRING_LOG']
      puts "PARSER: #{args.join(' ')}" if @log && @log !~ /^(false|0|)$/i
    end

    # Ring related methods.

    def on_ring(ast, lib: nil)
      log "ring: #{ast.to_sexp}"

      case ast.type
      in :begin if lib then on_library ast, name: lib
      in :class then on_class ast
      in :module then on_module ast
      in :def then on_def ast
      else Ring.new(:spell, :block, lib).tap { parse_body ast, it }
      end
    end

    def on_library(ast, name:)
      log "library #{name}"
      Ring.new(:library, nil, name).tap { parse_body ast, it }
    end

    def on_class(ast)
      log "class: #{ast.children[0].children[1]}"
      Ring.new(:grimoire, :class, ast.children[0].children[1]).tap { parse_body ast.children[2], it }
    end

    def on_module(ast)
      log "module: #{ast.children[0].children[1]}"
      Ring.new(:grimoire, :module, ast.children[0].children[1]).tap { parse_body ast.children[1], it }
    end

    def on_def(ast)
      log "def: #{ast.children[0]}"
      Ring.new(:spell, :def, ast.children[0], args: on_args(ast.children[1])).tap do
        parse_body ast.children[2], it
      end
    end

    def on_args(ast)
      log "args: #{ast.to_sexp}"
      ast.children.map.with_object([]) do |arg, args|
        args << Element.new(arg.type, arg.children[0])
      end
    end

    def parse_body(ast, ring)
      log "body: #{ast.inspect}"
      ring << Element.new(:sigil, id: :begin, word: ring.type.to_s[0].upcase)
      case ast.type
      in :begin then on_begin ast, ring
      else on_element ast, ring
      end
    end

    def on_begin(ast, ring)
      log "begin: #{ast.to_sexp}"
      ast.children.each { |child| on_element child, ring }
    end

    # Element related methods.

    def on_element(ast, ring)
      log "element: #{ast.type}"

      case ast.type
      in type if RING_TOKENS.include? type then ring << on_ring(ast)

      in :true then ring << Element.new(:sigil, id: :true) # rubocop:disable Lint/BooleanSymbol
      in :false then ring << Element.new(:sigil, id: :false) # rubocop:disable Lint/BooleanSymbol
      in :nil then ring << Element.new(:sigil, id: :nil)
      in :int | :float | :str | :sym | :complex | :rational
        ring << Element.new(:word, ast.children[0])
      in :regexp then ring.element :word, Regexp.new(ast.children[0].children[0])

      in :send then on_send ast, ring
      # in :block then parse_block ast

      else Element.new :unknown, ast
      end
    end

    def on_send(ast, ring)
      log "Parsing send: #{ast.to_sexp}"

      receiver, name, *args = ast.children

      ring.element :sigil, id: :unknown, word: receiver.to_s
      ring.element :sigil, id: :send, word: name
      args.each { on_element it, ring }
    end
  end
end
