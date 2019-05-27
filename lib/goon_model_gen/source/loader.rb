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

        (raw['types'] || {}).each do |name, t|
          source_type =
            if t['fields'].is_a?(Hash)
              load_struct(f, name, t).tap do |s|
                if g = t['goon']
                  s.id_name = g['id_name']
                  s.id_type = g['id_type']
                end
              end
            elsif t['enum_map'].is_a?(Hash) && t['base']
              f.new_enum(name, t['base'], t['enum_map'].map{|k,v| {k => v}})
            elsif t['enum'].is_a?(Array) && t['base']
              f.new_enum(name, t['base'], t['enum'])
            elsif t['slice_of'].is_a?(String)
              f.new_named_slice(name, t['slice_of'])
            else
              raise "Unsupported type definition named '#{name}': #{t.inspect}"
            end

          source_type.generators =
            case t['generates']
            when false then Hash.new({}) # Return empty Hash not to generate any file
            when nil, true then Hash.new(nil) # Fulfill by default methods
            when Hash then
              t['generates'].each_with_object({}) do |(k,v), d|
                d[k] =
                  case v
                  when false then {}
                  when nil, true then nil
                  when Array then v.each_with_object({}){|i,d| d[i] = true}
                  when Hash then v
                  else raise "Invalid generates value in #{k.inspect}: #{v.inspect}"
                  end
              end
            when Array then t['generates'].each_with_object({}){|i,d| d[i] = true}
            else raise "Invalid generates: #{t['generates'].inspect}"
            end
        end
      end

      # @param f [File]
      # @param name [String]
      # @param t [Hash<String,Hash>|Hash<String,String>] definition of struct from YAML
      # @return [Struct]
      def load_struct(f, name, t)
        f.new_struct(name).tap do |s|
          s.ref_name = t['ref_name']
          t['fields'].each do |field_name, attrs|
            attrs = {'type' => attrs} unless attrs.is_a?(Hash)
            s.new_field(field_name, attrs)
          end
        end
      end

    end
  end
end
