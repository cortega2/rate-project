require 'structure_validator'
require 'tzinfo'

RSpec.describe StructureValidator do
  context '::all_valid?' do
    it 'checks that all parts of the structure are valid' do
      rate = {
        days: ["mon"],
        times: "0900-1200",
        price: 100,
        tz: "America/Chicago"
      }

      allow(StructureValidator).to receive(:structure?).and_return(true)
      allow(StructureValidator).to receive(:timezone?).and_return(true)
      allow(StructureValidator).to receive(:times?).and_return(true)
      allow(StructureValidator).to receive(:has_days?).and_return(true)

      expect(StructureValidator).to receive(:structure?).with(rate)
      expect(StructureValidator).to receive(:timezone?).with(rate[:tz])
      expect(StructureValidator).to receive(:times?).with(rate[:times])
      expect(StructureValidator).to receive(:has_days?).with(rate[:days])
      StructureValidator::all_valid?(rate)
    end
  end

  context '::structure?' do
    it 'returns true if the structure matches' do
      rate = {
        days: "mon",
        times: "0900-1200",
        price: 100,
        tz: "America/Chicago"
      }
      expect(StructureValidator::structure?(rate)).to be(true)
    end

    it 'returns false if there is no days' do
      rate = {
        times: "0900-1200",
        price: 100,
        tz: "America/Chicago"
      }
      expect(StructureValidator::structure?(rate)).to be(false)
    end

    it 'returns false if the days variable is not a string' do
      rate = {
        days: 547,
        times: "0900-1200",
        price: 100,
        tz: "America/Chicago"
      }
      expect(StructureValidator::structure?(rate)).to be(false)
    end

    it 'returns false if there is no times' do
      rate = {
        days: ["mon"],
        price: 100,
        tz: "America/Chicago"
      }
      expect(StructureValidator::structure?(rate)).to be(false)
    end

    it 'returns false if there is no price' do
      rate = {
        days: ["mon"],
        times: "0900-1200",
        tz: "America/Chicago"
      }
      expect(StructureValidator::structure?(rate)).to be(false)
    end

    it 'returns false if there is no tz' do
      rate = {
        days: ["mon"],
        times: "0900-1200",
        price: 100
      }
      expect(StructureValidator::structure?(rate)).to be(false)
    end
  end

  context '::timezone?' do
    it 'returns false if the timezone is not valid' do
      tz = "im clearly not real"
      expect(StructureValidator::timezone?(tz)).to be(false)
    end

    it 'returns true if the timezone is not valid' do
      tz = "America/Chicago"
      expect(StructureValidator::timezone?(tz)).to be(true)
    end
  end

  context '::times?' do
    it 'returns false if the time doesnt match the format' do
      times = "asfdrvfs"
      expect(StructureValidator::times?(times)).to be(false)
    end

    it 'returns true if the time matches the format' do
      times = "0900-1000"
      expect(StructureValidator::times?(times)).to be(true)
    end
  end

  context '::has_days?' do
    it 'returns false if there are no days' do
      expect(StructureValidator::has_days?([])).to be(false)
    end

    it 'returns true if there are values in the days array' do
      expect(StructureValidator::has_days?(["im a day"])).to be(true)
    end
  end

  context '::restructure?' do
    it 'returns a combined group of rates as one hash object' do
      tz = TZInfo::Timezone.get("America/Chicago")
      start_time = Time.new(2000, 1, 1, 9, 30, 0, tz)
      end_time = Time.new(2000, 1, 1, 12, 30, 0, tz)

      day_1 = {
        day_key: "mon",
        start: start_time,
        end: end_time,
        price: 900,
        timezone: "America/Chicago"
      }

      day_2 = {
        day_key: "tues",
        start: start_time,
        end: end_time,
        price: 900,
        timezone: "America/Chicago"
      }

      expected_rates = {
        days: "mon,tues",
        times: "0930-1230",
        price: 900,
        tz: "America/Chicago"
      }

      expect(StructureValidator::restructure([day_1, day_2])).to eq(expected_rates)
    end
  end
end
