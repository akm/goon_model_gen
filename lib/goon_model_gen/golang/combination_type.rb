require "goon_model_gen"

require "goon_model_gen/golang/type"

module GoonModelGen
  module Golang
    class CombinationType < Type
      class ItemType
        attr_reader :name, :package_path
        attr_reader :type
        def initialize(name, package_path)
          @name, @package_path = name, package_path
        end

        # @param pkgs [Packages]
        def resolve(pkgs)
          @type =
            package_path.present? ?
              pkgs.type_for(name, package_path) :
              pkgs.type_for(name) || raise("#{name.inspect} not found")
        end
      end

      attr_reader :map

      # @param name [String]
      def initialize(name)
        super(name)
        @map = {}
      end

      def add(key, name, package_path)
        map[key] = ItemType.new(name, package_path)
      end

      # @param pkgs [Packages]
      def resolve(pkgs)
        map.each do |_, item|
          item.resolve(pkgs)
        end
      end
    end
  end
end
