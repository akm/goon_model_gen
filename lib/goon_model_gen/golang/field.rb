require "goon_model_gen"

module GoonModelGen
  module Golang
    class Field
      attr_reader :name, :type_name
      attr_reader :tags # Hash<string,Array[string]> ex. for datastore, validate, json, etc...
      attr_reader :goon_id # true/false
      attr_reader :type
      attr_accessor :struct
      attr_accessor :prepare_method

      def initialize(name, type_name, tags, goon_id: false)
        @name, @type_name = name, type_name
        @tags = tags || {}
        @goon_id = goon_id
      end

      # @param pkgs [Packages]
      def resolve(pkgs)
        @type = pkgs.type_for(type_name) || raise("#{type_name.inspect} not found for #{struct.qualified_name}.#{name}")
      end

      def tags_string
        tags.keys.sort.map do |key|
          val = tags[key]
          vals = val.is_a?(Array) ? val.join(',') : val.to_s
          vals.empty? ? nil : "#{key}:\"#{vals}\""
        end.compact.join(' ')
      end

      # @return [string]
      def definition
        "#{ name } #{ type.qualified_name } `#{ tags_string }`"
      end
    end
  end
end
