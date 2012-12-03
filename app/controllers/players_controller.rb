class PlayersController < ApplicationController
  def show
    @player = Player.find(params[:id])
    @matches = @player.matches
    @achievement = Achievement.find_by_id(params[:a]) if params[:a]
  end

  def update
    @player = Player.find(params[:id])
    if @player.update_attributes(params[:player])
      flash.notice = "Lookin' good, good lookin'"
      if !@player.achievements.map(&:class).include?(PicturePerfect) && @player.avatar?
        achievement = PicturePerfect.create(player: @player)
      end
    else
      flash.error = "No bueno"
    end
    redirect_to player_path(@player, a: achievement.id)
  end

  def odds
    player = Player.find(params[:player_id])
    opponent = Player.find(params[:opponent_id])
    matches = player.matches.where("winner_id = ? OR loser_id = ?", opponent.id, opponent.id)
    total_matches = matches.count.to_f
    probability = case
                    when total_matches > 0
                      player_wins = matches.where(winner_id: player.id).count.to_f
                      player_wins/total_matches*100
                    when player.rank.nil? && opponent.rank.nil?
                      50
                    when player.rank.nil?
                      0
                    when opponent.rank.nil?
                      100
                    else
                      total_rank = player.rank.to_f + opponent.rank.to_f
                      opponent.rank.to_f/total_rank*100
                  end
    render text: probability, content_type: "text/javascript"
  end
end