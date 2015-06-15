require 'parser'

module Reek
  module AST
    # Base class for AST nodes extended with utility methods. Contains some
    # methods to ease the transition from Sexp to AST::Node.
    #
    # @api private
    class ASTNode < ::Parser::AST::Node
      def initialize(type, children = [], options = {})
        @comments = options.fetch(:comments, [])
        super
      end

      def full_comment
        @comments.map(&:text).join("\n")
      end

      def leading_comment
        line = location.line
        comment_lines = @comments.select do |comment|
          comment.location.line < line
        end
        comment_lines.map(&:text).join("\n")
      end

      # @deprecated
      def [](index)
        elements[index]
      end

      def line
        loc.line
      end

      # @deprecated
      def first
        type
      end

      private

      def elements
        [type, *children]
      end
    end
  end
end
