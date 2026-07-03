# frozen_string_literal: true

require_relative 'test_helper'

class TestParser < Minitest::Test
  def test_parse_literals
    source = <<~RUBY
      true
      false
      nil
      42
      3.14
      "string"
      :symbol
    RUBY

    lib = Spellrings::Parser.parse source
    assert_equal :library, lib.type
    assert_equal 'Library', lib.name

    elements = lib.elements
    assert_equal 8, elements.size
    assert_equal :sigil, elements[0].type
    assert_equal :bool_true, elements[1].content[:id]
    assert_equal :bool_false, elements[2].content[:id]
    assert_equal :nil, elements[3].content[:id]
    assert_equal :word, elements[4].type
    assert_equal 42, elements[4].content
  end

  def test_parse_class
    source = <<~RUBY
      class Foo
        def bar
          42
        end
      end
    RUBY

    lib = Spellrings::Parser.parse source
    assert_equal :grimoire, lib.type
    assert_equal :class, lib.kind
    assert_equal :Foo, lib.name

    _begin_sigil, spell = lib.elements
    assert_equal :spell, spell.type
    assert_equal :def, spell.kind
    assert_equal :bar, spell.name
  end

  def test_parse_module
    source = <<~RUBY
      module M
        def foo; end
      end
    RUBY

    lib = Spellrings::Parser.parse source
    assert_equal :grimoire, lib.type
    assert_equal :module, lib.kind
    assert_equal :M, lib.name
  end

  def test_parse_send
    source = "puts 'hello'"
    lib = Spellrings::Parser.parse source
    elements = lib.elements

    assert elements.any? { |e| e.type == :sigil && e.content[:id] == :send }
  end

  def test_parse_method_with_args
    source = <<~RUBY
      def add(a, b)
        a + b
      end
    RUBY

    lib = Spellrings::Parser.parse source
    assert_equal :spell, lib.type
    assert_equal :def, lib.kind
    assert_equal :add, lib.name
    refute_nil lib.content[:args]
    assert_equal 2, lib.content[:args].size
  end

  def test_parse_file_type
    Dir.mktmpdir do |dir|
      path = File.join dir, 'script.rb'
      File.write path, "42\nclass Foo; end"
      lib = Spellrings::Parser.parse_file path
      assert_equal :library, lib.type
      assert_equal 'script', lib.name
    end
  end
end
