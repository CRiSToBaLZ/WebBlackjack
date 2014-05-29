require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true

helpers do


def total(playa_o_deala)   #[["5","C"], ["K","H"], ["2","S"]]
  ranks = playa_o_deala.map {|x| x[0]}
  total = 0
  current_rank = 0
  ace_count = 0
  0.upto(ranks.length-1) do |i|
    if ranks[i].to_i !=0
      rank_value = ranks[i].to_i
    elsif ranks[i] == "A"
      rank_value = 11
      ace_count += 1
    else
    rank_value = 10
    end
    total += rank_value
  end
  if total > 21
    if ace_count > 0
      while ace_count != 0 and total > 21
        total -= 10
        ace_count -= 1
      end
    end
  end
  return total
end


def display_card(card)
  suit = case card[1]
    when "C" then "clubs"
    when "D" then "diamonds"
    when "H" then "hearts"
    when "S" then "spades"
  end
  if card[0] !="A" and card[0]!="K" and card[0] !="Q" and card[0] !="J"
    value = card[0]
  else
    if card[0] == "A"
      value = "ace"
    elsif card[0] == "K"
      value = "king"
    elsif card[0] == "Q"
      value = "queen"
    else
      value = "jack"
    end
  end
  "<img src='/images/cards/#{suit}_#{value}.jpg' class='card_image'>"
end

def winner!(msg)
  @hit_stay_buttons = false
  @play_again_button = true
  session[:money_amt] += session[:bet_amt]*2
  @winning = "#{session[:player_name]} wins!  #{msg}  #{session[:player_name]} now has $#{session[:money_amt].to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}." 
end

def tied!(msg)
  @hit_stay_buttons = false
  @play_again_button = true
  session[:money_amt] += session[:bet_amt]
  @equal = "#{msg}  #{session[:player_name]} has $#{session[:money_amt].to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}." 
  # binding.pry  
end

def loser!(msg)
  @hit_stay_buttons = false
  @play_again_button = true
  @losing = "#{session[:player_name]} loses.  #{msg}  #{session[:player_name]} now has $#{session[:money_amt].to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}."
end


     
end

before do
  @hit_stay_buttons = true
  @dealer_show_buttons = false
  @play_again_button = false
  @dealer_show_first = false
  @welcome = false
end

post '/' do
  redirect '/'
end

get '/' do
  if session[:player_name]
    redirect '/bet'
  else
    redirect '/new_player'
  end
end

get '/new_player' do
  erb :new_player
end

post '/new_player' do
  if params[:player_name].empty?
    @error = "Please enter a name."
    halt erb(:new_player)
  end
  session[:player_name] = params[:player_name]
  session[:money_amt] = 1000
  redirect '/bet'
end

get '/bet' do
  erb :bet
end

post '/bet' do
  if params[:bet_amt].to_i < 1
    @error = "Please enter a bet amount."
    halt erb(:bet)
  end
  if params[:bet_amt].to_i > session[:money_amt]
    @error = "You cannot bet more money than you have.  You currently have $#{session[:money_amt]}."
    halt erb(:bet)
  end
  session[:bet_amt] = params[:bet_amt].to_i
  session[:money_amt] = session[:money_amt] - session[:bet_amt]
  redirect '/game'
end

get '/game' do
  @welcome = true
  # create a deck and put it in session
  ranks = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
  suits = ['H', 'D', 'C', 'S']
  session[:deck] = ranks.product(suits)
  session[:total_player] = 0
  session[:total_dealer] = 0
  
  # deal cards
  session[:hand_dealer] = []
  session[:hand_player] = []
  session[:hand_dealer] << session[:deck].shuffle!.pop
  session[:hand_player] << session[:deck].pop
  session[:hand_dealer] << session[:deck].pop
  session[:hand_player] << session[:deck].pop
  # session[:hand_player] = [["5","C"], ["7","H"]] ##testing lineeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
  # session[:hand_dealer] = [["3","S"], ["4","D"]] ##testing lineeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
  

  session[:total_player] = total(session[:hand_player])
  session[:total_dealer] = total(session[:hand_dealer])
  
  if session[:total_player] == 21
    winner!("#{session[:player_name]} hit Blackjack.")
    
  end
  erb :game
end


post '/game/player/hit' do
  new_card = session[:deck].pop
  # new_card = ["5","H"] ##testing line
  session[:hand_player] << new_card
  session[:total_player] = total(session[:hand_player])
  if session[:total_player] > 21
    loser!("#{session[:player_name]} busted.")
  end
  if session[:total_player] == 21
    winner!("#{session[:player_name]} hit Blackjack.")
  end
  
  erb :game, layout: false
end


post '/game/player/stay' do
  @hit_stay_buttons = false
  if session[:total_dealer] == 21
    @dealer_show_first = true
    loser!("Blackjack dealer.")
  elsif session[:total_dealer] >= 17
    redirect '/game/comparison'
  else
    @dealer_show_buttons = true
    @dealer_show_first = true
  end
  erb :game
end

post '/game/dealer/hit' do
  @dealer_show_first = true
  @hit_stay_buttons = false
  while session[:total_dealer] < 17
    @dealer_show_buttons = true
    new_card = session[:deck].pop
    # new_card = ["5","H"] ##testing line
    session[:hand_dealer] << new_card
    session[:total_dealer] = total(session[:hand_dealer])
    if session[:total_dealer] > 21
        @dealer_show_buttons = false
        winner!("Dealer busted.")
    elsif session[:total_dealer] == 21
      @dealer_show_buttons = false
    elsif session[:total_dealer] >= 17 and session[:total_dealer] < 21
      @dealer_show_buttons = false
      redirect '/game/comparison'
    end
    halt erb(:game)
  end
end
  
get '/game/comparison' do
  @dealer_show_first = true
  if session[:total_player] == session[:total_dealer]
    tied!("Tie.")
  elsif session[:total_player] > session[:total_dealer]
    winner!("#{session[:player_name]} has #{session[:total_player]} while the dealer has #{session[:total_dealer]}.")
  else
    loser!("The dealer has #{session[:total_dealer]} while #{session[:player_name]} has #{session[:total_player]}.")
  end
  erb :game
end


  