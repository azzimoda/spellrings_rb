# frozen_string_literal: true

require 'ostruct'
require 'victor'
require_relative 'visualizer/rings'

module Spellrings
  class Visualizer
    DEFAULT_COLOR = '#9B111E'
    FONT_HEIGHT = 10.0
    FONT_WIDTH = 3.5
    LINE_HEIGHT = 3 * FONT_HEIGHT
    SIGIL_VIEWBOX_WIDTH = 2.0 * LINE_HEIGHT
    SIGIL_VIEWBOX = "#{-0.5 * SIGIL_VIEWBOX_WIDTH} #{-0.5 * SIGIL_VIEWBOX_WIDTH} #{SIGIL_VIEWBOX_WIDTH} #{SIGIL_VIEWBOX_WIDTH}"

    def initialize(library, color: nil)
      @library = library
      @color = color || DEFAULT_COLOR
    end
    attr_reader :svg

    # Generate SVG file from the library.
    def generate_svg(file_name = nil, size: nil)
      size ||= p compute_size

      @svg = Victor::SVG.new viewBox: "0 0 #{size} #{size}", font_family: 'Z003'
      add_style
      add_defs
      svg.rect width: size, height: size, class: 'debug' if ENV['CMRB_DEBUG']
      draw_ring @library, transform: "translate(#{size / 2},#{size / 2})"
      svg.tap { svg.save file_name if file_name }
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
          font-size: #{FONT_HEIGHT}px;
          text-anchor: middle;
          dominant-baseline: middle;
          fill: var(--color);
        }

        circle,
        polygon,
        path {
          fill: none;
          stroke: var(--color);
        }

        path {
          stroke: yellow;
        }

        .debug {
          fill: none;
          stroke: yellow;
        }
      CSS
    end

    def add_defs
      # TODO: Add more sigils
      svg.defs do
        def_sigil :begin do
          svg.polygon points: star_points(5, 2, 0.4 * SIGIL_VIEWBOX_WIDTH).map { it.join(',') }.join(' ')
        end

        def_sigil :true do # rubocop:disable Lint/BooleanSymbol
          svg.text 'T'
          svg.polygon points: star_points(3, 1, 0.25 * SIGIL_VIEWBOX_WIDTH).join(' '), transform: 'translate(0,1.5)'
        end

        def_sigil :false do # rubocop:disable Lint/BooleanSymbol
          svg.text 'F'
          svg.polygon points: star_points(3, 1, 0.25 * SIGIL_VIEWBOX_WIDTH).join(' '), transform: 'translate(0,1.5)'
        end

        def_sigil :nil do
          svg.text 'N'
          svg.polygon points: star_points(3, 1, 0.25 * SIGIL_VIEWBOX_WIDTH).join(' '), transform: 'translate(0,1.5)'
        end

        def_sigil :unknown do
          svg.circle r: 0.25 * SIGIL_VIEWBOX_WIDTH
        end
      end
    end

    def def_sigil(name, **kwargs, &block)
      @sigils ||= []
      @sigils << name
      kwargs.merge!(id: "sigil_#{name}", viewBox: SIGIL_VIEWBOX, width: SIGIL_VIEWBOX_WIDTH,
                    height: SIGIL_VIEWBOX_WIDTH)
      svg.symbol(**kwargs) { block.call }
    end

    def compute_size
      max_child_size = 2 * ((@library.elements.select { it.is_a? Ring }.map(&:size).max || 0) + LINE_HEIGHT)
      2 * ((@library.size + max_child_size) * FONT_WIDTH + LINE_HEIGHT)
    end

    def log(*args)
      @log ||= ENV['SPELLRING_LOG']
      puts "VISUALIZER: #{args.join(' ')}" if @log && @log !~ /^(false|0|)$/i
    end
  end
end
