require "goon_model_gen"

require "goon_model_gen/source/type"

module GoonModelGen
  module Source
    class Enum < Type

      class Element
        attr_reader :value, :name
        def initialize(value, name)
          @value, @name = value, name
        end
      end

      attr_reader :base_type, :elements

      # @param name [String]
      # @param base_type [String]
      # @param element_definitions [Array<Hash<Object,String>>,Hash<Object,String>]
      def initialize(name, base_type, element_definitions)
        unless element_definitions.all?{|i| i.is_a?(Hash) && (i.length == 1) }
          raise "Enum element definitions must be an Array of 1 element Hash but was #{element_definitions.inspect}"
        end
        super(name)
        @base_type = base_type
        @elements = element_definitions.map do |i|
          Element.new(i.keys.first, i.values.first)
        end
      end
    end
  end
end
