require "goon_model_gen"

require "goon_model_gen/golang/predeclared_type"
require "goon_model_gen/golang/package"

module GoonModelGen
  module Golang
    class Builtin < PredeclaredType
      TYPE_NAMES =
        %w[bool byte complex128 complex64
           error float32 float64 int int16 int32 int64 int8
           rune string uint uint16 uint32 uint64 uint8 uintptr]

      class << self
        def package
          @package ||= Package.new(nil).tap do |pkg|
            instances.each do |i|
              i.package = pkg
              pkg.types.push(i)
            end
          end
        end

        def instances
          @instances ||= TYPE_NAMES.map{|name| self.new(name) }
        end
      end

    end
  end
end
