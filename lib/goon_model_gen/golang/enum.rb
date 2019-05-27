require "goon_model_gen"

require "goon_model_gen/golang/type"

module GoonModelGen
  module Golang
    class Enum < Type
      class Element
        attr_reader :value, :name
        def initialize(value, name)
          @value, @name = value, name
        end
      end

      attr_reader :base_type_name, :elements
      attr_reader :base_type

      # @param name [String]
      # @param base_type_name [String]
      def initialize(name, base_type_name)
        super(name)
        @base_type_name = base_type_name
        @elements = []
      end

      # @param value [Object]
      # @param name [String]
      def add(value, name)
        elements << Element.new(value, name)
      end

      # @yieldparam value [Object]
      # @yieldparam name [String]
      def each_value_and_name
        elements.each do |i|
          yield(i.value, i.name)
        end
      end

      # @param pkgs [Packages]
      def resolve(pkgs)
        @base_type = pkgs.type_for(base_type_name) || raise("#{base_type_name.inspect} not found for #{name}")
      end
    end
  end
end
