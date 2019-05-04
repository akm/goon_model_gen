require "goon_model_gen"

require "yaml"

require "thor"

require "goon_model_gen/model_builder"
require "goon_model_gen/source/loader"

module GoonModelGen
  class Cli < Thor
    include Thor::Actions

    desc "source FILE1...", "Show source YAML object for debug"
    def sources(*paths)
      context = load_yamls(paths)
      puts YAML.dump(context)
    end

    desc "build FILE1...", "Build golang objects from source YAML files"
    def build(*paths)
      packages = build_objects(paths)
      puts YAML.dump(packages)
    end

    no_commands do
      # @param paths [Array<String>]
      # @return [Source::Context]
      def load_yamls(paths)
        Source::Loader.new.process(paths)
      end

      # @param paths [Array<String>] Source::Context
      # @return [Array<Golang::Package>]
      def build_objects(paths)
        context = Source::Loader.new.process(paths)
        b = ModelBuilder.new("github.com/akm/goon_model_gen/examples/proj1")
        b.build(context)
      end
    end
  end
end
