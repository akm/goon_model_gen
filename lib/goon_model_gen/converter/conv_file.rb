require "goon_model_gen"

module GoonModelGen
  module Converter
    class ConvFile
      attr_reader :path
      attr_reader :goa_gen_package_path # String
      attr_accessor :payload_convs, :result_convs # Hash<String, Definition>

      def initialize(config, goa_gen_package_path)
        @path = path
        @goa_gen_package_path = goa_gen_package_path
      end

    end
  end
end
