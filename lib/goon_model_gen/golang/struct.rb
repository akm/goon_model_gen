require "goon_model_gen"

require "goon_model_gen/golang/type"
require "goon_model_gen/golang/field"

module GoonModelGen
  module Golang
    class Struct < Type
      attr_accessor :ref_name

      def fields
        @fields ||= []
      end

      # @param name [String]
      # @param t [String]
      # @param tags [Hash<String,Array<String>>]
      def new_field(name, t, tags, options = {})
        Field.new(name, t, tags, options).tap do |f|
          f.struct = self
          fields.push(f)
        end
      end

      def id_field
        fields.detect(&:goon_id)
      end

      # @param pkgs [Packages]
      def resolve(pkgs)
        fields.each do |f|
          f.resolve(pkgs)
        end
      end

    end
  end
end
