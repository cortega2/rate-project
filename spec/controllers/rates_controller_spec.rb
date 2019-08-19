require 'rails_helper'
require 'tzinfo'
require 'json'

RSpec.describe RatesController, type: :controller do
  describe "GET #index" do
    let(:timezone) { "America/Chicago" }
    let!(:tz) {TZInfo::Timezone.get("America/Chicago")}
    let(:start_time) { Time.new(2000, 1, 1, 9, 0, 0, tz) }
    let(:end_time) { Time.new(2000, 1, 1, 21, 0, 0, tz) }

    let(:start_time_2) { Time.new(2000, 1, 1, 6, 0, 0, tz) }
    let(:end_time_2) { Time.new(2000, 1, 1, 18, 0, 0, tz) }


    before(:each) do
      FactoryBot.create(:rate, day_key: "mon", price: 1500.0, start: start_time, end: end_time, timezone: timezone)
      FactoryBot.create(:rate, day_key: "tues", price: 1500.0, start: start_time, end: end_time, timezone: timezone)
      FactoryBot.create(:rate, day_key: "wed", price: 500.0, start: start_time_2, end: end_time_2, timezone: timezone)
    end
    it "returns all available rates in json" do
      expected = {
        rates: [
          {
            days: "wed",
            times: "0600-1800",
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

      headers = { "ACCEPT" => "application/json" }
      request.headers.merge! headers
      get :index, params: {}

      expect(response.body).to eq(expected)
    end

    it "returns all available rates in plain text" do
      expected = "500.0,1500.0"

      headers = { "ACCEPT" => "text/plain" }
      request.headers.merge! headers
      get :index, params: {}

      expect(response.body).to eq(expected)
    end

    it "returns all available rates after a specified time in json" do
      expected = {
        rates: [
          {
            days: "wed",
            times: "0600-1800",
            tz: "America/Chicago",
            price: 500.0
          }
        ]
      }.to_json

      headers = { "ACCEPT" => "application/json" }
      request.headers.merge! headers
      get :index, params: {start: "2019-08-14T07:00:00-05:00"}

      expect(response.body).to eq(expected)
    end

    it "returns all available rates after a specified time in plain text" do
      expected = "500.0"

      headers = { "ACCEPT" => "text/plain" }
      request.headers.merge! headers
      get :index, params: {start: "2019-08-14T07:00:00-05:00"}

      expect(response.body).to eq(expected)
    end

    it "returns all available rates before a specified time in json" do
      expected = {
        rates: [
          {
            days: "wed",
            times: "0600-1800",
            tz: "America/Chicago",
            price: 500.0
          }
        ]
      }.to_json

      headers = { "ACCEPT" => "application/json" }
      request.headers.merge! headers
      get :index, params: {end: "2019-08-14T12:00:00-05:00"}


      expect(response.body).to eq(expected)
    end

    it "returns all available rates before a specified time in plain text" do
      expected = "500.0"

      headers = { "ACCEPT" => "text/plain" }
      request.headers.merge! headers
      get :index, params: {end: "2019-08-14T12:00:00-05:00"}

      expect(response.body).to eq(expected)
    end

    it "returns the available rate that are between a date range in json" do
      expected = {
        rates: [
          {
            days: "tues",
            times: "0900-2100",
            tz: "America/Chicago",
            price: 1500.0
          }
        ]
      }.to_json

      headers = { "ACCEPT" => "application/json" }
      request.headers.merge! headers
      get :index, params: {start: "2019-08-20T09:00:00-05:00", end: "2019-08-20T21:00:00-05:00"}

      expect(response.body).to eq(expected)
    end

    it "returns the available rate that are between a date range in plain text" do
      expected = "1500.0"

      headers = { "ACCEPT" => "text/plain" }
      request.headers.merge! headers
      get :index, params: {start: "2019-08-20T09:00:00-05:00", end: "2019-08-20T21:00:00-05:00"}

      expect(response.body).to eq(expected)
    end

    it "returns an error if a date range spans more than a day in json" do
      expected = {
        error: "Range cannot spand more than a day"
      }.to_json

      headers = { "ACCEPT" => "application/json" }
      request.headers.merge! headers
      get :index, params: {start: "2019-08-20T09:00:00-05:00", end: "2019-08-21T21:00:00-05:00"}

      expect(response.body).to eq(expected)
    end

    it "returns an error if a date range spans more than a day in plain text" do
      expected = "Range cannot spand more than a day"

      headers = { "ACCEPT" => "text/plain" }
      request.headers.merge! headers
      get :index, params: {start: "2019-08-20T09:00:00-05:00", end: "2019-08-21T21:00:00-05:00"}

      expect(response.body).to eq(expected)
    end

    it "returns no rates if a date range is between two rates in json" do
      FactoryBot.create(:rate, day_key: "wed", price: 500.0, start: end_time_2, end: end_time_2 + 60*60, timezone: timezone)

      expected = {
        rates: []
      }.to_json

      headers = { "ACCEPT" => "application/json" }
      request.headers.merge! headers
      get :index, params: {start: "2019-08-21T20:00:00-05:00", end: "2019-08-21T22:00:00-05:00"}

      expect(response.body).to eq(expected)
    end

    it "returns unavailable if a date range is between two rates in plain text" do
      FactoryBot.create(:rate, day_key: "wed", price: 500.0, start: end_time_2, end: end_time_2 + 60*60, timezone: timezone)

      expected = "Unavailable"

      headers = { "ACCEPT" => "text/plain" }
      request.headers.merge! headers
      get :index, params: {start: "2019-08-21T20:00:00-05:00", end: "2019-08-21T22:00:00-05:00"}

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
end
