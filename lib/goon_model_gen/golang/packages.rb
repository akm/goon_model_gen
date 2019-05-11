require "goon_model_gen"

require "goon_model_gen/golang/package"
require "goon_model_gen/golang/modifier"

require "active_support/core_ext/string"

module GoonModelGen
  module Golang
    class Packages < Array

      class << self
        def wrap(obj)
          case obj
          when Packages then obj
          when Package then Packages.new.add(obj)
          when Array then Packages.new.add(*obj)
          else raise "Unsupported obj for #{self.name}.wrap #{obj.inspect}"
          end
        end
      end

      def name_to_type_map
        each_with_object({}) do |pkg, d|
          d.update(pkg.name_to_type_map)
        end
      end

      def dup
        Packages.new.add(*self)
      end

      def add(*packages)
        packages.flatten.each do |i|
          if pkg = find_by_path(i.path)
            pkg.merge!(i)
          else
            self << i
          end
        end
        self
      end

      def new_package(path)
        Package.new(path).tap{|pkg| add(pkg)}
      end

      def detect_by(name)
        detect{|pkg| pkg.name == name}
      end

      def find_by_path(path)
        detect{|pkg| pkg.path == path}
      end

      def find_or_new(path)
        find_by_path(path) || new_package(path)
      end

      def select_by(name)
        select{|pkg| pkg.name == name}
      end

      def resolve_type_names(extra_packages = [])
        candidates = dup.add(*extra_packages)
        map(&:types).flatten.each do |t|
          t.resolve(candidates)
        end
        return self
      end

      # @param type_name [string]
      # @param package_path [string]
      # @param [Type]
      def lookup(type_name, package_path = nil)
        lookup_by(name: type_name, package_path: package_path)
      end

      # @param name [String]
      # @param package_path [String]
      # @param package_base_path [String]
      # @param [Type]
      def lookup_by(name: nil, package_path: nil, package_base_path: nil)
        pkg_name, type_name = name.include?('.') ? name.split('.', 2) : [nil, name]
        if package_path.present?
          pkg = find_by_path(package_path) || raise("Package not found #{package_path.inspect} for type #{name.inspect}")
          return pkg.lookup(type_name)
        end

        pkgs =
          package_base_path.blank? ? self :
            self.class.wrap(select{|pkg| pkg.path ? pkg.path.include?(package_base_path) : false})
        if pkg_name.present?
          pkgs = pkgs.select_by(pkg_name)
          raise("Package not found #{pkg_name.inspect} for type #{name.inspect}") if pkgs.empty?
          return self.class.wrap(pkgs).lookup(type_name)
        end

        each do |pkg|
          t = pkg.lookup(type_name)
          return t if t
        end
        return nil
      end

      def type_for(expression, package_path = nil)
        return nil if expression.blank?
        Modifier.parse(expression) do |name|
          lookup(name, package_path)
        end
      end

      def type_by(name: nil, package_path: nil, package_base_path: nil)
        return nil if name.blank?
        Modifier.parse(name) do |type_name|
          lookup_by(name: type_name, package_path: package_path, package_base_path: package_base_path)
        end
      end
    end
  end
end
