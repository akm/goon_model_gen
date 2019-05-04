require "goon_model_gen"

require "goon_model_gen/source/context"
require "goon_model_gen/golang/package"

require "active_support/core_ext/string"

module GoonModelGen
  class ModelBuilder
    attr_reader :base_package_path

    def initialize(base_package_path)
      @base_package_path = base_package_path
    end


    # @param context [Source::Context]
    # @return [Array<Golang::Package>]
    def build(context)
      context.files.map do |f|
        package_path = File.join(base_package_path, f.basename)
        build_package(package_path, f.types)
      end
    end

    # @param package_path [String]
    # @param types [Array<Source::Type>]
    # @return [Golang::Package]
    def build_package(package_path, types)
      Golang::Package.new(package_path).tap do |pkg|
        types.each do |t|
          case t
          when Source::Struct then
            go_type = build_struct(t, pkg)
            build_methods("model/struct", t, go_type)
          when Source::Enum then
            go_type = pkg.new_enum(t.name, t.base_type, t.map)
            build_methods("model/enum", t, go_type)
          else
            raise "Unsupported type #{t.class.name} #{t.inspect}"
          end
        end
      end
    end

    # @param t [Source::Struct]
    # @param pkg [Golang::Package]
    # @return [Golang::Struct]
    def build_struct(t, pkg)
      pkg.new_struct(t.name).tap do |s|
        if t.id_name && t.id_type
          tags = {
            'goon' => ['id'],
            'datastore' => ['-'],
            'json' => [t.id_name.underscore],
          }
          s.new_field(t.id_name, t.id_type, tags, goon_id: true)
        end
        t.fields.each do |f|
          s.new_field(f.name, f.type, f.tags)
        end
      end
    end


    # @param template_base [string]
    # @param t [Source::Struct]
    # @param go_type [Golang::Type]
    def build_methods(template_base, t, go_type)
      m2t = method_to_template_for(template_base)
      t.methods ||= default_methods_for(template_base)
      t.methods.each do |name, suffix|
        next if !suffix
        template = m2t[name]
        parts = [t.name.underscore]
        parts << suffix if suffix.is_a?(String)
        filename = parts.join('_')
        file = go_type.package.find_or_new_file(filename)
        file.new_sentence(File.join(template_base, template), go_type)
      end
    end

    def default_methods_for(template_base)
      method_to_template_for(template_base).keys.
        each_with_object({}){|name, d| d[name] = true }
    end

    def method_to_template_map
      @method_to_template_map ||= {}
    end

    def method_to_template_for(template_base)
      method_to_template_map[template_base] ||=
        begin
          templates_for(template_base).each_with_object({}) do |filename, d|
            m = filename.sub(/\A\d+\_/, '').sub(/\.go\.erb\z/, '')
            d[m] = filename
          end
        end
    end

    def templates_for(template_base)
      base_dir = File.join(File.expand_path('../templates', __FILE__), template_base)
      Dir.chdir(base_dir) do
        Dir.glob('*.go.erb')
      end
    end

  end
end
