require "goon_model_gen"

require "goon_model_gen/source/type"

module GoonModelGen
  module Source
    class NamedSlice < Type
      attr_reader :base_type_name

      # @param name [String]
      # @param base_type [String]
      def initialize(name, base_type_name)
        super(name)
        @base_type_name = base_type_name
      end
    end
  end
end
