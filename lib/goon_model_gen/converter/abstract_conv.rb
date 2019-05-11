require "goon_model_gen"

module GoonModelGen
  module Converter
    class AbstractConv
      attr_accessor :file # ConvFile
      attr_reader :name
      attr_reader :model    # TypeRef
      attr_reader :gen_type # TypeRef Payload/Result
      attr_reader :mappings

      def initialize(name, model, gen_type, mappings)
        @name = name
        @model = model
        @gen_type = gen_type
        @mappings = mappings
      end
    end
  end
end
