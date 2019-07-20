require "goon_model_gen"

require "goon_model_gen/golang/predeclared_type"
require "goon_model_gen/golang/datastore_supported"
require "goon_model_gen/golang/package"
require "goon_model_gen/golang/packages"
require "goon_model_gen/golang/builtin"

module GoonModelGen
  module Golang
    class DatastorePackageFactory

        def datastore
          @datastore ||= Package.new('google.golang.org/appengine/datastore').tap do |pkg|
            pkg.add(DatastoreSupported.new('ByteString'))
            pkg.add(DatastoreSupported.new('Key'))
          end
        end

        def time
          @time ||= Package.new('time').tap do |pkg|
            pkg.add(DatastoreSupported.new('Time'))
          end
        end

        def appengine
          @appengine ||= Package.new('google.golang.org/appengine').tap do |pkg|
            pkg.add(DatastoreSupported.new('BlobKey'))
            pkg.add(DatastoreSupported.new('GeoPoint'))
          end
        end


        def packages
          @packages ||= Packages.new.tap do |pkgs|
            pkgs << Builtin.package
            pkgs << datastore
            pkgs << time
            pkgs << appengine
          end
        end

    end
  end
end
