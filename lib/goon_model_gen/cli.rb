require "goon_model_gen"

require "yaml"

require "thor"

require "goon_model_gen/source/loader"

module GoonModelGen
  class Cli < Thor
    include Thor::Actions

    desc "source FILE1...", "Show source YAML object for debug"
    def sources(*paths)
      context = load_yamls(paths)
      puts YAML.dump(context)
    end

    no_commands do
      # @param paths [Array<String>] Source::Context
      def load_yamls(paths)
        Source::Loader.new.process(paths)
      end
    end
  end
end
