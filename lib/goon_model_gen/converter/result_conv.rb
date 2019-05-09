require "goon_model_gen"

require "goon_model_gen/converter/abstract_conv"

module GoonModelGen
  module Converter
    class ResultConv < AbstractConv

      class << self
        # @return [String, boolean, boolean] func, requires_context, returns_error
        def load_func(props)
          if f = props['filter']
            return f, false, false
          elsif f = props['writer']
            return f, false, true
          else
            return nil, nil, nil
          end
        end
      end

    end
  end
end
