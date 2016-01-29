#Script to solve secret politician meeting brain teaser
#http://fivethirtyeight.com/features/who-will-win-the-politicians-secret-vote/?ex_cid=538fb

#global to print debug information
debug = false

#preferences is an array of candidate preferences 
#candidate[0]'s first preference is candidate[0][0]
#candidate[0]'s second preference is candidate[0][1]
#etc...
def simulate(preferences, debug = false)
	#winner is an array where the index indicates the round of voting, and the value 
	#indicates the candidate that will win given that they've made it to this round
	winner = []
	num_rounds = preferences[0].length - 1
	num_candidates = preferences.length

	#start with the final round of voting and build backwards
	num_rounds.downto(1).each do |i|
		matchup_a = i - 1
		#a vote for matchup_b is a vote for b OR whoever is going to win in the next round
		matchup_b = i

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


#Question 1: Who will be chosen as the presidential candidate?
q1_winner_array = simulate(preferences, debug)

#Question 2: To whom should he transfer his vote, given his candidate preference outlined above 
#(A > B > C > D > E)?

#worst thing that can happen is A's least favorite wins
q2_winner_array = [preferences[0].last]
q2_transfer = 0
1.upto(preferences.length-1).each do |i|
	temp_preferences = preferences.dup

	#replace A's preferences with the other person's
	temp_preferences[0] = temp_preferences[i]
	temp_winner_array = simulate(temp_preferences, debug)
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
