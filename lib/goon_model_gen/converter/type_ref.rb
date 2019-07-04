require "goon_model_gen"

module GoonModelGen
  module Converter
    class TypeRef
      attr_reader :name, :package_path
      attr_accessor :package_base_path
      attr_accessor :slice_with_ptr
      def initialize(name, package_path)
        @name, @package_path = name, package_path
      end

      def ordinary_name
        name.include?('.') ? name.split('.').last : name
      end

    end
  end
end
