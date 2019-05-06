require "goon_model_gen"

require "goon_model_gen/golang/type"

module GoonModelGen
  module Golang
    class Modifier < Type
      attr_reader :prefix, :target_name
      attr_reader :target
      def initialize(prefix, target)
        @prefix = prefix
        case target
        when Type
          @target = target
          @target_name = target.name
        else
          @target = nil
          @target_name = target.to_s
        end
      end

      def package
        target.package
      end

      def qualified_name
        prefix + target.qualified_name
      end

      # @param pkgs [Packages]
      def resolve(pkgs)
        return if target
        @target = pkgs.type_for(target_name) || raise("#{target_name.inspect} not found")
      end

      PATTERN = /\A\*|\A\[\d*\]/

      class << self
        # @param s [String]
        # @return [Proc]
        def parse(s)
          parts = parse_expression(s)
          t = yield(parts.shift)
          return nil unless t
          parts.each do |part|
            t = new(part, t)
          end
          t
        end

        # @param s [String]
        # @return [Array<String>]
        def parse_expression(s)
          m = s.match(PATTERN)
          m.nil? ? [s] : parse_expression(s.sub(PATTERN, '')) + [m[0]]
        end

      end
    end
  end
end
