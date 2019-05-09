require "goon_model_gen"

module GoonModelGen
  module Converter
    class ConvFile
      attr_reader :path
      attr_reader :gen_package_path # String
      attr_accessor :payload_convs, :result_convs # Hash<String, Definition>

      def initialize(config, gen_package_path)
        @path = path
        @gen_package_path = gen_package_path
      end

    end
  end
end
