require "goon_model_gen"

require "goon_model_gen/golang/package"
require "goon_model_gen/golang/builtin"

module GoonModelGen
  module Golang
    class << self

      def gopath
        # Instead of $GOPATH
        `go env GOPATH`.strip
      end

      # @return [Package]
      def builtin_package
        Buildin.package
      end

    end
  end
end
