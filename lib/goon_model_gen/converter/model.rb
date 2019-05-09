require "goon_model_gen"

module GoonModelGen
  module Converter
    class Model
      attr_reader :name, :package_path
      def initialize(name, package_path)
        @name, @package_path = name, package_path
      end
    end
  end
end
