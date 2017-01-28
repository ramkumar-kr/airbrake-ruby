require 'active_job'
module Airbrake
  # Airbrake notifier to use ActiveJob
  class ActivejobSender < ::ActiveJob::Base
    queue_as :default

    def perform(serialized_exception, params = {})
      exception = YAML.safe_load(serialized_exception, all_exceptions)
      ::Airbrake.notify_sync(exception, params)
    end

    private

    def all_exceptions
      exceptions = []
      ObjectSpace.each_object(Class) do |cls|
        exceptions << cls if cls.ancestors.include?(Exception)
      end
      exceptions
    end
  end
end
