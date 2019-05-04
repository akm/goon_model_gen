require "goon_model_gen"

require "goon_model_gen/source/contextual"

module GoonModelGen
  module Source
    class Field
      include Contextual

      attr_reader :name, :type
      attr_reader :required
      attr_reader :unique
      attr_reader :tags # Hash<string,Array[string]> ex. for datastore, validate, json, etc...
      attr_accessor :type_obj

      # @param name [String]
      # @param attrs [Hash<string,Object>]
      def initialize(name, attrs)
        @name = name
        @type = attrs['type']
        @required = attrs['required']
        @unique = attrs['unique']
        @tags = attrs['tags']
      end
    end
  end
end
