require "goon_model_gen"

require "erb"
require "yaml"

require "goon_model_gen/source/context"
require "goon_model_gen/source/file"

module GoonModelGen
  module Source
    class Loader
      # @param filepaths [Array<String>]
      # @return [Context]
      def process(filepaths)
        context = Context.new
        filepaths.each do |filepath|
          load_source_yaml(context, filepath)
        end
        return context
      end

      # @param context [Context]
      # @param path [string]
      def load_source_yaml(context, path)
        erb = ERB.new(::File.read(path), nil, "-")
        erb.filename = path
        txt = erb.result
        raw = YAML.load(txt)

        f = File.new(path).tap do |f|
          f.context = context
          context.files.push(f)
        end

        (raw['types'] || []).each do |name, t|
          if t['fields'].is_a?(Hash)
            load_struct(f, name, t)
          elsif t['enum_map'].is_a?(Hash) && t['base']
            load_enum(f, name, t['base'], t['enum_map'])
          else

          end
        end
      end

      # @param f [File]
      # @param name [String]
      # @param t [Hash<String,Hash>|Hash<String,String>] definition of struct from YAML
      def load_struct(f, name, t)
        f.new_struct(name).tap do |s|
          t['fields'].each do |field_name, attrs|
            s.new_field(field_name, attrs)
          end
        end
      end

      # @param f [File]
      # @param name [String]
      # @param base_type [String]
      # @param map [Hash<Object,Hash>] elements of enum from YAML
      def load_enum(f, name, base_type, map)
        f.new_enum(name, base_type, map)
      end

    end
  end
end
