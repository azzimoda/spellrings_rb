# frozen_string_literal: true

require 'ostruct'
require 'victor'
require_relative 'visualizer/rings'
require_relative 'fonts'

module Spellrings
  class Visualizer
    DEFAULT_COLOR = '#9B111E'
    DEFAULT_FONT_SIZE = 12
    DEFAULT_FONT_FAMILY = 'Z003'

    VIEWBOX_PADDING = 10.0

    def initialize(library)
      @library = library
    end
    attr_reader :svg

    def initilize_metrics
      @font_height = FontManager.font_height @font, @font_size
      @space_width = FontManager.str_width(' ', @font, @font_size)
      @line_height = 2.5 * @font_height
      @sigil_viewbox_width = 2.0 * @line_height
      @sigil_viewbox =
        "#{-0.5 * @sigil_viewbox_width} #{-0.5 * @sigil_viewbox_width} " \
        "#{@sigil_viewbox_width} #{@sigil_viewbox_width}"
    end

    # Generate SVG file from the library.
    def generate_svg(font_family: DEFAULT_FONT_FAMILY, font_size: DEFAULT_FONT_SIZE, color: DEFAULT_COLOR,
                     output_file: nil, viewbox: nil)
      @font_family = font_family
      @font = FontManager.load font_family
      @font_size = font_size
      initilize_metrics
      @color = color

      x, y, width, height = viewbox ? viewbox.split(' ').map(&:to_f) : compute_viewbox
      log "viewBox: #{x} #{y} #{width} #{height}"

      @svg = Victor::SVG.new viewBox: "#{x} #{y} #{width} #{height}", font_family: @font_family

      if ENV['SPELLRING_DEBUG']
        svg.rect x: x, y: y, width: width, height: height, class: 'debug'
        points = peak_points @library
        points.each { |v| svg.circle cx: v[0], cy: v[1], r: 0.5, class: 'debug' }
      end

      add_style
      add_defs
      draw_ring @library
      svg.tap { svg.save output_file if output_file }
    end
    alias cast generate_svg

    private

    def add_style
      svg.style <<~CSS
        * {
          stroke-width: 0.75;
          --color: #{@color};
        }

        text {
          font-family: Z003;
          font-size: #{@font_size}px;
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
    end

    def add_defs
      # TODO: Add more sigils
      svg.defs do
        def_sigil :begin do
          # svg.polygon points: star_points(5, 2, 0.4 * @sigil_viewbox_width).map { it.join(',') }.join(' ')
          draw_star(0.4 * @sigil_viewbox_width, 5)
        end

        def_sigil :true do # rubocop:disable Lint/BooleanSymbol
          svg.text 'T'
          svg.g(transform: 'translate(0,1.5)') { draw_star 0.25 * @sigil_viewbox_width, 3 }
        end

        def_sigil :false do # rubocop:disable Lint/BooleanSymbol
          svg.text 'F'
          svg.g(transform: 'translate(0,1.5)') { draw_star 0.25 * @sigil_viewbox_width, 3 }
        end

        def_sigil :nil do
          svg.text 'N'
          svg.g(transform: 'translate(0,1.5)') { draw_star 0.25 * @sigil_viewbox_width, 3 }
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

    def compute_viewbox
      points = peak_points @library
      x_min, x_max = points.map { it[0] }.minmax
      y_min, y_max = points.map { it[1] }.minmax

      width = x_max - x_min
      height = y_max - y_min

      [x_min - VIEWBOX_PADDING, y_min - VIEWBOX_PADDING, width + VIEWBOX_PADDING * 2, height + VIEWBOX_PADDING * 2]
    end

    def peak_points(library, center: Vector[0, 0], start_angle: 0)
      radius = library.radius(@font, @font_size)
      full_radius = radius + @line_height
      circle_length = library.circle_length @font, @font_size

      points = [center + Vector[full_radius, 0], center + Vector[0, full_radius],
                center - Vector[full_radius, 0], center - Vector[0, full_radius]]

      i = 0
      library.elements.each do |element|
        unless element.is_a? Ring
          i += element.width(@font, @font_size) + @space_width
          next
        end

        child_center_distance = full_radius + element.radius(@font, @font_size) + @line_height * 2

        angle = start_angle - Math::PI / 2 - 2 * Math::PI * (i + 0.5 * element.width(@font, @font_size)) / circle_length
        child_center = center + Vector[child_center_distance * Math.cos(angle),
                                       child_center_distance * Math.sin(angle)]
        points << center + Vector[radius * Math.cos(angle), radius * Math.sin(angle)]
        points += peak_points element, center: child_center, start_angle: -Math::PI / 2 + angle

        i += element.width(@font, @font_size) + @space_width
      end

      points
    end

    def log(*args)
      @log ||= ENV['SPELLRING_LOG']
      puts "VISUALIZER: #{args.join(' ')}" if @log && @log !~ /^(false|0|)$/i
    end
  end
end
