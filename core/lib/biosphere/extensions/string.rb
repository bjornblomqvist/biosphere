module Biosphere
  module Extensions
    module StringExtensions

      def normal
        stylize :normal
      end

      def red
        stylize :red
      end

      def green
        stylize :green
      end

      def yellow
        stylize :yellow
      end

      def blue
        stylize :blue
      end

      def magenta
        stylize :magenta
      end

      def cyan
        stylize :cyan
      end

      def bold
        stylize :bold
      end

      def faint
        stylize :faint
      end

      def blink
        stylize :blink
      end

      # Copyright 2005-2012 David Heinemeier Hansson (github.com/rails/rails) under MIT
      def underscore
        gsub(/::/, '/').gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').gsub(/([a-z\d])([A-Z])/, '\1_\2').tr('-', '_').downcase
      end

      # Copyright 2009 Martin Aumont (github.com/mynyml/undent) under MIT
      def undent
        indent = split("\n").select { |line| !line.strip.empty? }.map { |line| line.index(/[^\s]/) }.compact.min || 0
        gsub(/^[[:blank:]]{#{indent}}/, '').chomp
      end

      # Copyright 2009 Martin Aumont (github.com/mynyml/undent) under MIT
      def undent!
        replace undent
      end

      private

      def stylize(style)
        start_code = start_code_for_style(style)
        end_code   = end_code_for_style(style)

        # When this string resets the style because of a bold pattern, ensure it's opened properly again
        string = gsub(/\033\[1m(.*)\033\[22m/, "\033\[1m" + '\1' + "\033\[22m\033[#{start_code}m")

        %(\033[#{start_code}m#{string}\033[#{end_code}m) + "\033[0m"
      end

      def start_code_for_style(style) # rubocop:disable Metrics/MethodLength,Metrics/CyclomaticComplexity
        case style
        when :normal  then 0
        when :red     then 31
        when :green   then 32
        when :yellow  then 33
        when :blue    then 34
        when :magenta then 35
        when :cyan    then 36
        when :bold    then 1
        when :faint   then 2
        end
      end

      def end_code_for_style(style)
        case style
        when :blink then 25
        when :bold  then 22
        when :faint then 22
        else             0
        end
      end

    end
  end
end

String.send :include, Biosphere::Extensions::StringExtensions
