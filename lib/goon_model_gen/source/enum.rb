require "goon_model_gen"

require "goon_model_gen/source/type"

module GoonModelGen
  module Source
    class Enum < Type
      attr_reader :base_type, :map

      # @param name [String]
      # @param base_type [String]
      # @param map [Hash<Object,String>]
      def initialize(name, base_type, map)
        super(name)
        @base_type = base_type
        @map = map
      end
    end
  end
end
