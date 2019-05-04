require "goon_model_gen"

module GoonModelGen
  module Source
    class Context
      attr_reader :files

      def initialize
        @files = []
      end

      # @return [nil|Type]
      def lookup(type_name)
      end
    end
  end
end
