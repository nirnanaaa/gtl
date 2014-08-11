require 'ostruct'
require 'erb'

module GemTemplate
  class Render < OpenStruct
    def render(template)
      ERB.new(template).result(binding)
    end
  end
end
