require "goon_model_gen"

require "goon_model_gen/golang/packages"

module GoonModelGen
  module Builder
    class AbstractBuilder
      attr_reader :base_package_path
      attr_accessor :package_suffix

      # @param base_package_path [String]
      def initialize(base_package_path)
        @base_package_path = base_package_path
      end

      # @param context [Source::Context]
      # @return [Golang::Packages]
      def build(context)
        Golang::Packages.new.tap do |r|
          build_sentences = []
          context.files.each do |f|
            package_path = File.join(base_package_path, f.basename + (package_suffix || ""))
            pkg, procs = build_package(package_path, f.types)
            r << pkg
            build_sentences.concat(procs)
          end
          resolve_type_names(r)
          build_sentences.each(&:call)
        end
      end

      # @param package_path [String]
      # @param types [Array<Source::Type>]
      # @return [Golang::Package, Array<Proc>]
      def build_package(package_path, types)
        raise NotImplementedError, "#{self.type.name} doesn't implement build_package method"
      end

      # @param pkgs [Golang::Packages]
      def resolve_type_names(pkgs)
        raise NotImplementedError, "#{self.type.name} doesn't implement resolve_type_names method"
      end

      # @param action [string] directory name under templates directory. ex. model, store...
      # @param kind [string] directory name under the directory specified by action. ex. goon, struct, enum, slice
      # @param t [Source::Struct]
      # @param go_type [Golang::Type]
      def build_sentences(action, kind, t, go_type)
        template_base = File.join(action, kind)
        build_sentences_with(template_base, go_type, t.generators[action])
      end

      # @param template_base [string] template directory path from templates directory. ex. model/enum, store/goon...
      # @param generators [Hash<string,Object>]
      # @param go_type [Golang::Type]
      def build_sentences_with(template_base, go_type, generators)
        m2t = method_to_template_for(template_base)
        generators ||= default_generators_for(template_base)
        generators.each do |name, suffix|
          next if !suffix
          template = m2t[name]
          raise "No template found for #{name.inspect}" unless template
          parts = [go_type.name.underscore]
          custom_suffix = false
          if suffix.is_a?(String)
            parts << suffix
            custom_suffix = true
          end
          filename = parts.join('_') << '.go'
          go_type.package.find_or_new_file(filename).tap do |file|
            file.custom_suffix = custom_suffix
            file.new_sentence(File.join(template_base, template), go_type)
          end
        end
      end

      def default_generators_for(template_base)
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
        base_dir = File.join(File.expand_path('../../templates', __FILE__), template_base)
        Dir.chdir(base_dir) do
          Dir.glob('*.go.erb')
        end
      end

    end
  end
end
