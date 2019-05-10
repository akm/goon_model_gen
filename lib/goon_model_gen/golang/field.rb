require "goon_model_gen"

require "goon_model_gen/golang/type"
require "goon_model_gen/golang/struct"
require "goon_model_gen/golang/named_slice"
require "goon_model_gen/golang/builtin"
require "goon_model_gen/golang/modifier"

module GoonModelGen
  module Golang
    class Field
      attr_reader :name, :type_name
      attr_reader :tags # Hash<string,Array[string]> ex. for datastore, validate, json, etc...
      attr_reader :goon_id # true/false
      attr_reader :type
      attr_accessor :struct
      attr_accessor :prepare_method
      attr_accessor :unique

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

      # @param pkg [Package]
      # @return [string]
      def definition_in(pkg)
        type_exp =
          (type.package.path == pkg.path) ? type.name : type.qualified_name
        "#{ name } #{ type_exp } `#{ tags_string }`"
      end

      def ptr?
        case type
        when Modifier then (type.prefix == "*")
        when Type then false
        else raise "Unsupported type class #{type.inspect}"
        end
      end

      def slice?
        case type
        when Modifier then (type.prefix == "[]")
        when NamedSlice then true
        when Type then false
        else raise "Unsupported type class #{type.inspect}"
        end
      end

      def struct?
        case type
        when Modifier then false
        when Struct then true
        when Type then false
        else raise "Unsupported type class #{type.inspect}"
        end
      end

      def value_ptr?
        case type
        when Modifier then
          return false unless type.prefix == '*'
          case type.target
          when Builtin then type.target.name != 'interface'
          else false
          end
        when Type then false
        else raise "Unsupported type class #{type.inspect}"
        end
      end

      def short_desc
        "#{name}: #{type.qualified_name}"
      end
    end
  end
end
