require "goon_model_gen"

require "goon_model_gen/config"
require "goon_model_gen/builder/abstract_builder"

require "goon_model_gen/golang/packages"
require "goon_model_gen/golang/datastore_package_factory"


module GoonModelGen
  module Builder
    class ValidationBuilder < AbstractBuilder

      # @param config [GoonModelGen::Config]
      def initialize(config)
        super(config, config.validation_package_path)
      end

      # @return [Golang::Packages]
      def build(*)
        Golang::Packages.new.tap do |r|
          r.new_package(base_package_path).tap do |pkg|
            t = pkg.new_struct('ValidationError')
            pkg.new_file('validation_error.go').tap do |f|
              build_sentences_with('validation/error', t, nil)
            end
          end
        end
      end

      # @param pkgs [Golang::Packages]
      def resolve_type_names(pkgs)
        pkgs.resolve_type_names(Golang::DatastorePackageFactory.new(config.package_alias_map).packages)
      end

    end
  end
end
