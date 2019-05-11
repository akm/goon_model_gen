require "goon_model_gen"

require "goon_model_gen/golang/type"

module GoonModelGen
  module Golang
    class Enum < Type
      attr_reader :base_type_name, :map
      attr_reader :base_type

      # @param name [String]
      # @param base_type_name [String]
      # @param map [Hash<Object,String>]
      def initialize(name, base_type_name, map)
        super(name)
        @base_type_name = base_type_name
        @map = map
      end

      # @param pkgs [Packages]
      def resolve(pkgs)
        @base_type = pkgs.type_for(base_type_name) || raise("#{base_type_name.inspect} not found for #{name}")
      end
    end
  end
end
