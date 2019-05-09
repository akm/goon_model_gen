require "goon_model_gen"

require "erb"
require "yaml"

require "goon_model_gen/golang/packages"
require "goon_model_gen/golang/datastore_supported"

require "active_support/core_ext/string"

module GoonModelGen
  module Golang
    class StructsLoader

      def process(path)
        erb = ERB.new(::File.read(path), nil, "-")
        erb.filename = path
        txt = erb.result
        raw = YAML.load(txt)

        r = raw.each_with_object({}) do |(key, types), d|
          d[key] = build_packages(types)
        end

        whole_packages = Golang::DatastoreSupported.packages.dup
        r.values.each do |pkgs|
          whole_packages.add(*pkgs)
        end

        r.values.each do |pkgs|
          pkgs.resolve_type_names(whole_packages)
        end
        return r
      end

      def build_packages(types)
        Packages.new.tap do |pkgs|
          types.each do |type_hash|
            next if type_hash['PkgPath'].blank? || type_hash['Name'].blank?
            pkg = pkgs.find_or_new(type_hash['PkgPath'])
            if type_hash['Fields']
              pkg.new_struct(type_hash['Name']).tap do |s|
                type_hash['Fields'].each do |f|
                  t = f['Type']
                  s.new_field(f['Name'], t['Representation'], nil)
                end
              end
            elsif type_hash['Kind'] == 'slice'
              base_type_hash = base_type_hash_from(type_hash['Elem'])
              pkg.new_named_slice(type_hash['Name'], base_type_hash['Name'], base_type_hash['PkgPath'])
            else
              pkg.new_enum(type_hash['Name'], type_hash['Kind'], {})
            end
          end
        end
      end

      def base_type_hash_from(type_hash)
        type_hash['Elem'].nil? ? type_hash : base_type_name_from(type_hash['Elem'])
      end

    end
  end
end
