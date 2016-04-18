module Biosphere
  module Tools
    class Augmentor
      class Result
        attr_reader :status

        def initialize(options={})
          @success = options[:success]
          @status = options[:status]
        end

        def success?
          !!@success
        end

        def failure?
          !success?
        end
      end

    end
  end
end
