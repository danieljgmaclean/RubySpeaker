module Utils

  class Speak
    def initialize(voice)
      # Instance variables
      @voice = voice
    end

    def say (text)
      output = `say -v #{@voice} "#{text}"`
    end

  end

end
