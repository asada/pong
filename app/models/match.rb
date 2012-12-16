class Match < ActiveRecord::Base
  validates :winner,      presence: true
  validates :loser,       presence: true
  validates :occured_at,  presence: true
  validate :daily_limit

  belongs_to :winner, :class_name => 'Player'
  belongs_to :loser, :class_name => 'Player'

  has_many :achievements

  before_validation :set_default_occured_at_date, on: :create

  after_save :update_player_ranks
  after_save :create_logs
  after_save :check_achievements
  after_save :check_specials
  after_save :mark_inactive_players

  scope :occurred_today, where("occured_at >= ? AND occured_at <= ?", Date.today.beginning_of_day, Date.today.end_of_day)
  scope :descending, order("occured_at DESC")

  private

  def set_default_occured_at_date
    self.occured_at ||= Time.now
  end

  def update_player_ranks
    winner_rank = winner.rank || Player.maximum(:rank) + 1
    loser_rank = loser.rank || Player.maximum(:rank) + 1

    if winner_rank > loser_rank
      new_rank = (winner_rank + loser_rank) / 2
      winner.update_attributes :rank => nil
      Player.where(['rank < ? AND rank >= ?', winner_rank, new_rank]).order('rank desc').each do |player|
        player.update_attributes :rank => player.rank + 1
      end
      winner.update_attributes :rank => new_rank, :active => true
      loser.reload.update_attributes :active => true
    end
  end

  def create_logs
    winner.logs.create(match: self, rank: winner.rank)
    loser.logs.create(match: self, rank: loser.rank)
  end

  def mark_inactive_players
    cutoff = 30.days.ago
    Player.active.each do |player|
      if player.most_recent_match.nil? || (player.most_recent_match.occured_at < cutoff)
        player.update_attributes :active => false
        Inactive.create(player: player) if !player.achievements.map(&:class).include?(Inactive)
      end
    end

    Player.compress_ranks
  end

  def daily_limit
    winner_id = self.winner_id
    loser_id = self.loser_id
    played_today = Match.where(winner_id: winner_id, loser_id: loser_id).occurred_today.present? || Match.where(winner_id: loser_id, loser_id: winner_id).occurred_today.present?
    (errors[:bad_match] << "- Already played today!") if played_today
  end

  def check_achievements
    achievements = Achievement.subclasses
    winner_achievements_needed = achievements - winner.achievements.map(&:class)
    loser_achievements_needed = achievements - loser.achievements.map(&:class)
    winner_achievements_needed.each do |achievement|
      achievement.create(player: winner, match: self) if achievement.eligible?(winner)
    end
    loser_achievements_needed.each do |achievement|
      achievement.create(player: loser, match: self) if achievement.eligible?(loser)
    end
  end

  def check_specials
    achievements = Achievement::SPECIALS
    achievements.each do |achievement|
      achievement.special(self)
    end
  end
end
