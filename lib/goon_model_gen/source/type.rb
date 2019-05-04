require "goon_model_gen"

require "goon_model_gen/source/contextual"

module GoonModelGen
  module Source
    class Type
      include Contextual

      attr_reader :name

      # @param name [string]
      def initialize(name)
        @name = name
      end

    end
  end
end
