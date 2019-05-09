require "goon_model_gen"

module GoonModelGen
  module Converter
    class AbstractConv
      attr_accessor :file # ConvFile
      attr_reader :name
      attr_reader :model
      attr_reader :mappings

      def initialize(name, model, mappings)
        @name = name
        @model = model
        @mappings = mappings
      end
    end
  end
end
