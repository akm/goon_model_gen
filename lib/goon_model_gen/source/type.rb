require "goon_model_gen"

require "goon_model_gen/source/contextual"

module GoonModelGen
  module Source
    class Type
      include Contextual

      attr_reader :name
      attr_accessor :file
      attr_accessor :generators # key: method_name, value: true|false|string(file_suffix)

      # @param name [string]
      def initialize(name)
        @name = name
      end

    end
  end
end
