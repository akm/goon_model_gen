require "goon_model_gen"

require "goon_model_gen/config"
require "goon_model_gen/builder/abstract_builder"

require "goon_model_gen/source/struct"
require "goon_model_gen/source/enum"
require "goon_model_gen/source/named_slice"

require "goon_model_gen/golang/package"
require "goon_model_gen/golang/packages"
require "goon_model_gen/golang/datastore_package_factory"

require "active_support/core_ext/string"

module GoonModelGen
  module Builder
    class ModelBuilder < AbstractBuilder

      # @param config [GoonModelGen::Config]
      def initialize(config)
        super(config, config.model_package_path)
      end

      # @param package_path [String]
      # @param types [Array<Source::Type>]
      # @return [Golang::Package, Array<Proc>]
      def build_package(package_path, types)
        procs = []
        pkg = Golang::Package.new(package_path).tap do |pkg|
          types.each do |t|
            case t
            when Source::Struct then
              go_type = build_struct(t, pkg)
              kind = (t.id_name && t.id_type) ? 'goon' : 'struct'
              procs << Proc.new{ build_sentences('model', kind, t, go_type) }
            when Source::Enum then
              go_type = pkg.new_enum(t.name, t.base_type).tap do |enum|
                t.elements.each{|i| enum.add(i.value, i.name) }
              end
              procs << Proc.new{ build_sentences('model', 'enum', t, go_type) }
            when Source::NamedSlice then
              go_type = pkg.new_named_slice(t.name, t.base_type_name)
              procs << Proc.new{ build_sentences('model', 'slice', t, go_type) }
            else
              raise "Unsupported type #{t.class.name} #{t.inspect}"
            end
          end
        end
        return pkg, procs
      end

      # @param pkgs [Golang::Packages]
      def resolve_type_names(pkgs)
        pkgs.resolve_type_names(Golang::DatastorePackageFactory.new(config.package_alias_map).packages)
      end

      # @param t [Source::Struct]
      # @param pkg [Golang::Package]
      # @return [Golang::Struct]
      def build_struct(t, pkg)
        pkg.new_struct(t.name).tap do |s|
          s.ref_name = t.ref_name
          if t.id_name && t.id_type
            tags = {
              'goon' => ['id'],
              'datastore' => ['-'],
              'json' => [t.id_name.underscore],
            }
            s.new_field(t.id_name, t.id_type, tags, goon_id: true)
          end
          t.fields.each do |f|
            s.new_field(f.name, f.type_name, f.build_tags).tap do |field|
              field.unique = f.unique
            end
          end
        end
      end

    end
  end
end
