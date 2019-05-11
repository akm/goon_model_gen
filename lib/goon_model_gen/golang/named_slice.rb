require "goon_model_gen"

require "goon_model_gen/golang/type"

module GoonModelGen
  module Golang
    class NamedSlice < Type
      attr_reader :base_type_name
      attr_reader :base_type_package_path
      attr_reader :base_type

      # @param name [String]
      # @param base_type_name [String]
      # @param base_type_package_path [String]
      def initialize(name, base_type_name, base_type_package_path = nil)
        super(name)
        @base_type_name = base_type_name
        @base_type_package_path = base_type_package_path
      end

      # @param pkgs [Packages]
      def resolve(pkgs)
        @base_type =
          base_type_package_path.present? ?
            pkgs.type_for(base_type_name, base_type_package_path) :
            pkgs.type_for(base_type_name) || raise("#{base_type_name.inspect} not found")
      end

      def ptr_slice?
        base_type.is_a?(GoonModelGen::Golang::Modifier) && (base_type.prefix == '*')
      end
    end
  end
end
