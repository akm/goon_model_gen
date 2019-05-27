require "goon_model_gen"

require "goon_model_gen/source/contextual"
require "goon_model_gen/source/struct"
require "goon_model_gen/source/enum"
require "goon_model_gen/source/named_slice"

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

      def basename
        ::File.basename(path, '.*')
      end

      # @param name [string]
      # @return [Struct]
      def new_struct(name)
        Struct.new(name).tap do |s|
          s.context = self.context
          s.file = self
          types.push(s)
        end
      end

      # @param name [string]
      # @param base_type [String]
      # @param elements [Hash<Object,Hash>] elements of enum from YAML
      # @return [Enum]
      def new_enum(name, base_type, elements)
        Enum.new(name, base_type, elements).tap do |t|
          t.context = self.context
          types.push(t)
        end
      end

      # @param name [string]
      # @param base_type_name [string]
      # @return [Slice]
      def new_named_slice(name, base_type_name)
        NamedSlice.new(name, base_type_name).tap do |s|
          s.context = self.context
          types.push(s)
        end
      end

    end
  end
end
