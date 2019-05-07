require "goon_model_gen"

module GoonModelGen
  module Golang
    class Type
      attr_reader :name
      attr_accessor :package

      # @param name [string]
      def initialize(name)
        @name = name
      end

      # @param pkgs [Packages]
      def resolve(pkgs)
        raise NotImplementedError, "#{self.type.name} doesn't implement resolve method"
      end

      # @return [string]
      def qualified_name
        if package && package.name
          "#{package.name}.#{name}"
        else
          name
        end
      end

      def memo
        @memo ||= {}
      end

    end
  end
end
