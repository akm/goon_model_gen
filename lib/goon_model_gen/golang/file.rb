require "goon_model_gen"

require "goon_model_gen/golang/sentence"

module GoonModelGen
  module Golang
    class File
      attr_reader :package, :name
      attr_reader :sentences

      # @param package [Package]
      # @param name [string]
      def initialize(package, name)
        @package = package
        @name = name
        @sentences = []
      end

      def new_sentence(template_path, type)
        Sentence.new(template_path, type).tap do |s|
          sentences.push(s)
        end
      end
    end
  end
end
