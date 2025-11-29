# frozen_string_literal: true

require_relative 'spellrings_rb/parser'
require_relative 'spellrings_rb/visualizer'

module Spellrings
  class << self
    def build_file(source_filename, output_filename = nil)
      dir = File.dirname source_filename
      name = File.basename source_filename, '.rb'
      output_filename ||= File.join dir, "#{name}.svg"

      library = Spellrings::Parser.parse_file source_filename
      Visualizer.new(library, color: ENV['SPELLRING_COLOR']).cast output_filename
      output_filename
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
