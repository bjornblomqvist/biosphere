module Biosphere
  module Extensions
    module StringExtensions

      def normal()  stylize(:normal);  end
      def red()     stylize(:red);     end
      def green()   stylize(:green);   end
      def yellow()  stylize(:yellow);  end
      def blue()    stylize(:blue);    end
      def magenta() stylize(:magenta); end
      def cyan()    stylize(:cyan);    end
      def bold()    stylize(:bold);    end
      def faint()   stylize(:faint);   end
      def blink()   stylize(:blink);   end

      # Thanks ActiveSupport
      def underscore
        self.gsub(/::/, '/').gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').gsub(/([a-z\d])([A-Z])/,'\1_\2').tr("-", "_").downcase
      end

      private

      def stylize(style)
        start_code = case style
        when :normal    then 0
        when :red       then 31
        when :green     then 32
        when :yellow    then 33
        when :blue      then 34
        when :magenta   then 35
        when :cyan      then 36
        when :bold      then 1
        when :faint     then 2
        end

        end_code = case style
        when :blink then 25
        when :bold  then 22
        when :faint then 22
        else             0
        end

        %{\033[#{start_code}m#{self}\033[#{end_code}m}
      end

    end
  end
end

class String
  include Biosphere::Extensions::StringExtensions
end