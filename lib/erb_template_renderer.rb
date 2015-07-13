class ErbTemplateRenderer

  def initialize(erb_template, variables)
    @erb_template, @variables = erb_template, variables
  end

  def render
    template.result(template_variables.instance_eval { binding })
  end

  private

  def template
    ERB.new(@erb_template)
  end

  def template_variables
    OpenStruct.new(@variables)
  end
end
