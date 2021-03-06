require "goon_model_gen"

require "erb"
require "yaml"
require "pathname"

require "goon_model_gen/golang"
require "goon_model_gen/package_alias_map"

module GoonModelGen
  class Config

    ATTRIBUTES = %w[
      gofmt_disabled
      base_package_path
      model_dir
      model_package_path
      validation_dir
      validation_package_path
      store_dir
      store_package_path
      converter_dir
      converter_package_path
      goa_gen_dir
      goa_gen_package_path
      structs_gen_dir
      structs_json_path
      validator_package_path
      version_comment
      package_alias_map
    ].freeze

    attr_accessor *ATTRIBUTES

    def fulfill
      @gofmt_disabled ||= false
      @model_dir      ||= "./model"
      @store_dir      ||= "./stores"
      @validation_dir ||= "./validation"
      @converter_dir  ||= "./converters"
      @goa_gen_dir    ||= "./gen"
      @base_package_path  ||= default_go_package
      @model_package_path ||= join_paths(@base_package_path, @model_dir)
      @store_package_path ||= join_paths(@base_package_path, @store_dir)
      @validation_package_path ||= join_paths(@base_package_path, @validation_dir)
      @converter_package_path ||= join_paths(@base_package_path, @converter_dir)
      @goa_gen_package_path   ||= join_paths(@base_package_path, @goa_gen_dir)
      @structs_gen_dir ||= "./cmd/structs"
      @structs_json_path ||= "./structs.json"
      @version_comment ||= false
      @package_alias_map ||= {}
      @package_alias_map = PACKAGE_ALIAS_MAP.merge(@package_alias_map)
      @package_alias_map.default_proc = proc{|hash,key| key.to_s}
      self
    end

    def load_from(path)
      erb = ERB.new(File.read(path), nil, "-")
      erb.filename = path
      config = YAML.load(erb.result, path)

      ATTRIBUTES.each do |name|
        instance_variable_set("@#{name}", config[name].presence)
      end

      fulfill
    end

    def to_hash
      ATTRIBUTES.each_with_object({}) do |name, d|
        d[name] = send(name)
      end
    end

    def to_yaml
      YAML.dump(to_hash)
    end

    def default_go_package
      return default_go_package!
    rescue
      nil
    end

    def default_go_package!
      return Pathname.new(Dir.pwd).relative_path_from(Pathname.new(File.join(Golang.gopath, "src"))).to_s
    end

    def join_paths(path1, path2)
      Pathname.new(path1).join(Pathname.new(path2)).to_s
    end

  end
end
