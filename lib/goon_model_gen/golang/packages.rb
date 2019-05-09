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
        if package_path.present?
          parts = type_name.split('.', 2)
          if parts.first == "github"
            require 'pry'
            binding.pry
          end
          name = parts.last
          pkg = find_by_path(package_path) || raise("Package not found for #{name.inspect} by #{package_path.inspect}")
          return pkg.lookup(name) || raise("#{name.inspect} not found in #{package_path.inspect}")
        elsif type_name.include?('.')
          pkg_name, name = type_name.split('.', 2)
          pkg = detect_by(pkg_name)
          return pkg ? pkg.lookup(name) : nil
        else
          each do |pkg|
            t = pkg.lookup(type_name)
            return t if t
          end
          return nil
        end
      end

      def type_for(expression, package_path = nil)
        return nil if expression.blank?
        Modifier.parse(expression) do |name|
          lookup(name, package_path)
        end
      end
    end
  end
end
