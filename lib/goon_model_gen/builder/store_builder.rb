require "goon_model_gen"

require "goon_model_gen/config"
require "goon_model_gen/builder/abstract_builder"

require "goon_model_gen/source/struct"

require "goon_model_gen/golang/package"
require "goon_model_gen/golang/datastore_package_factory"


module GoonModelGen
  module Builder
    class StoreBuilder < AbstractBuilder
      attr_reader :model_packages

      # @param config [GoonModelGen::Config]
      # @param model_packages [Golang::Packages]
      def initialize(config, model_packages)
        super(config, config.store_package_path)
        @package_suffix = "_store"
        @model_packages = model_packages
      end

      # @param package_path [String]
      # @param types [Array<Source::Type>]
      # @return [Golang::Package, Array<Proc>]
      def build_package(package_path, types)
        procs = []
        pkg = Golang::Package.new(package_path).tap do |pkg|
          types.select{|t| t.is_a?(Source::Struct) && t.id_name && t.id_type }.each do |t|
            store_type = pkg.new_struct(t.name + "Store")
            procs << Proc.new{ build_sentences('store', 'goon', t, store_type) }
            store_type.memo[:model] =
              begin
                pkg_name = Golang::Package.regularize_name(t.file.basename)
                pkg = model_packages.detect_by(pkg_name)
                raise "Package not found for #{t.file.basename}" unless pkg
                pkg.lookup(t.name)
              end
          end
        end
        return pkg, procs
      end

      # @param pkgs [Golang::Packages]
      def resolve_type_names(pkgs)
        pkgs.resolve_type_names(Golang::DatastorePackageFactory.new(config.package_alias_map).packages.dup.add(model_packages))
      end

    end
  end
end
