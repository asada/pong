require 'spec_helper'

describe MatchesController do
  subject { response }

  describe "GET #index" do
    let(:occured_at) { Time.now }
    let(:me) { Player.create(name: "me") }
    let(:you) { Player.create(name: "you") }
    let!(:newer_match) { Match.create(winner: me, loser: you, occured_at: occured_at) }
    let!(:older_match) { Match.create(winner: you, loser: me, occured_at: occured_at - 1.day) }

    describe "when achievements are won from a match" do
      before { get :index, d: true }
      it { should be_success }
      it { assigns(:matches).should == Match.order("occured_at desc") }
      it { assigns(:match).should be }
      it { assigns(:most_recent_match).should == Match.order("occured_at desc").first }
    end

    describe "when an achievement qualifying from twitter passes in a match id into d" do
      before { get :index, d: newer_match.id }
      it { assigns(:most_recent_match).should == newer_match }
    end
  end

  describe "GET #show" do
    let(:occured_at) { Time.now }
    let(:me) { Player.create(name: "me") }
    let(:you) { Player.create(name: "you") }
    let!(:match) { Match.create(winner: me, loser: you, occured_at: occured_at) }
    it "should assign values for the match and players" do
      get :show, :id => match.to_param
      assigns(:match).should == match
      assigns(:winner).should == match.winner
      assigns(:loser).should == match.loser
    end
  end
  describe "POST #create" do
    let(:match_params) { {winner_name: "taeyang", loser_name: "se7en" } }

    describe "redirection" do
      before { post :create, match_params }
      it { should redirect_to(matches_path(d: true)) }
    end

    it "creates a match" do
      expect { post :create, match_params }.to change(Match, :count).by(1)
    end

    it "finds players that already exist, case insensitively" do
      foo = Player.create(name: "foo")
      bar = Player.create(name: "bar")
      post :create, {winner_name: "Foo", loser_name: "bar"}
      match = Match.last
      match.winner.should == foo
      match.loser.should == bar
    end

    it "doesn't create a match if winner or loser is blank" do
      expect { post :create, {winner_name: "", loser_name: "bar"} }.to_not change(Match, :count)
      expect { post :create, {winner_name: "foo", loser_name: ""} }.to_not change(Match, :count)
      expect { post :create, {winner_name: "", loser_name: ""} }.to_not change(Match, :count)

    end

    context "when the winner name includes extra whitespace" do
      before { post :create, params }

      let(:params) { {winner_name: "Winner McWinnerson   ", loser_name: "Loser O'Loserly   " } }
      let(:winner) { Player.find_by_name "winner mcwinnerson" }
      let(:loser) { Player.find_by_name "loser o'loserly" }

      it "strips whitespace from player names" do
        winner.should be
        loser.should be
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:match) { Match.create(winner: Player.create(name: "gd"), loser: Player.create(name: "top")) }

    it "destroys the given match" do
      expect { delete :destroy, id: match.to_param }.to change(Match, :count).by(-1)
    end

    context "after deletion" do
      before { delete :destroy, id: match.to_param }
      it { should redirect_to(matches_path) }
    end
  end

  describe "GET #rankings" do
    let!(:me) { Player.create(name: "me") }
    let!(:you) { Player.create(name: "you") }
    let!(:us) { Player.create(name: "us") }
    let!(:them) { Player.create(name: "them")}
    let(:occurred_at) { Time.now }
    let!(:older_match) { Match.create(winner: you, loser: me, occured_at: occurred_at - 1.day) }
    let!(:newer_match) { Match.create(winner: me, loser: you, occured_at: occurred_at) }
    let!(:ten_months_ago_match) { Match.create(winner: Player.create(name: "one"), loser: Player.create(name: "two"), occured_at: occurred_at - 10.months) }
    let!(:two_months_ago_match) { Match.create(winner: Player.create(name: "bro1"), loser: Player.create(name: "bro2"), occured_at: occurred_at - 2.months) }
    before { get :rankings }
    it { should be_success }
    it { assigns(:rankings).should == [me, you] }
  end

  describe "GET #players" do
    before do
      @match1 = Match.create(winner: Player.create(name: "danny burkes"), loser: Player.create(name: "edward hieatt"))
      @match2 = Match.create(winner: Player.create(name: "davis frank"), loser: Player.create(name: "parker thompson"))
    end

    it "renders a sorted, titleized list of player names" do
      get :players
      response.should be_success
      response.body.should == ["Danny Burkes", "Davis Frank", "Edward Hieatt", "Parker Thompson"].join("\n")
    end

    it "takes a query parameter" do
      get :players, q: "d"
      response.should be_success
      response.body.should == ["Danny Burkes", "Davis Frank"].join("\n")
    end

    it "applies the query parameter case-insensitively" do
      get :players, q: "D"
      response.should be_success
      response.body.should == ["Danny Burkes", "Davis Frank"].join("\n")
    end
  end
end
