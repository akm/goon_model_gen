require "goon_model_gen"

require "yaml"

require "thor"

require "goon_model_gen/config"
require "goon_model_gen/model_builder"
require "goon_model_gen/source/loader"
require "goon_model_gen/generator"

module GoonModelGen
  class Cli < Thor
    include Thor::Actions

    class_option :version, type: :boolean, aliases: 'v', desc: 'Show version before processing'
    class_option :skip, type: :boolean, aliases: 's', desc: "Skip generate file"
    class_option :force, type: :boolean, aliases: 'f', desc: 'Force overwrite files'
    class_option :overwrite_custom_file, type: :boolean, aliases: 'o', desc: 'Overwrite custom files if given'
    class_option :config, type: :string, aliases: 'c', default: '.goon_model_gen.yaml', desc: 'Path to config file. You can generate it by config subcommand'

    desc "config", "Show config"
    def config
      puts YAML.dump(cfg)
    end

    desc "source FILE1...", "Show source YAML object for debug"
    def sources(*paths)
      context = load_yamls(paths)
      puts YAML.dump(context)
    end

    desc "model FILE1...", "Generate model files from source YAML files"
    option :inspect, type: :boolean, desc: "Don't generate any file and show package objects if given"
    def model(*paths)
      packages = build_model_objects(paths)
      if options[:inspect]
        puts YAML.dump(packages)
      else
        packages.map(&:files).flatten.each do |f|
          new_generator(f, packages).run
        end
      end
    end

    no_commands do
      def cfg
        @cfg ||= Config.new.load_from(options[:config])
      end

      # @param paths [Array<String>]
      # @return [Source::Context]
      def load_yamls(paths)
        Source::Loader.new.process(paths)
      end

      # @param paths [Array<String>] Source::Context
      # @return [Array<Golang::Package>]
      def build_model_objects(paths)
        context = Source::Loader.new.process(paths)
        b = ModelBuilder.new(cfg.model_package_path)
        b.build(context)
      end

      # @param f [Golang::File]
      # @param packages [Golang::Packages]
      # @return [Generator]
      def new_generator(f, packages)
        g = Generator.new(f, packages, thor: self)
        g.load_config(cfg)
        g.skip = options[:skip]
        g.force = options[:force]
        g.overwrite_custom_file = options[:overwrite_custom_file]
        return g
      end
    end
  end
end
