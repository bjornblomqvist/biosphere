module Biosphere
  module Runtime
    extend self

    def privileged?
      Process.uid == 0
    end

  end
end
