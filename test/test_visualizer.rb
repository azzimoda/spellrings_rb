# frozen_string_literal: true

require_relative 'test_helper'

class TestVisualizer < Minitest::Test
  def setup
    @source = <<~RUBY
      true
      false
      42
    RUBY
    @library = Spellrings::Parser.parse @source
  end

  def test_generate_svg_returns_victor_svg
    viz = Spellrings::Visualizer.new @library
    svg = viz.generate_svg
    assert svg
    assert_match(%r{</style>}, svg.to_s)
    assert_match(%r{<defs>}, svg.to_s)
  end

  def test_generate_svg_contains_ring_elements
    viz = Spellrings::Visualizer.new @library
    svg = viz.generate_svg
    output = svg.to_s
    assert_match(/ring library/, output)
    assert_match(/Library/, output)
  end

  def test_generate_svg_contains_sigils
    viz = Spellrings::Visualizer.new @library
    svg = viz.generate_svg
    output = svg.to_s
    assert_match(/sigil_bool_true/, output)
    assert_match(/sigil_bool_false/, output)
  end

  def test_generate_svg_with_custom_color
    viz = Spellrings::Visualizer.new @library, color: '#ff0000'
    svg = viz.generate_svg
    assert_match(/--color: #ff0000/, svg.to_s)
  end

  def test_generate_svg_writes_to_file
    viz = Spellrings::Visualizer.new @library
    path = File.join Dir.tmpdir, "test_#{Time.now.to_i}.svg"
    viz.generate_svg path
    assert File.exist?(path)
    File.delete path
  end

  def test_visualizer_accepts_custom_font
    viz = Spellrings::Visualizer.new @library, font_family: 'Z003', font_size: 14
    svg = viz.generate_svg
    assert_match(/Z003/, svg.to_s)
  end
end
