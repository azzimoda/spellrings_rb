# frozen_string_literal: true

require_relative 'test_helper'
require 'matrix'

class TestLayout < Minitest::Test
  FONT_SIZE = 12

  def collect_rings(ast)
    font = Spellrings::FontManager.load 'Z003'
    viz = Spellrings::Visualizer.new ast
    viz.cast

    cache = viz.instance_variable_get(:@layout_cache)
    line_h = 2.5 * Spellrings::FontManager.font_height(font, FONT_SIZE)
    rings = []

    q = [[ast, Vector[0, 0], -Math::PI / 2]]
    until q.empty?
      ring, center, sa = q.shift
      inner = ring.radius(font, FONT_SIZE)
      outer = inner + line_h
      rings << { name: ring.name, type: ring.type, center: center, outer: outer }

      i = 0
      ring.elements.each do |el|
        if el.is_a?(Spellrings::Ring)
          d = cache[[ring.object_id, el.object_id]]
          mid = i + el.width(font, FONT_SIZE) / 2.0
          cl = ring.circle_length(font, FONT_SIZE)
          angle = sa - 2 * Math::PI * mid / cl
          child_center = center + Vector[d * Math.cos(angle), d * Math.sin(angle)]
          q << [el, child_center, -Math::PI / 2 + angle]
        end
        i += el.width(font, FONT_SIZE) + Spellrings::SPACE_SIZE
      end
    end
    rings
  end

  def assert_no_ring_overlaps(rings, message)
    overlaps = []
    rings.combination(2).each do |a, b|
      next if (a[:center] - b[:center]).magnitude < 1

      dist = (a[:center] - b[:center]).magnitude
      min_dist = a[:outer] + b[:outer] + 2
      if min_dist - dist > 0.5
        overlaps << "#{a[:name]}(#{a[:type]}) vs #{b[:name]}(#{b[:type]}): " \
                     "dist=#{dist.round(1)} need=#{min_dist.round(1)}"
      end
    end
    assert overlaps.empty?, "#{message}: #{overlaps.first(3).join('; ')}"
  end

  EXAMPLES = %w[class module functions script self].freeze

  EXAMPLES.each do |name|
    define_method "test_#{name}_example_no_overlaps" do
      src = File.read("examples/#{name}/#{name}.rb")
      ast = Spellrings::Parser.parse(src)
      rings = collect_rings(ast)
      assert_no_ring_overlaps rings, "#{name}.rb"
    end
  end

  def test_dense_methods_no_overlaps
    src = File.read('examples/dense_methods/dense_methods.rb')
    ast = Spellrings::Parser.parse(src)
    rings = collect_rings(ast)
    assert_no_ring_overlaps rings, 'dense_methods.rb'
  end
end
