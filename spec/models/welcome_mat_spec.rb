require 'spec_helper'

describe WelcomeMat do
  let(:me) { Player.create(name: "me") }

  it "should populate achievement specific attributes to achievement on create" do
    achievement = nil
    expect { achievement = WelcomeMat.create(player: me) }.to change(me.achievements, :count).by(1)
    achievement.title.should == "Laying Out the Welcome Mat"
    achievement.description.should == "Play someone not on the ladder"
    achievement.badge.should == "icon-plus"
  end

  describe "#eligible" do
    let(:you) { Player.create(name: "you") }
    let(:him) { Player.create(name: "him") }
    let!(:match) { Match.create(winner: me, loser: you) }
    let!(:match_2) { Match.create(winner: me, loser: him) }

    it "should be eligible if you play someone not yet on the ladder(only 1 match)" do
      me.most_recent_matches.size.should == 2
      him.most_recent_matches.size.should == 1
      WelcomeMat.eligible?(me).should be_true
      WelcomeMat.eligible?(him).should_not be_true
    end
  end
end