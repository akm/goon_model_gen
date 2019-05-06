require "goon_model_gen"

module GoonModelGen
  module Templates
    module DSL
      def dependencies
        @dependencies ||= {}
      end

      def import(alias_or_package, package_or_nil = nil)
        package = package_or_nil || alias_or_package
        new_alias = package_or_nil ? alias_or_package.to_s : nil
        if dependencies.key?(package)
          old_alias = dependencies[package]
          raise "Conflict alias #{old_alias.inspect} and #{new_alias.inspect}" if old_alias != new_alias
        end
        dependencies[package] ||= new_alias
      end

      def partitioned_imports
        import_content = partition(dependencies.keys).map do |group|
          group.map do |path|
            ailas_name = dependencies[path]
            ailas_name ? "\t#{ailas_name} \"#{path}\"" : "\t\"#{path}\""
          end.join("\n")
        end.join("\n\n")
        "import (\n%s\n)\n" % import_content
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
