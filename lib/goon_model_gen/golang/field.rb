require "goon_model_gen"

module GoonModelGen
  module Golang
    class Field
      attr_reader :name, :type
      attr_reader :tags # Hash<string,Array[string]> ex. for datastore, validate, json, etc...
      attr_reader :goon_id # true/false

      def initialize(name, type, tags, goon_id: false)
        @name, @type = name, type
        @tags = tags || {}
        @goon_id = goon_id
      end
    end
  end
end
