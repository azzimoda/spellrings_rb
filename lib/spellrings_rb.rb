# frozen_string_literal: true

require_relative 'spellrings_rb/fonts'
require_relative 'spellrings_rb/parser'
require_relative 'spellrings_rb/visualizer'

module Spellrings
  class << self
    def build_file(source_file, output_file: nil, font_family: DEFAULT_FONT)
      dir = File.dirname source_file
      name = File.basename source_file, '.rb'
      output_file ||= File.join dir, "#{name}.svg"

      library = Spellrings::Parser.parse_file source_file
      Visualizer.new(library).generate_svg(font_family: font_family, output_file: output_file)
      output_file
    end

    def node_types(source)
      ast_node_types Prism::Translation::Parser34.parse source
    end

    private

    def ast_node_types(ast)
      return Set.new unless ast.is_a? ::Parser::AST::Node

      node_types = Set[ast.type]
      ast.children.each { |child| node_types.merge ast_node_types child }
      node_types
    end
  end
end
