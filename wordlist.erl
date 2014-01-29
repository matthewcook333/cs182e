-module(wordlist).
-export([load/1, distance/3, correct/2, suggestions/2, main/1]).

-define(THRESHOLD, 1).

% load/1
% input: path to dictionary file.
% output: a list containing the word in the dictionary file.
% details:  if error occurs in opening file or reading input, 
%  the resulting list is empty. Assumes the dictionary file 
%  describes one word per line.
% reference: http://stackoverflow.com/questions/
%  10295557/erlang-reading-integers-from-file
load(Device) ->
	load(Device, []).

load(Device, Dict) -> 
	case io:fread(Device, [], "~s") of
		eof ->
			lists:sort(Dict);
		{ok, [S]} ->
			load(Device, [S | Dict]);
		{error, What} ->
			io:format("io:fread error: ~w~n", [What]),
			load(Device, Dict)
	end.
	
% distance/3
% input: word x, word y, and integer threshold t.
% output: a distance between x and y up to threshold t.
% details:  if the distance is greater than t, this function
%  returns some integer greater than t.
distance(X, Y, T) -> distance(X, Y, T, 0).

distance( [], [], _, Acc) -> Acc.
distance(_, _, T, Acc) when Acc > T -> Acc. 
distance([CharX | X], [CharY | Y], T, Acc) when CharX == CharY ->
	distance(X, Y, T, Acc). 
distance()

% correct/2
% input: word w and list of words L.
% output: true if w appears in L and false otherwise.
correct(W, L) -> lists:member(W, L).

% suggestions/2
% input: word w and list of words L.
% output: a list containing all the suggested spellings for w that appear
%  in L in alphabetical order.
% details:  if there are no suggested spellings for w, returns empty list
suggestions(W, L) ->
	[Similar] = lists:filter(
		fun(X) -> distance(X, W, THRESHOLD) =< THRESHOLD end, L),
	Similar.

% main/1
% input: a list with only one element which is the pathname of dictionary
%  file (written as main([Pathname]).
% output: prints results of correct and suggestions for each word user types
% details:  this allows the user to repeatedly enter words (one per line) 
%  until the EOF character (Control-D) is entered.
main(Pathname) ->
	{ok, Device} = file:open(Pathname, [read]),
	load(Device).

