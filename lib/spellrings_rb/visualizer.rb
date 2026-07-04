# frozen_string_literal: true

require 'ostruct'
require 'victor'
require_relative 'visualizer/rings'
require_relative 'visualizer/layout'
require_relative 'fonts'

module Spellrings
  # Spellrings visualizer
  class Visualizer
    DEFAULT_OPTIONS = {
      color: '#9B111E',
      font_family: 'Z003',
      font_size: 12,
      viewbox_padding: 10.0
    }.freeze

    def initialize(library, **opts)
      @library = library
      @opts = DEFAULT_OPTIONS.clone.merge opts
    end
    attr_reader :svg

    def initialize_metrics
      @font_height = FontManager.font_height @font, @font_size
      @space_width = FontManager.str_width(' ', @font, @font_size)
      @line_height = 2.5 * @font_height
      @sigil_viewbox_width = 2.0 * @line_height
      @sigil_viewbox =
        "#{-0.5 * @sigil_viewbox_width} #{-0.5 * @sigil_viewbox_width} " \
        "#{@sigil_viewbox_width} #{@sigil_viewbox_width}"
    end

    # Generate SVG from the library.
    def generate_svg(output = nil, viewbox: nil, **opts)
      @opts = @opts.merge opts
      @font = FontManager.load @opts[:font_family]
      @font_size = @opts[:font_size]
      @color = @opts[:color]
      @viewbox_padding = @opts[:viewbox_padding]
      initialize_metrics

      compute_layout @library

      x, y, width, height = viewbox ? viewbox.split(' ').map(&:to_f) : compute_viewbox
      log "viewBox: #{x} #{y} #{width} #{height}"

      @svg = Victor::SVG.new viewBox: "#{x} #{y} #{width} #{height}", font_family: @opts[:font_family]

      if ENV['SPELLRING_DEBUG']
        svg.rect x: x, y: y, width: width, height: height, class: 'debug'
        points = collect_points @library
        points.each { |v| svg.circle cx: v[0], cy: v[1], r: 0.5, class: 'debug' }
      end

      add_style
      add_defs
      draw_ring @library
      svg.tap { svg.save output if output }
    end
    alias cast generate_svg

    private

    STYLE = <<~CSS
      * {
          stroke-width: 0.75;
          --color: COLOR;
      }

      text {
          font-family: FONT_FAMILY;
          font-size: FONT_SIZEpx;
          text-anchor: middle;
          dominant-baseline: middle;
          fill: var(--color);
      }

      line,
      circle,
      polygon,
      path {
          fill: none;
          stroke: var(--color);
      }

      .debug {
          fill: none;
          stroke: yellow;
      }

      text.debug {
          fill: yellow;
          font-family: sans-serif;
          font-size: 10px;
          text-anchor: start;
          dominant-baseline: hanging;
      }
    CSS

    def add_style
      svg.style STYLE.sub('COLOR', @color).sub('FONT_FAMILY', @opts[:font_family]).sub('FONT_SIZE', @font_size.to_s)
    end

    def add_defs
      svg.defs do
        def_sigil :begin do
          draw_star(0.4 * @sigil_viewbox_width, 5)
        end

        def_sigil :bool_true do
          svg.text 'T'
          svg.g(transform: 'translate(0,1.5)') { draw_star 0.25 * @sigil_viewbox_width, 3 }
        end

        def_sigil :bool_false do
          svg.text 'F'
          svg.g(transform: 'translate(0,1.5)') { draw_star 0.25 * @sigil_viewbox_width, 3 }
        end

        def_sigil :nil do
          svg.text 'N'
          svg.g(transform: 'translate(0,1.5)') { draw_star 0.25 * @sigil_viewbox_width, 3 }
        end

        def_sigil :send do
          svg.circle r: 0.15 * @sigil_viewbox_width
          svg.line x1: 0, y1: -0.2 * @sigil_viewbox_width,
                  x2: 0, y2: 0.2 * @sigil_viewbox_width
        end

        def_sigil :if do
          r = 0.3 * @sigil_viewbox_width
          svg.polygon points: "0,#{-r} #{r},0 0,#{r} #{-r},0"
        end

        def_sigil :block do
          r = 0.25 * @sigil_viewbox_width
          svg.circle r: r
          svg.circle r: r * 0.6
        end

        def_sigil :assign do
          svg.line x1: -0.3 * @sigil_viewbox_width, y1: 0,
                  x2: 0.3 * @sigil_viewbox_width, y2: 0
        end

        def_sigil :unknown do
          svg.circle r: 0.25 * @sigil_viewbox_width
        end
      end
    end

    def def_sigil(name, **kwargs, &block)
      (@sigils ||= []) << name
      kwargs.merge!(id: "sigil_#{name}", viewBox: @sigil_viewbox, width: @sigil_viewbox_width,
                    height: @sigil_viewbox_width)
      svg.symbol(**kwargs) { block.call }
    end

    # Computes canvas sizes from preparsed library.
    def compute_viewbox
      x_min, x_max, y_min, y_max = peak_points @library
      double_padding = @viewbox_padding * 2
      [x_min - @viewbox_padding,
       y_min - @viewbox_padding,
       x_max - x_min + double_padding,
       y_max - y_min + double_padding]
    end

    # Finds most left, right, top, and bottom points of preparsed library.
    def peak_points(library, center: Vector[0, 0], start_angle: 0)
      points = collect_points library, center: center, start_angle: start_angle
      [*points.map { |v| v[0] }.minmax, *points.map { |v| v[1] }.minmax]
    end

    def collect_points(library, center: Vector[0, 0], start_angle: 0)
      radius = library.radius @font, @font_size
      outer_radius = radius + @line_height
      circle_length = library.circle_length @font, @font_size

      points = [
        center + Vector[outer_radius, 0], center + Vector[0, outer_radius],
        center - Vector[outer_radius, 0], center - Vector[0, outer_radius]
      ]
      points.concat find_all_points library, radius, outer_radius, circle_length, start_angle, center
      points
    end

    def find_all_points(library, radius, outer_radius, circle_length, start_angle, center = Vector[0, 0])
      i = 0
      points = []
      library.elements.each do |element|
        unless element.is_a? Ring
          i += element.width(@font, @font_size) + @space_width
          next
        end

        child_center_distance = layout_distance library, element

        angle = rotation_angle start_angle, i, element.width(@font, @font_size), circle_length
        child_center = center + Vector[child_center_distance * Math.cos(angle),
                                       child_center_distance * Math.sin(angle)]
        points << center + Vector[radius * Math.cos(angle), radius * Math.sin(angle)]
        points += collect_points element, center: child_center, start_angle: -Math::PI / 2 + angle

        i += element.width(@font, @font_size) + @space_width
      end
      points
    end

    def rotation_angle(start_angle, idx, element_width, circle_length)
      start_angle - Math::PI / 2 - 2 * Math::PI * (idx + 0.5 * element_width) / circle_length
    end

    def log(*args)
      @log ||= ENV['SPELLRING_LOG']
      puts "VISUALIZER: #{args.join(' ')}" if @log && @log !~ /^(false|0|)$/i
    end
  end
end
