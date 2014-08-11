require 'thor'
module GemTemplate
  class CLI < Thor


    desc "new NAME", "Create a new Gem by passing options"
    method_option :base, type: :string, required: false, default: '.', aliases: '-b'
    def new(name)
      Engine.new(name: name, base: options[:base]).create
    end
  end
end
