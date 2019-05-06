require "goon_model_gen"

require "goon_model_gen/golang/type"

module GoonModelGen
  module Golang
    class NamedSlice < Type
      attr_reader :base_type_name
      attr_reader :base_type

      # @param name [String]
      # @param base_type_name [String]
      def initialize(name, base_type_name)
        super(name)
        @base_type_name = base_type_name
      end

      # @param pkgs [Packages]
      def resolve(pkgs)
        @base_type = pkgs.type_for(base_type_name) || raise("#{base_type_name.inspect} not found")
      end
    end
  end
end
