require "goon_model_gen"

require "goon_model_gen/golang/sentence"

module GoonModelGen
  module Golang
    class File
      attr_reader :name
      attr_reader :sentences
      attr_accessor :package
      attr_accessor :custom_suffix # false/true

      # @param name [string]
      def initialize(name)
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
