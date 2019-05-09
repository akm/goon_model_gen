require "goon_model_gen"

require "goon_model_gen/golang/struct"
require "goon_model_gen/golang/enum"
require "goon_model_gen/golang/named_slice"
require "goon_model_gen/golang/file"

module GoonModelGen
  module Golang
    class Package
      attr_reader :path
      attr_reader :types
      attr_reader :files

      # @param path [String]
      def initialize(path)
        @path = path
        @types = []
        @files = []
      end

      def basename
        @basename ||= path ? ::File.basename(path, '.*') : nil
      end

      def name
        @name ||= basename ? basename.gsub(/[\-\_]/, '').downcase : nil
      end

      def add(type)
        types.push(type)
        type.package = self
      end

      def new_struct(name)
        Struct.new(name).tap{|s| add(s) }
      end

      # @param name [string]
      # @param base_type [String]
      # @param map [Hash<Object,Hash>] elements of enum from YAML
      # @return [Enum]
      def new_enum(name, base_type, map)
        Enum.new(name, base_type, map).tap{|s| add(s) }
      end

      # @param name [string]
      # @param base_type_package_path [String]
      # @param base_type_name [String]
      # @return [Slice]
      def new_named_slice(name, base_type_name, base_type_package_path = nil)
        NamedSlice.new(name, base_type_name, base_type_package_path).tap{|s| add(s) }
      end

      # @param name [string]
      # @return [File]
      def find_or_new_file(name)
        files.detect{|f| f.name == name} || new_file(name)
      end

      # @param name [string]
      # @return [File]
      def new_file(name)
        File.new(self, name).tap do |f|
          files.push(f)
        end
      end

      # @return [Hash<String,Type>]
      def name_to_type_map
        @name_to_type_map ||= types.each_with_object({}) do |t,d|
          d[t.name] = t
        end
      end

      # @param name [string]
      # @param [Type]
      def lookup(name)
        name_to_type_map[name]
      end

    end
  end
end
