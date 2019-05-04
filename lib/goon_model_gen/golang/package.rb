require "goon_model_gen"

require "goon_model_gen/golang/struct"
require "goon_model_gen/golang/enum"
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

      def new_struct(name)
        Struct.new(name).tap do |s|
          types.push(s)
          s.package = self
        end
      end

      # @param name [string]
      # @param base_type [String]
      # @param map [Hash<Object,Hash>] elements of enum from YAML
      # @return [Enum]
      def new_enum(name, base_type, map)
        Enum.new(name, base_type, map).tap do |t|
          types.push(t)
          t.package = self
        end
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

    end
  end
end
