require "goon_model_gen"

require "goon_model_gen/golang/type"
require "goon_model_gen/golang/field"

module GoonModelGen
  module Golang
    class Struct < Type
      attr_reader :id_name, :id_type
      attr_accessor :display_method

      def fields
        @fields ||= []
      end

      # @param name [string]
      # @param t [Type]
      # @param tags [Hash<String,Array<String>>]
      def new_field(name, t, tags, options = {})
        Field.new(name, t, tags, options).tap do |f|
          self.fields.push(f)
        end
      end

      def id_field
        fields.detect(&:goon_id)
      end

    end
  end
end
