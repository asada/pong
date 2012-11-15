require 'spec_helper'

describe Player do
  describe "downcasing names" do
    subject { Player.create(name: "Gregg Van Hove") }
    its(:name) { should == "gregg van hove" }
  end

  it "should validate unique names" do
    Player.create(name: 'p1')
    p = Player.new(name: 'p1')
    p.should_not be_valid
    p.error_on(:name).should be_present
  end

  it "should validate unique ranks" do
    p1 = Player.create(name: 'p1')
    p2 = Player.create(name: 'p2')
    p1.rank.should_not be_nil
    p2.rank.should_not be_nil
    p1.rank.should_not == p2.rank
  end

  it "requires a name" do
    Player.new.should_not be_valid
  end

  it "clears ranks when players become inactive" do
    p1 = Player.create(name: "foo")
    p1.should be_active
    p1.rank.should == 1
    Match.new.send(:mark_inactive_players)
    p1.reload.should be_inactive
    p1.rank.should be_nil
  end

  describe '#display_name' do
    subject { Player.create(name: 'scooby doo') }
    its(:display_name) { should == 'Scooby Doo' }
  end

  describe "ranked" do
    let!(:me) { Player.create(name: "me") }
    let!(:you) { Player.create(name: "you") }
    let!(:us) { Player.create(name: "us") }
    subject { Player.ranked }
    it { should == [me, you, us] }
  end

  describe ".active and .inactive" do
    let!(:me) { Player.create(name: "me") }
    let!(:you) { Player.create(name: "you") }
    let!(:us) { Player.create(name: "us") }

    before do
      us.update_attributes(:rank => nil, :active => false)
    end

    it "should scope players correctly" do
      Player.active.should == [me, you]
      Player.inactive.should == [us]
    end
  end

  describe "#most_recent_match" do
    let!(:player) { Player.create(name: "me") }
    subject { player.most_recent_match }
    let!(:opponent) { Player.create(name: "you") }
    let!(:m1) { Match.create(winner: player, loser: opponent) }
    it { should == m1 }

    context "multiple matches" do
      let!(:m2) { Match.create(winner: opponent, loser: player) }
      it { should == m2 }

      context "with retro-actively created matches" do
        let!(:m3) { Match.create(winner: player, loser: opponent, occured_at: 1.day.ago) }
        it { should == m2 }
      end
    end
  end

  describe ".compress_ranks" do
    let!(:p1) { Player.create(name: "p1", rank: 1) }
    let!(:p2) { Player.create(name: "p2", rank: 3) }
    let!(:p3) { Player.create(name: "p3", rank: 5) }
    let!(:p4) { Player.create(name: "p4", rank: 9) }

    it "should leave no gaps in the rankings" do
      Player.compress_ranks

      p1.reload.rank.should == 1
      p2.reload.rank.should == 2
      p3.reload.rank.should == 3
      p4.reload.rank.should == 4
    end
  end
end
