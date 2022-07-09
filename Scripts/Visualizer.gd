extends Node

export var pieces_path : NodePath
onready var pieces = get_node(pieces_path)
var white_piece = preload("res://Scenes/White Piece.tscn")
var black_piece = preload("res://Scenes/Black Piece.tscn")


const dis1 = [21,22,31,39,38,29,]
const dis2 = [13,14,15,23,32,40,47,46,45,37,28,20,]
const dis3 = [6,7,8,9,16,24,33,41,48,54,53,52,51,44,36,27,19,12,]
const dis4 = [0,1,2,3,4,10,17,25,34,42,49,55,60,59,58,57,56,50,43,35,26,18,11,5,]

var player
var initial

func _ready():
	draw_complete_board(BoardManager.current_board)
	var first_board = BoardManager.current_board
	initial = State.new(first_board, 0,0)
	player = 1
func _process(delta):
	initial = minimax(initial, player, 2)
	if player == 1:
		player = 2
	elif player == 2:
		player = 1
	update_board(initial.board)
	

func heuristicEval(board, state, player):
	var result = 0
	
	var pieces = []
	getIndexes(board, pieces, player)
	var enemyPieces = []
	getIndexes(board, enemyPieces, 3 - player)
	if player == 2:
		result += 1000 * (state.white_score - state.black_score)
	else: 
		result += 1000 * (state.black_score - state.white_score)
	result += -10 * scoreByDistance(pieces)
	result += 100 * scoreByDistance(enemyPieces)
	result += 10 * grouping(pieces)
	result += -100 * grouping(enemyPieces)

	
	return result

func scoreByDistance(pieces):
	var score = 0
	for temp in pieces: 
		if temp == 30:
			continue
		elif temp in dis1:
			score += 1
		elif temp in dis2:
			score += 2
		elif temp in dis3:
			score += 3
		elif temp in dis4:
			score += 4
	return score
	

func getIndexes(board, arr, player):
	for index in range(len(board)):
		if board[index] == player:
			arr.append(index)

func grouping(pieces):
	var score = 0
	for marbel in pieces:
		if BoardManager.neighbors[marbel][BoardManager.R] in  pieces:
			score += 1
		if BoardManager.neighbors[marbel][BoardManager.DR] in pieces:
			score += 1
		if BoardManager.neighbors[marbel][BoardManager.DL] in pieces:
			score += 1
		if BoardManager.neighbors[marbel][BoardManager.L] in  pieces:
			score += 1
		if BoardManager.neighbors[marbel][BoardManager.UL] in pieces:
			score += 1
		if BoardManager.neighbors[marbel][BoardManager.UR] in pieces:
			score += 1
	return score
			

func minimax(state, player, depth):
	return myMax(state, player, depth)
	

func myMax(state, player, depth):

	var pieces = []
	getIndexes(state.board, pieces, player)
	var enemyPieces = []
	getIndexes(state.board, enemyPieces, 3 - player)
	
	if len(enemyPieces) == 8:
		state.value = INF
		return state
	if len(pieces) == 8:
		state.value = -INF
		return state
	if depth == 0:
		state.value = heuristicEval(state.board, state, player)
		return state
	
	var succ = Successor.calculate_successor(state, player)
	var evals = []
	
	for st in succ:
		evals.append(heuristicEval(st.board, st, player))
		var n = len(evals)
		for i in range(n):
			for j in range(0, n-i-1):
				if evals[j] < evals[j+1]:
					var temp = evals[j]
					evals[j] = evals[j+1]
					evals[j+1] = temp
					
					var temp2 = succ[j]
					succ[j] = succ[j+1]
					succ[j+1] = temp2

	var counter = 0
	var result 
	var alpha = -INF
	for st in succ:

		if counter == 30:
			break
		var minVar = myMin(st, player, depth-1, alpha)
		if  minVar.value > alpha:
			st.value = minVar.value
			alpha = minVar.value
			result = st
		counter += 1
	return result


func myMin(state, player, depth, alpha):
	var pieces = []
	getIndexes(state.board, pieces, player)
	var enemyPieces = []
	getIndexes(state.board, enemyPieces, 3 - player)
	
	if len(enemyPieces) == 8:
		state.value = INF
		return state
	if len(pieces) == 8:
		state.value = -INF
		return state
		
	var succ = Successor.calculate_successor(state, 3 - player)
	var result
	var beta = INF
	for st in succ:
		var maxVar = myMax(st, player, depth-1)
		if  maxVar.value < beta:
			beta = maxVar.value
			if beta < alpha:
				result = st
				result.value = -INF
				break
			st.value = maxVar.value
			result = st
	return result

func update_board(new_board):
	for child in pieces.get_children():
		child.queue_free()
	draw_complete_board(new_board)


func draw_complete_board(board):
	var coordinates = Vector3(0, 0, 0)
	for cell_number in range(len(board)):
		if board[cell_number] == BoardManager.WHITE:
			coordinates = get_3d_coordinates(cell_number)
			var piece = white_piece.instance()
			pieces.add_child(piece)
			piece.translation = coordinates
		elif board[cell_number] == BoardManager.BLACK:
			coordinates = get_3d_coordinates(cell_number)
			var piece = black_piece.instance()
			pieces.add_child(piece)
			piece.translation = coordinates

func get_3d_coordinates(cell_number):
	if cell_number >= 0 and cell_number <= 4:
		return Vector3(-0.6 + cell_number * 0.3, 0.01, -1.04)
	elif cell_number >= 5 and cell_number <= 10:
		return Vector3(-0.75 + (cell_number - 5) * 0.3, 0.01, -0.78)
	elif cell_number >= 11 and cell_number <= 17:
		return Vector3(-0.9 + (cell_number - 11) * 0.3, 0.01, -0.52)
	elif cell_number >= 18 and cell_number <= 25:
		return Vector3(-1.05 + (cell_number - 18) * 0.3, 0.001, -0.26)
	elif cell_number >= 26 and cell_number <= 34:
		return Vector3(-1.2 + (cell_number - 26) * 0.3, 0.01, 0)
	elif cell_number >= 35 and cell_number <= 42:
		return Vector3(-1.05 + (cell_number - 35) * 0.3, 0.01, 0.26)
	elif cell_number >= 43 and cell_number <= 49:
		return Vector3(-0.9 + (cell_number - 43) * 0.3, 0.01, 0.52)
	elif cell_number >= 50 and cell_number <= 55:
		return Vector3(-0.75 + (cell_number - 50) * 0.3, 0.01, 0.78)
	else:
		return Vector3(-0.6 + (cell_number - 56) * 0.3, 0.01, 1.04)
	
