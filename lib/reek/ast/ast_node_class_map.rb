require_relative 'ast_node'
require_relative 'sexp_node'
require_relative 'sexp_extensions'

module Reek
  module AST
    # Maps AST node types to sublasses of ASTNode extended with the relevant
    # utility modules.
    #
    # @api private
    class ASTNodeClassMap
      def initialize
        @klass_map = {}
      end

      def klass_for(type)
        @klass_map[type] ||= Class.new(ASTNode).tap do |klass|
          extension = extension_map[type]
          klass.send :include, extension if extension
          klass.send :include, SexpNode
        end
      end

      def extension_map
        @extension_map ||=
          begin
            assoc = SexpExtensions.constants.map do |const|
              [
                const.to_s.sub(/Node$/, '').downcase.to_sym,
                SexpExtensions.const_get(const)
              ]
            end
            Hash[assoc]
          end
      end
    end
  end
end
