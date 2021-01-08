# frozen_string_literal: true

class Counter < Draco::Component
  attribute :count, default: 0
end

class TestEntity < Draco::Entity
  component Counter
end

class TestSystem < Draco::System
  include Draco::Periodic

  filter Counter

  def tick(_context)
    entities.each { |entity| entity.counter.count += 1 }
  end
end

class TestSystemEveryFive < Draco::System
  include Draco::Periodic

  run_every 5
  filter Counter

  def tick(_context)
    entities.each { |entity| entity.counter.count += 1 }
  end
end

class TestWorld < Draco::World
  entity TestEntity, as: :test_entity

  systems TestSystem
end

class TestWorldEveryFive < Draco::World
  entity TestEntity, as: :test_entity

  systems TestSystemEveryFive
end

class MockState
  def initialize; @tick_count = 1; end

  def tick_count
    current = @tick_count
    @tick_count += 1

    current
  end
end

class MockContext
  attr_reader :state

  def initialize; @state = MockState.new; end
end


RSpec.describe Draco::Periodic do
  it "has a version number" do
    expect(Draco::Periodic::VERSION).not_to be nil
  end

  describe "#tick" do
    context "defaults to every tick" do
      subject { TestWorld.new }
      let(:context) { MockContext.new }

      it "runs once every five ticks" do
        5.times { subject.tick(context) }

        expect(subject.test_entity.counter.count).to eq(5)
      end
    end

    context "every five ticks" do
      subject { TestWorldEveryFive.new }
      let(:context) { MockContext.new }

      it "runs once every five ticks" do
        5.times { subject.tick(context) }

        expect(subject.test_entity.counter.count).to eq(1)
      end
    end
  end
end
