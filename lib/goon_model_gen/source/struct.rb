require "goon_model_gen"

require "goon_model_gen/source/type"
require "goon_model_gen/source/field"

module GoonModelGen
  module Source
    class Struct < Type
      attr_accessor :id_name, :id_type
      attr_accessor :ref_name

      def fields
        @fields ||= []
      end

      # @param name [string]
      # @param attrs [Hash<String,Object>]
      def new_field(name, attrs)
        Field.new(name, attrs).tap do |f|
          f.context = self.context
          self.fields.push(f)
        end
      end
    end
  end
end
