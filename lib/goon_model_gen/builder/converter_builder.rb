require "goon_model_gen"

require "goon_model_gen/config"
require "goon_model_gen/builder/abstract_builder"

require "goon_model_gen/source/struct"

require "goon_model_gen/golang/package"
require "goon_model_gen/golang/datastore_package_factory"


module GoonModelGen
  module Builder
    class ConverterBuilder < AbstractBuilder
      attr_reader :loader
      attr_reader :packages

      # @param config [GoonModelGen::Config]
      # @param loader [Converter::Loader]
      # @param packages [Golang::Packages]
      def initialize(config, loader, packages)
        super(config, config.converter_package_path)
        @package_suffix = "_conv"
        @loader = loader
        @packages = packages
      end

      # @param conv_file_path [Array<String>]
      def build(conv_file_paths)
        Golang::Packages.new.tap do |pkgs|
          build_sentences = []
          conv_file_paths.each do |conv_file_path|
            conf_file = loader.process(conv_file_path)
            procs = build_package(pkgs, conf_file)
            build_sentences.concat(procs)
          end
          resolve_type_names(pkgs)
          build_sentences.each(&:call)
        end
      end

      # @param pkgs [Golang::Packages]
      # @param conv_file [Converter::ConvFile]
      # @return [Array<Proc>]
      def build_package(pkgs, conv_file)
        procs = []
        pkgs.new_package(conv_file.converter_package_path).tap do |pkg|
          {
            'converter/payload' => conv_file.payload_convs,
            'converter/result' => conv_file.result_convs,
          }.each do |template_dir, convs|
            convs.each do |conv|
              conv_type = pkg.new_combination_type(conv.name).tap do |t|
                m = conv.model
                g = conv.gen_type
                t.add(:model, m.name, m.package_path, m.package_base_path)
                t.add(:gen_type, g.name, g.package_path, g.package_base_path)
                t.memo['base_conv_func'] = (m.ordinary_name == g.ordinary_name) ? "#{m.ordinary_name}ToResult" : "#{m.ordinary_name}To#{g.ordinary_name}"
                t.memo['slice_conv_func'] = (m.ordinary_name == g.ordinary_name) ? "#{m.ordinary_name}SliceToResultSlice" : "#{m.ordinary_name}SliceTo#{g.ordinary_name}Slice"
                t.memo['mappings'] = conv.mappings
                unless conv.model.slice_with_ptr.nil?
                  t.memo['model_slice_with_ptr'] = conv.model.slice_with_ptr
                end
              end
              procs << Proc.new{ build_sentences_with(template_dir, conv_type, nil) }
            end
          end
        end
        return procs
      end

      # @param pkgs [Golang::Packages]
      def resolve_type_names(pkgs)
        pkgs.resolve_type_names(Golang::DatastorePackageFactory.new(config.package_alias_map).packages.dup.add(packages))
      end

    end
  end
end
