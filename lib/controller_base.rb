require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res)

    @req = req
    @res = res
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    !!@already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise "redirect error" if already_built_response?

    if (res.header['location'] = url)
      @already_built_response = true
    end

    res.status = 302

  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise "render error" if already_built_response?

    if (res.body = [content]) && (res['Content-Type'] = content_type)
      @already_built_response = true
    end
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    controller_name = (self.class).to_s.downcase[0..-11] + "_controller"

    cont = File.read("views/#{controller_name}/#{template_name}.html.erb")

    content = ERB.new(cont).result(binding)

    render_content(content, "text/html")

  end

  # method exposing a `Session` object
  def session
    
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end
end
