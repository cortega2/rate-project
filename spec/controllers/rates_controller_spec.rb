require 'rails_helper'
require 'tzinfo'
require 'json'

RSpec.describe RatesController, type: :controller do
  describe "GET #index" do
    let(:timezone) { "America/Chicago" }
    let!(:tz) {TZInfo::Timezone.get("America/Chicago")}
    let(:start_time) { Time.new(2000, 1, 1, 9, 0, 0, tz) }
    let(:end_time) { Time.new(2000, 1, 1, 21, 0, 0, tz) }

    let(:start_time_2) { Time.new(2000, 1, 1, 12, 0, 0, tz) }
    let(:end_time_2) { Time.new(2000, 1, 1, 16, 0, 0, tz) }

    it "returns all  available rates" do

      FactoryBot.create(:rate, day_key: "mon", price: 1500.0, start: start_time, end: end_time, timezone: timezone)
      FactoryBot.create(:rate, day_key: "tues", price: 1500.0, start: start_time, end: end_time, timezone: timezone)
      FactoryBot.create(:rate, day_key: "wed", price: 500.0, start: start_time_2, end: end_time_2, timezone: timezone)

      expected = {
        rates: [
          {
            days: "wed",
            times: "1200-1600",
            tz: "America/Chicago",
            price: 500.0
          },
          {
            days: "mon,tues",
            times: "0900-2100",
            tz: "America/Chicago",
            price: 1500.0
          }
        ]
      }.to_json

      get :index, params: {}
      expect(response.body).to eq(expected)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates new rates" do
        body = {
          rates: [
            {
              days: "wed",
              times: "1200-1600",
              tz: "America/Chicago",
              price: 500.0
            },
            {
              days: "mon, tues",
              times: "0900-2100",
              tz: "America/Chicago",
              price: 1500.0
            }
          ]
        }

        expect {
          post :create, body: body.to_json, format: :json
        }.to change(Rate, :count).by(3)
      end

    end

    context "with invalid params" do
      it "renders a JSON response with errors for the new rate" do

        body = {
          rates: [
            {
              times: "1200-1600",
              tz: "America/Chicago",
              price: 500.0
            }
          ]
        }

        post :create, body: body.to_json, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  #describe "GET #show" do
  #  it "returns a success response" do
  #    rate = Rate.create! valid_attributes
  #    get :show, params: {id: rate.to_param}, session: valid_session
  #    expect(response).to be_successful
  #  end
  #end
#
#
  #describe "PUT #update" do
  #  context "with valid params" do
  #    let(:new_attributes) {
  #      skip("Add a hash of attributes valid for your model")
  #    }
#
  #    it "updates the requested rate" do
  #      rate = Rate.create! valid_attributes
  #      put :update, params: {id: rate.to_param, rate: new_attributes}, session: valid_session
  #      rate.reload
  #      skip("Add assertions for updated state")
  #    end
#
  #    it "renders a JSON response with the rate" do
  #      rate = Rate.create! valid_attributes
#
  #      put :update, params: {id: rate.to_param, rate: valid_attributes}, session: valid_session
  #      expect(response).to have_http_status(:ok)
  #      expect(response.content_type).to eq('application/json')
  #    end
  #  end
#
  #  context "with invalid params" do
  #    it "renders a JSON response with errors for the rate" do
  #      rate = Rate.create! valid_attributes
#
  #      put :update, params: {id: rate.to_param, rate: invalid_attributes}, session: valid_session
  #      expect(response).to have_http_status(:unprocessable_entity)
  #      expect(response.content_type).to eq('application/json')
  #    end
  #  end
  #end
#
  #describe "DELETE #destroy" do
  #  it "destroys the requested rate" do
  #    rate = Rate.create! valid_attributes
  #    expect {
  #      delete :destroy, pa rams: {id: rate.to_param}, session: valid_session
  #    }.to change(Rate, :count).by(-1)
  #  end
  #end

end
