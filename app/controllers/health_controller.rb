class HealthController < ApplicationController
  def index
    version = File.read('./VERSION').strip()
    render json: {version: version}
  end
end
