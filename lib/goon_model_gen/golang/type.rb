require "goon_model_gen"

module GoonModelGen
  module Golang
    class Type
      attr_reader :name
      attr_accessor :package

      # @param name [string]
      def initialize(name)
        @name = name
      end
    end
  end
end
