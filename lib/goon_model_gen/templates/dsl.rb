require "goon_model_gen"

require "active_support/core_ext/string"

module GoonModelGen
  module Templates
    module DSL
      def dependencies
        @dependencies ||= {}
      end

      def import(alias_or_package, package_or_nil = nil)
        package_path = package_or_nil || alias_or_package
        new_alias = package_or_nil ? alias_or_package.to_s : nil
        package_path = package_path.path if package_path.respond_to?(:path)
        package_path = package_alias_map[package_path]
        return if package_path.blank?
        if dependencies.key?(package_path)
          old_alias = dependencies[package_path]
          raise "Conflict alias #{old_alias.inspect} and #{new_alias.inspect}" if old_alias != new_alias
        end
        dependencies[package_path] ||= new_alias
      end

      def partitioned_imports(except: [])
        pkg_paths = dependencies.keys - except
        import_contents = partition(pkg_paths).map do |group|
          group.map do |path|
            ailas_name = dependencies[path]
            ailas_name ? "\t#{ailas_name} \"#{path}\"" : "\t\"#{path}\""
          end.join("\n")
        end
        import_contents.empty? ? '' : "import (\n%s\n)\n" % import_contents.join("\n\n")
      end

      PARTITION_PATTERNS = [
        /\A[^\.\/]+(?:\/.+)?\z/,
        /\Agopkg\.in\//,
        /\Agolang\.org\//,
        /\Agoogle\.golang\.org\//,
        /\Agithub\.com\//,
      ].freeze

      def partition(paths)
        groups = paths.group_by do |path|
          PARTITION_PATTERNS.index{|ptn| ptn =~ path} || PARTITION_PATTERNS.length
        end
        groups.keys.sort.map{|k| groups[k].sort }
      end

      def user_editable(value: true)
        @user_editable = value
      end

      def user_editable?
        @user_editable
      end

    end
  end
end
