extends RefCounted

class_name Session

var player_ids: Array[int]

var turn: int = 0
var channel: int

const MAX_PLAYERS: int = 2

func add_player_id(player_id: int):
	if player_ids.size() < MAX_PLAYERS:
		player_ids.append(player_id)
	else:
		printerr("Session: max player count has been reached")

func has_player_id(player_id: int):
	return player_ids.has(player_id)

func rpc(callable: Callable, arg1=null, arg2=null):
#	TODO: Fix errors / hackiness
#	callable = callable.bindv(args) # (in Godot 4.2)

	for player_id in player_ids:
		if arg1 == null:
			callable.rpc_id(player_id)
		elif arg2 == null:
			callable.rpc_id(player_id, arg1)
		else:
			callable.rpc_id(player_id, arg1, arg2)

func _to_string() -> String:
	return "Session(%s, %s, %s)" % ([turn] + player_ids)
