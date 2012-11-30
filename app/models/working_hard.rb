class WorkingHard < Achievement
  class << self
    def title
      "Working Hard or Hardly Working?"
    end

    def description
      "Log more than 5 matches in a single day"
    end

    def badge
      "icon-headphones"
    end

    def eligible?(player)
      player.matches.occurred_today.size > 5
    end
  end
end