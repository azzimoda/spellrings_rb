# frozen_string_literal: true

require 'ttfunk'

module Spellrings
  # This class is responsible for loading and managing fonts.
  class FontManager
    @paths = {}
    @fonts = {}

    class << self
      def load(font_name)
        font_path = find_font_path font_name
        @fonts[font_path] ||= TTFunk::File.open font_path
      end

      def find_font_path(font_name)
        @paths[font_name.downcase] ||=
          case RbConfig::CONFIG['host_os']
          when /linux/i              then find_font_path_linux font_name
          when /darwin/i             then find_font_path_macos font_name
          when /mswin|mingw|cygwin/i then find_font_path_windows font_name
          else raise "Unsupported platform: #{RbConfig::CONFIG['host_os']}"
          end
      end

      def font_height(font, font_size = 12.0)
        font =
          case font
          when String then load font
          when TTFunk::File then font
          else raise ArgumentError, "Invalid font: #{font.inspect}"
          end
        full_height = font.ascent - font.descent
        font_size * full_height / font.header.units_per_em
      end

      def str_width(string, font, font_size = 12.0)
        font =
          case font
          when String then load font
          when TTFunk::File then font
          else raise ArgumentError, "Invalid font: #{font.inspect}"
          end
        unicode_cmap = font.cmap.tables.find { [0, 3].include? it.platform_id }
        metrics = font.horizontal_metrics
        total_advance = string.chars.inject(0.0) do |sum, char|
          glyph_id = unicode_cmap[char.ord]
          sum + metrics.widths[glyph_id] + metrics.left_side_bearings[glyph_id].to_f
        end
        (font_size.to_f * total_advance / font.header.units_per_em)
      end

      private

      def find_font_path_linux(font_name)
        `fc-match -v "#{font_name}"`.match(/file: "(.+?)"/)&.captures&.first
      end

      def find_font_path_macos(font_name)
        # TODO: Test it on macos. IDK how can I do it :(
        ["/Library/Fonts/#{font_name}.ttf",
         "/Library/Fonts/#{font_name}.otf",
         "/System/Library/Fonts/#{font_name}.ttf",
         "~/Library/Fonts/#{font_name}.ttf"].find { File.exist? it }
      end

      def find_font_path_windows(font_name)
        # TODO: Test it on Windows.
        font_dir = "#{ENV['WINDIR']}\\Fonts\\"
        ["#{font_dir}#{font_name}.ttf",
         "#{font_dir}#{font_name}.otf",
         "#{font_dir}#{font_name.gsub(' ', '')}.ttf"].find { File.exist? it }
      end
    end
  end
end
