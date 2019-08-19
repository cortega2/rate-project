require 'rails_helper'
require 'tzinfo'

RSpec.describe Rate, type: :model do
  context 'Factory' do
    it 'has a valid factory' do
      # TODO: factory bot is not as useful as orginially thought
      #       consider removing it or rafactoring tests
      expect(FactoryBot.build(:rate, day_key: "mon", price: 1.0, start: Time.now, end: Time.now, timezone: "America/Chicago").save).to be true
    end
  end

  context 'when there is no day key' do
    let!(:params) {{day_key: nil, price: 1.0, start: Time.now, end: Time.now, timezone: "America/Chicago" }}
    let(:rate) {Rate.create(params)}

    it 'will not be valid' do
      expect(rate.valid?).to be(false)
    end

    it "will have description can't be blank error" do
      field = :day_key
      expect(rate.errors.messages[field][0]).to eq("can't be blank")
    end
  end

  context 'when the day key is not valid' do
    let!(:params) {{day_key: "not valid", price: 1.0, start: Time.now, end: Time.now, timezone: "America/Chicago" }}
    let(:rate) {Rate.create(params)}

    it 'will not be valid' do
      expect(rate.valid?).to be(false)
    end

    it "will have description has to be valid key error" do
      field = :day_key
      expect(rate.errors.messages[field][0]).to eq("has to be a valid key")
    end
  end

  context 'when there is no price' do
    let!(:params) {{day_key: "mon", price: nil, start: Time.now, end: Time.now, timezone: "America/Chicago" }}
    let(:rate) {Rate.create(params)}

    it 'will not be valid' do
      expect(rate.valid?).to be(false)
    end

    it "will have description can't be blank error" do
      field = :price
      expect(rate.errors.messages[field][0]).to eq("can't be blank")
    end
  end

  context 'when the price is negative' do
    let!(:params) {{day_key: "mon", price: -1, start: Time.now, end: Time.now, timezone: "America/Chicago" }}
    let(:rate) {Rate.create(params)}

    it 'will not be valid' do
      expect(rate.valid?).to be(false)
    end

    it "will have description greater than 0 error" do
      field = :price
      expect(rate.errors.messages[field][0]).to eq("must be greater than 0")
    end
  end

  context 'when there is no start time' do
    let!(:params) {{day_key: "mon", price: 1.0, start: nil, end: Time.now, timezone: "America/Chicago" }}
    let(:rate) {Rate.create(params)}

    it 'will not be valid' do
      expect(rate.valid?).to be(false)
    end

    it "will have description can't be blank error" do
      field = :start
      expect(rate.errors.messages[field][0]).to eq("can't be blank")
    end
  end

  context 'when there is no end time' do
    let!(:params) {{day_key: "mon", price: 1.0, start: Time.now, end: nil, timezone: "America/Chicago" }}
    let(:rate) {Rate.create(params)}

    it 'will not be valid' do
      expect(rate.valid?).to be(false)
    end

    it "will have description can't be blank error" do
      field = :end
      expect(rate.errors.messages[field][0]).to eq("can't be blank")
    end
  end

  context 'when there is no timezone' do
    let!(:params) {{day_key: "mon", price: 1.0, start: Time.now, end: Time.now, timezone: nil }}
    let(:rate) {Rate.create(params)}

    it 'will not be valid' do
      expect(rate.valid?).to be(false)
    end

    it "will have description can't be blank error" do
      field = :timezone
      expect(rate.errors.messages[field][0]).to eq("can't be blank")
    end
  end

  context '::replace_all' do
    let(:params_mon) {{day_key: "mon", price: 1.0, start: Time.now, end: Time.now, timezone: "America/Chicago" }}
    let(:params_tues) {{day_key: "tues", price: 1.0, start: Time.now, end: Time.now, timezone: "America/Chicago" }}

    before(:each) do
      # create some data
      Rate.create(params_mon)
    end

    it 'will remove old rates and insert new ones' do
      new_rate = Rate.new(params_tues)
      Rate.replace_all([new_rate])

      expect(Rate.count).to eq(1)
      expect(Rate.all[0][:day_key]).to eq("tues")
    end
  end

  context '::create_time' do
    it 'given a time and a time zone it will return a UTC time' do
      tz = TZInfo::Timezone.get("America/Chicago")
      expected_time = Time.new(2000, 1, 1, 9, 30, 0, tz)
      expect(Rate.create_time("0930", "America/Chicago")).to eq(expected_time)
    end
  end

  context '::new_from_group' do
    it 'returns a list of rate objects and no errors' do
      rate = {
        days: "mon,tues",
        times: "0900-1200",
        price: 100,
        tz: "America/Chicago"
      }

      created_rates = Rate.new_from_group(rate)
      expect(created_rates[:error]).to eq(false)
      expect(created_rates[:rates].length).to eq(2)
    end

    it 'returns an error when a rate is invalid' do
      rate = {
        days: "mon,not valid",
        times: "0900-1200",
        price: 100,
        tz: "America/Chicago"
      }

      created_rates = Rate.new_from_group(rate)
      expect(created_rates[:error]).to eq(true)
      expect(created_rates[:rates].length).to eq(1)
    end
  end
end
