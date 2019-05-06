require "goon_model_gen"

require "goon_model_gen/templates/dsl"

module GoonModelGen
  class Generator
    include Templates::DSL

    attr_reader :file, :packages
    attr_reader :templates_dir

    attr_accessor :thor
    attr_accessor :gofmt_disabled  # false/true
    attr_accessor :version_comment # false/true
    attr_accessor :force, :skip    # false/true
    attr_accessor :keep_editable   # false/true

    DEFAULT_TEMPLATES_DIR = File.expand_path('../templates', __FILE__)

    # @param file [Golang::File]
    # @param templates_dir [String]
    def initialize(file, packages, templates_dir: DEFAULT_TEMPLATES_DIR, thor: nil)
      @file = file
      @packages = packages
      @templates_dir = templates_dir
      @thor = thor
    end

    COLORS = {
      blue:  "\e[34m",
      clear: "\e[0m",
    }

    def run(output_path, variables = {})
      content = execute(variables)

      if user_editable? && File.exist?(output_path) && keep_editable
        $stderr.puts("%sKEEP%s %s" % [COLORS[:blue], COLORS[:clear], output_path])
        return
      end

      options = {skip: skip, force: force}
      thor.create_file(output_path, content, options)
    end

    def execute(variables = {})
      variables.each do |key, val|
        define_singleton_method(key){ val }
      end

      texts = file.sentences.sort_by(&:template_path).map do |sentence|
        template_path = File.join(templates_dir, sentence.template_path)

        # local variables used in tempaltes
        type = sentence.type
        package = type.package

        erb = ERB.new(File.read(template_path), nil, "-")
        erb.filename = template_path
        erb.result(binding).strip
      end

      r = [
        header_comments,
        "package %s" % file.package.name,
        partitioned_imports(except: [file.package.path]),
        texts.join("\n\n"),
      ].join("\n\n").strip << "\n"

      r = gofmt(r) unless gofmt_disabled
      r
    end

    def header_comments
      r = []
      if user_editable?
        r << "You can edit this file. goa_model_gen doesn't overwrite this file."
      else
        r << "DO NOT EDIT this file."
      end

      if version_comment
        r << "This code generated by goon_model_gen-#{GoonModelGen::VERSION}"
      end

      return r.map{|s| "// #{s}" }.join("\n")
    end


    def gofmt(content)
      # https://docs.ruby-lang.org/ja/2.5.0/class/IO.html#S_POPEN
      r = IO.popen(["gofmt"], "r+", err: :out) do |io|
        io.puts(content)
        io.close_write
        io.read
      end
      return r unless r.empty?
      raise "gofmt returned empty output:\n#{content}"
    end

    # @param cfg [Config]
    def load_config(cfg)
      [:gofmt_disabled, :version_comment].each do |key|
        self.send("#{key}=", cfg.send(key))
      end
    end
  end
end