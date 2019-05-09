require "goon_model_gen"

module GoonModelGen
  module Converter
    class Mapping
      attr_reader :name, :args, :func, :requires_context, :returns_error
      def initialize(name, args, func, requires_context, returns_error)
        @name, @args, @func, @requires_context, @returns_error = name, args, func, requires_context, returns_error
      end
    end
  end
end
