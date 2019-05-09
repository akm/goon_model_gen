require "goon_model_gen"

require "goon_model_gen/converter/abstract_conv"

module GoonModelGen
  module Converter
    class PayloadConv < AbstractConv
      class << self
        # @return [String, boolean, boolean] func, requires_context, returns_error
        def load_func(props)
          if f = props['filter']
            return f, false, false
          elsif f = props['reader']
            return f, false, true
          elsif f = props['loader']
            return f, true, true
          else
            return nil, nil, nil
          end
        end
      end

    end
  end
end
