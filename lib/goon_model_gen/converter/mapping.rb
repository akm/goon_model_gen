require "goon_model_gen"

module GoonModelGen
  module Converter
    class Mapping
      attr_reader :name, :args, :func, :requires_context, :returns_error
      attr_accessor :package_base_path, :package_name
      attr_accessor :allow_zero # for int or uint only
      def initialize(name, args, func, requires_context, returns_error)
        @name, @args, @func, @requires_context, @returns_error = name, args, func, requires_context, returns_error
      end

      def resolve_package_path(config)
        if func.present? && func.include?('.')
          self.package_base_path = requires_context ? config.store_package_path : config.model_package_path
          self.package_name = func.split('.', 2).first
        end
      end
    end
  end
end
