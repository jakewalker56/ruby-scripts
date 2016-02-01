require 'gnuplot'
#Script to solve secret politician meeting brain teaser
#http://fivethirtyeight.com/features/who-will-win-the-politicians-secret-vote/?ex_cid=538fb

#global to print debug information
debug = false

#preferences is an array of candidate preferences 
#candidate[0]'s first preference is candidate[0][0]
#candidate[0]'s second preference is candidate[0][1]
#etc...
def simulate(preferences, vote_order, debug = false)
	#winner is an array where the index indicates the round of voting, and the value 
	#indicates the candidate that will win given that they've made it to this round
	winner = []
	num_rounds = vote_order.length - 1
	num_candidates = preferences.length

	#start with the final round of voting and build backwards
	num_rounds.downto(1).each do |i|
		matchup_a = vote_order[i - 1]
		#a vote for matchup_b is a vote for b OR whoever is going to win in the next round
		matchup_b = vote_order[i]

		#vote is an array where the index indicates the candidate, and the value indicates which of the 
		#two current candidates they are voting for (0 = a, 1 = b)
		vote = []

		if winner.length == 0
			#if this is the last round, next winner is matchup_b
			next_winner = matchup_b
		else
			#if this is not the last round, next winner is the winner in the next round
			next_winner = winner[0]
		end 

		0.upto(num_candidates - 1).each do |j|
			#if candidate j prefers next_winner to a, they vote for b.  Otherwise they vote for a.
			#note there can never be a tie in this formulation.
			if debug
				puts "Candidate " + j.to_s + " voting between " + matchup_a.to_s + " and " + next_winner.to_s + "..."
			end
			if preferences[j].index(matchup_a) < preferences[j].index(next_winner)
				if debug
					puts matchup_a
				end
				vote[j] = 0
			else
				if debug
					puts next_winner
				end
				vote[j] = 1
			end
		end
		#if vote.inject(:+) < num_candidates.to_f / 2.0
		if vote.inject(:+) <= num_candidates.to_f / 2.0
			#a has it, a is this round's winner
			if debug
				puts "**** " + matchup_a.to_s + " wins!"
			end
			winner.unshift(matchup_a)
		else
			#b has it, this round's winner is whoever wins the next round
			if debug
				puts "**** " + next_winner.to_s + " wins!"
			end
			winner.unshift(next_winner)
		end
	end
	return winner
end


preferences = []
#Candidate A: A > B > C > D > E
preferences << [0, 1, 2, 3, 4]
#Candidate B: B > A > E > D > C
preferences << [1, 0, 4, 3, 2]
#Candidate C: C > D > A > E > B
preferences << [2, 3, 0, 4, 1]
#Candidate D: D > B > A > E > C
preferences << [3, 1, 0, 4, 2]
#Candidate E: E > D > B > C > A
preferences << [4, 3, 1, 2, 0]

#vote_order specifies the order the votes happen in.  [0, 1, 2] would mean that everyone votes 
#between 0 and 1, and the winner is then voted against 2, etc.

#vote_order = [0, 1, 2, 3, 4]
vote_order = [4, 3, 2, 1, 0]

#Question 1: Who will be chosen as the presidential candidate?
q1_winner_array = simulate(preferences, vote_order, debug)

#Question 2: To whom should he transfer his vote, given his candidate preference outlined above 
#(A > B > C > D > E)?

#worst thing that can happen is A's least favorite wins
q2_winner_array = [preferences[0].last]
q2_transfer = 0
1.upto(preferences.length-1).each do |i|
	temp_preferences = preferences.dup

	#replace A's preferences with the other person's
	temp_preferences[0] = temp_preferences[i]
	temp_winner_array = simulate(temp_preferences, vote_order, debug)
	if debug 
		puts "Transfering vote to " + i.to_s + "..."
		puts temp_winner_array.inspect
		puts temp_preferences.inspect
	end
	if preferences[0].index(temp_winner_array[0]) < preferences[0].index(q2_winner_array[0])
		#if A likes the current winner more than any other he's seen so far, go ahead 
		#and transfer vote to this candidate
		q2_transfer = i
		q2_winner_array = temp_winner_array 
	end
end

#Question 3: Who will win the candidacy now?
#duh

#Question 4: A month before the meeting, Candidate A must decide whether or not to get the flu vaccine. Should he get it?
#No!

puts "Question 1: " + q1_winner_array[0].to_s + " will win (winner array = " + q1_winner_array.inspect  + ")"
puts "Question 2: A will transfer vote to " + q2_transfer.to_s
puts "Question 3: Winner after transfering to " + q2_transfer.to_s + " will be " + q2_winner_array[0].to_s + " (winner array = " + q2_winner_array.inspect + ")"
puts "Question 4: A " + (preferences[0].index(q2_winner_array[0]) < preferences[0].index(q1_winner_array[0]) ? "should not" : "should") + " get the flu shot!"



Gnuplot.open do |gp|
  Gnuplot::Plot.new( gp ) do |plot|
  
	candidate_trials = [5, 10, 25, 100]
    #candidate_trials = [5, 6, 7, 8, 9, 10]
    #candidate_trials = [100]
    title_string = candidate_trials.join("_")
	
	num_points = 100
    
    plot.terminal "png"
    plot.output File.expand_path("../" + title_string + "_win_percentage.png", __FILE__)
    plot.xrange "[0:" + (num_points - 1).to_s + "]"
    plot.title  "Win Percentage by Vote Order"
    plot.ylabel "Win Percentage"
    plot.xlabel "Order voted on (0 = first vote, 1 = second vote, etc.)"
    
    plot.data = []

    for k in candidate_trials
		num_candidates = k
		num_simulations = 10000
		winner_array = []
		vote_order = (0..(num_candidates-1)).to_a
		num_simulations.times do
			preferences = []
			num_candidates.times do |j|
				preferences[j] = (0..(num_candidates-1)).to_a.shuffle
				#remove himself from preferences
				preferences[j].delete(j)
				#add himself to front- everyone prefers themselves!
				preferences[j].unshift(j)
			end
			winner_array << simulate(preferences, vote_order, debug)[0]
		end
		percent_winners = []
		num_candidates.times do |i|
			percent_winners[i] = winner_array.select{|v| v == i}.count.to_f / num_simulations.to_f
		end
	    x = (0..(num_points-1)).to_a
	    y = percent_winners.first(num_points)
	      
	    plot.data << Gnuplot::DataSet.new( [x, y] ) { |ds|
	        ds.with = "linespoints"
	        ds.title = num_candidates.to_s + " Candidates"
	      }
	end

  end
end

