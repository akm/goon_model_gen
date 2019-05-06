require "goon_model_gen"

require "yaml"

require "thor"

require "goon_model_gen/config"
require "goon_model_gen/golang"
require "goon_model_gen/model_builder"
require "goon_model_gen/source/loader"
require "goon_model_gen/generator"

module GoonModelGen
  class Cli < Thor
    include Thor::Actions

    class_option :version, type: :boolean, aliases: 'v', desc: 'Show version before processing'
    class_option :skip, type: :boolean, aliases: 's', desc: "Skip generate file"
    class_option :force, type: :boolean, aliases: 'f', desc: 'Force overwrite files'
    class_option :keep_editable, type: :boolean, aliases: 'k', default: true, desc: 'Keep user editable file'
    class_option :config, type: :string, aliases: 'c', default: '.goon_model_gen.yaml', desc: 'Path to config file. You can generate it by config subcommand'

    desc "source FILE1...", "Show source YAML object for debug"
    def sources(*paths)
      context = load_yamls(paths)
      puts YAML.dump(context)
    end

    desc "build FILE1...", "Build golang objects from source YAML files"
    def build(*paths)
      packages = build_model_objects(paths)
      puts YAML.dump(packages)
    end

    desc "model FILE1...", "Generate model files from source YAML files"
    def model(*paths)
      packages = build_model_objects(paths)
      packages.map(&:files).flatten.each do |f|
        path = File.join(Golang.gopath, 'src', f.package.path, f.name)
        g = new_generator(f)
        g.run(path)
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

      def new_generator(f)
        g = Generator.new(f, thor: self)
        g.load_config(cfg)
        g.skip = options[:skip]
        g.force = options[:force]
        g.keep_editable = options[:keep_editable]
        return g
      end
    end
  end
end
