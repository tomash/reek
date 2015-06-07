require_relative 'ast/ast_node_class_map'

module Reek
  #
  # Adorns an abstract syntax tree with mix-in modules to make accessing
  # the tree more understandable and less implementation-dependent.
  #
  class TreeDresser
    def initialize(klass_map = AST::ASTNodeClassMap.new)
      @klass_map = klass_map
    end

    # Given this sexp (Parser::AST::Node):
    # (class
    #   (const nil :C) nil
    #   (def :m
    #     (args)
    #     (send nil :puts
    #       (str "nada"))))
    #
    # `dress` would now:
    #
    # 1.) determine the type of this sexp which would be `class`
    # 2.) iterate over the children which would be:
    #   [1] (const nil :C)
    #   [2] nil
    #   [3] (def :m ....
    #
    # Let's just look at what happens with [1]:
    #   - `type` is going to be `const`
    #   - children would be [nil, :C]
    #   - the resulting class from @klass_map.klass_for(type)
    #     would be an anonymous class with Reek::AST::ASTNode as superclass,
    #     so not Parser::AST::Node anymore and it would have included
    #     Reek::AST::SexpExtensions::ConstNode.
    #     The overall ancestors chain just for [1] would look like this:
    #     [ Reek::AST::SexpNode, Reek::AST::SexpExtensions::ConstNode, Reek::AST::ASTNode,
    #       Parser::AST::Node, AST::Node, ...]
    #
    # At the end when we're done, all nodes will have been recursively adorned by
    # our SexpExtensions in a similar fashion.
    # The root node class for instance would have the following, very similar
    # ancestors chain:
    # [ Reek::AST::SexpNode, Reek::AST::SexpExtensions::ClassNode,
    #   Reek::AST::SexpExtensions::ModuleNode, Reek::AST::ASTNode, ... ]
    # which resembles the one from [1]
    # but instead of SexpExtensions::ConstNode we have SexpExtensions::ClassNode
    # and SexpExtensions::ModuleNode mixed in

    # @param sexp [Parser::AST::Node] - the given sexp
    # @param comment_map [Hash] - see the documentation for SourceCode#syntax_tree
    #
    # @return an instance of Reek::AST::SexpNode with type-dependent sexp extensions mixed in.
    def dress(sexp, comment_map)
      return sexp unless sexp.is_a? ::Parser::AST::Node
      type = sexp.type
      children = sexp.children.map { |child| dress(child, comment_map) }
      comments = comment_map[sexp]
      @klass_map.klass_for(type).new(type, children,
                                     location: sexp.loc, comments: comments)
    end
  end
end
