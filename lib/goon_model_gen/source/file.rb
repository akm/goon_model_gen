require "goon_model_gen"

require "goon_model_gen/source/contextual"
require "goon_model_gen/source/struct"
require "goon_model_gen/source/enum"

module GoonModelGen
  module Source
    class File
      include Contextual

      attr_reader :path
      attr_reader :types

      # @param path [string]
      def initialize(path)
        @path = path
        @types = []
      end

      # @param name [string]
      # @return [Struct]
      def new_struct(name)
        Struct.new(name).tap do |s|
          s.context = self.context
          types.push(s)
        end
      end

      # @param name [string]
      # @param base_type [String]
      # @param map [Hash<Object,Hash>] elements of enum from YAML
      # @return [Enum]
      def new_enum(name, base_type, map)
        Enum.new(name, base_type, map).tap do |t|
          t.context = self.context
          types.push(t)
        end
      end

    end
  end
end
