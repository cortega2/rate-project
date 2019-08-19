require 'rails_helper'

RSpec.describe HealthController, type: :request do
  it 'returns the version' do
    allow(File).to receive(:read).with('./VERSION').and_return(' 0.0.1 ')
    get '/health'
    expect(JSON.parse(response.body)["version"]).to eq('0.0.1')
  end
end
