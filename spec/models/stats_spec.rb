require 'spec_helper'
require 'yaml'

RSpec.describe Stats do
  it 'gets initialized w/ optional param' do
    s = Stats.new [], [], [] # default param
    expect(s.mode).to eq :both

    s = Stats.new [], [], [], :leaving
    expect(s.mode).to eq :leaving
  end

  it 'sorts events into order given by timestamp' do
    e = [
      [1, 1, 3, 'arriving'],
      [1, 1, 1, 'arriving'],
      [1, 1, 2, 'arriving']
    ]
    s = Stats.new e, [], []
    expect(s.events.map(&:third)).to eq [1, 2, 3]
  end

  context 'per race' do
    context 'before start' do
      before(:each) do
        data = YAML.load_file Rails.root.join('spec', 'fixtures', 'examples_before_start.yml')
        @events = data[:events]
        @turns  = data[:turns]
        Timecop.freeze Time.at(0)
      end

      subject { Stats.new @events, @turns, [] }

      it 'calculates number of active drivers' do
        expect(subject.active_driver_count).to eq 2
      end

      it 'calculates total drive time' do
        expect(subject.total_drive_time).to be_nil
      end

      it 'calculates average drive time' do
        expect(subject.average_drive_time).to eq 0.0
      end

      it 'returns current driver id' do
        expect(subject.current_driver_id).to eq 3
      end

      it 'returns last driver id' do
        expect(subject.last_driver_id).to eq 1
      end

      it 'calculates minimum drive time' do
        expect(subject.minimum_drive_time).to be_nil
      end

      it 'calculates maximum drive time' do
        expect(subject.maximum_drive_time).to be_nil
      end

      it 'calculates last drive time' do
        expect(subject.last_drive_time).to be_nil
      end
    end

    context 'during race' do
      before(:each) do
        data = YAML.load_file Rails.root.join('spec', 'fixtures', 'examples_active.yml')
        @events = data[:events]
        @turns  = data[:turns]
        Timecop.freeze Time.at(1201)
      end

      subject { Stats.new @events, @turns, [] }

      it 'calculates number of active drivers' do
        expect(subject.active_driver_count).to eq 4
      end

      it 'calculates total drive time' do
        expect(subject.total_drive_time).to eq 1_858
      end

      it 'returns current driver id' do
        expect(subject.current_driver_id).to eq 3
      end

      it 'returns last driver id' do
        expect(subject.last_driver_id).to eq 1
      end
    end

    context 'after finish' do
      before(:each) do
        data = YAML.load_file Rails.root.join('spec', 'fixtures', 'examples_finished.yml')
        @events = data[:events]
        @turns  = data[:turns]
        Timecop.freeze Time.at(1900)
      end

      subject { Stats.new @events, @turns, [] }

      it 'calculates number of active drivers' do
        expect(subject.active_driver_count).to eq 4
      end

      it 'calculates total drive time' do
        expect(subject.total_drive_time).to eq 3_820
      end

      it 'calculates average drive time' do
        expect(subject.average_drive_time).to be_within(0.01).of 636.66
      end

      it 'returns current driver id' do
        expect(subject.current_driver_id).to be_nil
      end

      it 'returns last driver id' do
        expect(subject.last_driver_id).to eq 3
      end
    end
  end

  context 'per team 1' do
    context 'during race' do
      before(:each) do
        data = YAML.load_file Rails.root.join('spec', 'fixtures', 'examples_active.yml')
        @events = data[:events].select { |e| e[0] == 1 }
        @turns  = data[:turns].select { |e| e[0] == 1 }
        Timecop.freeze Time.at(1201)
      end

      subject { Stats.new @events, @turns, [] }

      it 'calculates number of active drivers' do
        expect(subject.active_driver_count).to eq 2
      end

      it 'calculates total drive time' do
        expect(subject.total_drive_time).to eq 1_250
      end

      it 'returns current driver id' do
        expect(subject.current_driver_id).to eq 1
      end

      it 'returns last driver id' do
        expect(subject.last_driver_id).to eq 2
      end
    end

    context 'after finish' do
      before(:each) do
        data = YAML.load_file Rails.root.join('spec', 'fixtures', 'examples_finished.yml')
        @events = data[:events].select { |e| e[0] == 1 }
        @turns  = data[:turns].select { |e| e[0] == 1 }
        Timecop.freeze Time.at(1900)
      end

      subject { Stats.new @events, @turns, [] }

      it 'calculates number of active drivers' do
        expect(subject.active_driver_count).to eq 2
      end

      it 'calculates total drive time' do
        expect(subject.total_drive_time).to eq 1_902
      end

      it 'calculates average drive time' do
        expect(subject.average_drive_time).to be_within(0.01).of 634.0
      end

      it 'returns current driver id' do
        expect(subject.current_driver_id).to be_nil
      end

      it 'returns last driver id' do
        expect(subject.last_driver_id).to eq 1
      end
    end
  end

  context 'per team 2' do
    context 'during race' do
      before(:each) do
        data = YAML.load_file Rails.root.join('spec', 'fixtures', 'examples_active.yml')
        @events = data[:events].select { |e| e[0] == 2 }
        @turns  = data[:turns].select { |e| e[0] == 2 }
        Timecop.freeze Time.at(1201)
      end

      subject { Stats.new @events, @turns, [] }

      it 'calculates number of active drivers' do
        expect(subject.active_driver_count).to eq 2
      end

      it 'calculates total drive time' do
        expect(subject.total_drive_time).to eq 608
      end

      it 'returns current driver id' do
        expect(subject.current_driver_id).to eq 3
      end

      it 'returns last driver id' do
        expect(subject.last_driver_id).to eq 4
      end
    end

    context 'after finish' do
      before(:each) do
        data = YAML.load_file Rails.root.join('spec', 'fixtures', 'examples_finished.yml')
        @events = data[:events].select { |e| e[0] == 2 }
        @turns  = data[:turns].select { |e| e[0] == 2 }
        Timecop.freeze Time.at(1900)
      end

      subject { Stats.new @events, @turns, [] }

      it 'calculates number of active drivers' do
        expect(subject.active_driver_count).to eq 2
      end

      it 'calculates total drive time' do
        expect(subject.total_drive_time).to eq 1_918
      end

      it 'calculates average drive time' do
        expect(subject.average_drive_time).to be_within(0.01).of 639.33
      end

      it 'returns current driver id' do
        expect(subject.current_driver_id).to be_nil
      end

      it 'returns last driver id' do
        expect(subject.last_driver_id).to eq 3
      end
    end
  end

  context 'per driver' do
    context 'during race' do
      before(:each) do
        data = YAML.load_file Rails.root.join('spec', 'fixtures', 'examples_active.yml')
        @events = data[:events].select { |e| e[1] == 1 }
        @turns  = data[:turns].select { |e| e[1] == 1 }
        Timecop.freeze Time.at(800)
      end

      subject { Stats.new @events, @turns, [] }

      it 'calculates number of active drivers' do
        expect(subject.active_driver_count).to eq 1
      end

      it 'calculates total drive time' do
        expect(subject.total_drive_time).to eq 600
      end

      it 'returns last break time' do
        expect(subject.last_break_time).to eq 199
      end
    end


  end

  #   it 'calculates number of active drivers' do
  #     expect(subject.active_driver_count).to eq 4
  #   end

  #   it 'calculates total drive time' do
  #     expect(subject.total_drive_time).to eq 3820
  #   end

  #   it 'calculates average drive time' do
  #     expect(subject.average_drive_time).to be_a Float
  #     expect(subject.average_drive_time).to eq 636.66
  #   end

  #   it 'returns current driver id' do
  #     expect(subject.current_driver_id).to be_nil
  #   end

  #   it 'calculates current drive time' do
  #     Timecop.freeze Time.at(1000)
  #     expect(subject.last_drive_time).to eq 649
  #   end

  #   it 'returns last driver id' do
  #     expect(subject.last_driver_id).to eq 2
  #   end

  #   it 'calculates minimum drive time' do
  #     expect(subject.minimum_drive_time).to eq 600
  #   end

  #   it 'calculates maximum drive time' do
  #     expect(subject.maximum_drive_time).to eq 649
  #   end

  #   it 'calculates last drive time' do
  #     expect(subject.last_drive_time).to eq 649
  #   end
  # end

  # context 'per team' do
  #   before(:each) do
  #     data = YAML.load_file Rails.root.join('spec', 'fixtures', 'examples.yml')
  #     @events = data[:events].select { |e| e[0] == 1 }
  #     @turns  = data[:turns].select { |e| e[0] == 1 }
  #   end

  #   subject { Stats.new @events, @turns }

  #   it 'calculates number of active drivers' do
  #     expect(subject.active_driver_count).to eq 2
  #   end

  #   it 'calculates total drive time' do
  #     expect(subject.total_drive_time).to eq 1210
  #   end

  #   it 'calculates average drive time' do
  #     expect(subject.average_drive_time).to be_a Float
  #     expect(subject.average_drive_time).to eq 605.0
  #   end

  #   it 'returns current driver id' do
  #     expect(subject.current_driver_id).to eq 2
  #   end

  #   it 'calculates current drive time' do
  #     Timecop.freeze Time.at(1000)
  #     expect(subject.last_drive_time).to eq 610
  #   end

  #   it 'returns last driver id' do
  #     expect(subject.last_driver_id).to eq 1
  #   end

  #   it 'calculates minimum drive time' do
  #     expect(subject.minimum_drive_time).to eq 600
  #   end

  #   it 'calculates maximum drive time' do
  #     expect(subject.maximum_drive_time).to eq 610
  #   end

  #   it 'calculates last drive time' do
  #     expect(subject.last_drive_time).to eq 610
  #   end
  # end

  # context 'per driver' do
  #   before(:each) do
  #     data = YAML.load_file Rails.root.join('spec', 'fixtures', 'examples.yml')
  #     @events = data[:events].select { |e| e[1] == 1 }
  #     @turns  = data[:turns].select { |e| e[1] == 1 }
  #   end

  #   subject { Stats.new @events, @turns }

  #   it 'calculates number of active drivers' do
  #     expect(subject.active_driver_count).to eq 1
  #   end

  #   it 'calculates total drive time' do
  #     expect(subject.total_drive_time).to eq 600
  #   end

  #   it 'calculates average drive time' do
  #     expect(subject.average_drive_time).to be_a Float
  #     expect(subject.average_drive_time).to eq 600.0
  #   end

  #   it 'returns current driver id' do
  #     expect(subject.current_driver_id).to eq 1
  #   end

  #   it 'calculates current drive time' do
  #     Timecop.freeze Time.at(1000)
  #     expect(subject.current_drive_time).to eq 999
  #   end

  #   it 'returns last driver id' do
  #     expect(subject.last_driver_id).to be_nil
  #   end

  #   it 'calculates minimum drive time' do
  #     expect(subject.minimum_drive_time).to eq 600
  #   end

  #   it 'calculates maximum drive time' do
  #     expect(subject.maximum_drive_time).to eq 600
  #   end
  # end
end
