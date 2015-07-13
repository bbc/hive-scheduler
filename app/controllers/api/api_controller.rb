class Api::ApiController < ApplicationController
  skip_before_filter :verify_authenticity_token

  private

  def render_model_with_errors(model, status = :unprocessable_entity)
    render status: status, json: { errors: model.errors.full_messages }
  end

  def render_job_not_found
    render status: :not_found, json: { error: t('api.jobs.not_found') }
  end
end
