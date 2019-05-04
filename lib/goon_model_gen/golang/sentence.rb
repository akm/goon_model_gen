require "goon_model_gen"

module GoonModelGen
  module Golang
    class Sentence
      attr_reader :template_path
      attr_reader :type

      # @param template_path [string]
      # @param type [Type]
      def initialize(template_path, type)
        @template_path = template_path
        @type = type
      end
    end
  end
end
