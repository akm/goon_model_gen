require "goon_model_gen"

require "erb"
require "yaml"

require "goon_model_gen/converter/conv_file"
require "goon_model_gen/converter/payload_conv"
require "goon_model_gen/converter/result_conv"
require "goon_model_gen/converter/model"
require "goon_model_gen/converter/mapping"

module GoonModelGen
  module Converter
    class Loader
      attr_reader :config

      def initialize(config)
        @config = config
      end

      def process(path)
        erb = ERB.new(::File.read(path), nil, "-")
        erb.filename = path
        txt = erb.result
        raw = YAML.load(txt)

        goa_gen_dir = raw['goa_gen_dir'] || ::File.basename(path, '.*')
        goa_gen_package_path = raw['goa_gen_package_path'] || File.join(config.goa_goa_gen_package_path, goa_gen_dir)
        ConvFile.new(path, goa_gen_package_path).tap do |f|
          f.payload_convs = load_conv_defs(f, PayloadConv, raw['payloads'])
          f.result_convs = load_conv_defs(f, ResultConv, raw['results'])
        end
      end

      def load_conv_defs(f, conv_class, hash)
        hash.each do |name, definition|
          model = load_model_for_conv(definition['model'])
          gen_type = TypeRef.new(name, File.join(config.goa_gen_package_path, f.basename))
          mappings = load_mappings(definition['mappings'], conv_class)
          conv_class.new(name, model, mappings).tap do |conv|
            conv.file = f
          end
        end
      end

      def load_model_for_conv(obj)
        case obj
        when Hash
          TypeRef.new(obj['name'], obj['package_path'])
        when String
          parts = *obj.split('.', 2)
          pkg = (parts.length > 1) ? ::File.join(config.model_package_path, parts.first) : config.model_package_path
          TypeRef.new(parts.last, pkg)
        else
          raise "Unsupported model type for converter definition: #{obj.inspect}"
        end
      end

      def load_mappings(hash, conv_class)
        hash.map do |(name, props)|
          props ||= {}
          props = {'arg' => props} if props.is_a?(String)
          args = props['args'] || [props['arg'] || name]
          func, requires_context, returns_error = *conv_class.load_func(props)
          if func.nil? && (args.length > 1)
            raise "Invalid argument length: #{args.length} for #{name}: #{args.inspect}"
          end
          Mapping.new(name, args, func, requires_context, returns_error)
        end
      end

    end
  end
end
