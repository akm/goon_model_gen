require "goon_model_gen"

module GoonModelGen
  module Converter
    class ConvFile
      attr_reader :path
      attr_reader :converter_package_path # String
      attr_accessor :payload_convs, :result_convs # [XxxxConv]

      def initialize(path, converter_package_path)
        @path = path
        @converter_package_path = converter_package_path
      end

      def basename
        ::File.basename(path, '.*')
      end
    end
  end
end
