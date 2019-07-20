require "goon_model_gen"

require "erb"
require "yaml"
require "pathname"

require "goon_model_gen/golang"

module GoonModelGen
  PACKAGE_ALIAS_MAP = {
    'appengine' => 'google.golang.org/appengine',
    'datastore' => 'google.golang.org/appengine/datastore',
    'log'       => 'google.golang.org/appengine/log',
    'goon'      => 'github.com/mjibson/goon',
  }
end
