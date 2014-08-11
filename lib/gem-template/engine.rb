require 'active_support/inflector'
require 'fileutils'
require 'gem-template/render'
module GemTemplate
  class Engine

    STRUCT = [
      {
        name: 'spec',
        type: 'folder',
        sub: [
          {name: 'spec_helper.rb', type: 'file',content: 'spec_helper'},
          {name: '%s', type: 'folder',sub: [
            {name: '%s_spec.rb', type: 'file', content: 'spec_file'}
          ]}
        ]
      },
      {
        name: 'lib',
        type: 'folder',
        sub: [
          {name: '%s.rb', type: 'file', content: 'gem_lib', unless: "ext?"},
          {name: '%s', type: 'folder', sub: [
            {name: 'version.rb', type: 'file',content: 'gem_version'}
          ]}
        ]
      },
      {
        name: 'ext',
        if: "ext?",
        type: 'folder',
        sub: [
          {
            name: '%s',
            type: 'folder',
            sub: [
              {name: 'extconf.rb', type: 'file', content: 'extconf_tmpl'},
              {name: '%s.c', type: 'file', content: 'c_ext_c'},
              {name: '%s.h', type: 'file', content: 'c_ext_h'}
            ]}
        ]
      },
      {
        name: 'bin',
        if: "bin?",
        type: 'folder',
        sub: [
          {name: '%s', type: 'file', content: 'bin_exe', mode: 0755}
        ]
      },
      {
        name: '%s.gemspec',
        type: 'file',
        content: 'gemspec'
      },
      {
        name: 'Gemfile',
        type: 'file',
        content: 'gemfile'
      },
      {
        name: 'Rakefile',
        type: 'file',
        content: 'rakefile'
      },
      {
        name: 'LICENSE',
        type: 'file',
        content: 'gpl_license'
      },
      {
        name: 'README.md',
        type: 'file',
        content: 'readme_markdown'
      }
    ]


    def initialize(params = {})

      # Required params
      #  :rbgem_name    => 'mruby-hogehoge',
      #  :license        => 'MIT',
      #  :github_user    => 'matsumoto-r',

      # Optional params (auto complete from Required data)
      #  :rbgem_prefix  => '.',
      #  :rbgem_type    => 'class',  # not yet
      #  :class_name     => 'Hogehoge',
      #  :author         => 'mruby-hogehoge developers',

      raise "Base is empty" unless params[:base]
      @base = params[:base]
      @modname = params[:name].camelize
      @gemname = params[:name].underscore.to_sym
      @params = params
      @params.merge!(mod_name: @modname, gem_name: @gemname)
      @params.merge!(git_parameters)
      @render = Render.new(@params)

      #raise "gem_name is nil" if params[:rbgem_name].nil?
    end

    def cra(lop=STRUCT,path=[])
      lop.each do |index|
        if index[:type] == 'folder' && index.has_key?(:sub)
          path << index[:name] % @gemname
          pat = File.join(@base,path)
          if File.exists?(pat)
              puts "\033[33mexisting folder: #{pat}\033[0m"
          else
            FileUtils.mkdir_p(pat)
            puts "\033[32mcreating folder: #{pat}\033[0m"
          end
          pt = path.dup
          path = []
          cra(index[:sub],pt) unless @deep_skip
        else
          if index[:type] == 'folder'
            path << index[:name]
            pat = File.join(path)
            FileUtils.mkdir_p(pat)
          end
          if index[:type] == 'file'
            pch = path.dup
            pch << index[:name] % @gemname
            pat = File.join(@base,pch)
            if File.exist?(pat)
              puts "\033[33mexisting file:   #{pat}\033[0m"
            else
              FileUtils.touch(pat)
              puts "\033[32mcreating file:   #{pat}\033[0m"
            end
            if File.zero?(pat)
              puts "\033[32m  > filling file\033[0m"
              File.write(pat, self.send(index[:content]))
            end
            if index[:mode]
              puts "\033[32m  > chmod file to #{index[:mode]}\033[0m"
              File.chmod(index[:mode], pat)
            end
          end
        end
      end
    end

    def create(&block)
      cra
      puts
      print_next
    end
    def print_next
      if bundle?
        inprintl "Running bundler"
        `cd #{@base} && bundle install`
        inprintl "\033[32mBundler complete\033[0m"
      end
      puts
      if File.exists?(File.join(@base, '.git'))
        inprintl "\033[33mNot executing git init\033[0m"
      else
        inprintl "\033[32mExecuting git init\033[0m"
        git_exec("init .")
        git_exec("add .")
        git_exec("commit -am 'initial import'")
      end
      inprint "Next create a repository on GitHub"

    end

    def git_exec(cmd)
      `cd #{@base};git #{cmd}`
    end

    def inprint(text)
      puts "\n\t > #{text}"
    end

    def inprintl(text)
      print "\r"
      print "\t > #{text}"
    end

    def ext?
      !!@params[:with_ext]
    end
    def bin?
      !!@params[:with_bin]
    end

    def bundle?
      !@params[:no_bundle]
    end

    def git_parameters
      usr = `git config user.name`.chomp
      mail = `git config user.email`.chomp
      {git_user: usr, git_mail: mail}
    end

    private

    # fill methods
    def method_missing(name, *args)
      file = File.expand_path("../templates/#{name}",__FILE__)
      if File.exists?(file)
        @render.render(File.read(file))
      else
        if self.respond_to?(name)
          self.send(name, *args)
        else
          raise NoMethodError
        end
      end

    end
  end
end
