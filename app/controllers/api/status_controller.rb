class Api::StatusController < Api::ApiController

  # == System status endpoint used by Cosmos
  #
  def show
    head :ok
  end
end
