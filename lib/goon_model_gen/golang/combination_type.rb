require "goon_model_gen"

require "goon_model_gen/golang/type"

module GoonModelGen
  module Golang
    class CombinationType < Type
      class ItemType
        attr_reader :name, :package_path, :package_base_path
        attr_reader :type
        def initialize(name, package_path, package_base_path = nil)
          @name, @package_path, @package_base_path = name, package_path, package_base_path
        end

        def to_hash
          {name: name, package_path: package_path, package_base_path: package_base_path}
        end

        # @param pkgs [Packages]
        def resolve(pkgs)
          @type = pkgs.type_by(**to_hash) || raise("Type not found by #{to_hash.inspect}")
        end
      end

      attr_reader :map

      # @param name [String]
      def initialize(name)
        super(name)
        @map = {}
      end

      def add(key, name, package_path, package_base_path = nil)
        map[key] = ItemType.new(name, package_path, package_base_path)
      end

      # @param pkgs [Packages]
      def resolve(pkgs)
        map.each do |_, item|
          item.resolve(pkgs)
        end
      end

      def fields
        map.values.map{|i| i.respond_to?(:fields) ? i.fields : []}.flatten
      end

    end
  end
end
