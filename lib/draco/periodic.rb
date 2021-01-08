# frozen_string_literal: true

module Draco
  # Public: A library for the Draco ECS system that allows the definition of Systems
  # that run every _n_ ticks.
  module Periodic
    VERSION = "0.1.0"

    def self.included(mod)
      mod.extend(ClassMethods)
      mod.prepend(InstanceMethods)
      mod.instance_variable_set(:@period, 1)
    end

    # Internal: Overrides the tick method to check that we want to run the system
    # on the current tick.
    module InstanceMethods
      def tick(context)
        super if (context.state.tick_count % period).zero?
      end

      def period
        self.class.instance_variable_get(:@period) || 1
      end
    end

    # Internal: Adds the DSL to define which tick to run the System.
    module ClassMethods
      def run_every(ticks)
        @period = ticks.to_i
      end
    end
  end
end
