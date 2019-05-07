require "goon_model_gen"

require "goon_model_gen/source/contextual"

module GoonModelGen
  module Source
    class Field
      include Contextual

      attr_reader :name, :type_name
      attr_reader :required
      attr_reader :unique
      attr_reader :tags # Hash<string,Array[string]> ex. for datastore, validate, json, etc...

      # @param name [String]
      # @param attrs [Hash<string,Object>]
      def initialize(name, attrs)
        @name = name
        @type_name = attrs['type']
        @required = attrs['required']
        @unique = attrs['unique']
        @tags = attrs['tags']
      end

      def build_tags
        r = {}
        (tags || {}).each do |key, val|
          r[key] = val.is_a?(Array) ? val.dup : [val]
        end
        r['json'] ||= [name.underscore]
        if required
          r['validate'] = ['required'] + (r['validate'] || [])
        else
          r['json'] << 'omitempty'
        end
        return r
      end
    end
  end
end
