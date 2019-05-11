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

      # @param pkg2alias [Hash<String,String>]
      # @return [string]
      def qualified_name(pkg2alias = nil)
        if package && package.name
          pkg_name = (pkg2alias && package.path ? pkg2alias[package.path] : nil) || package.name
          "#{pkg_name}.#{name}"
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
