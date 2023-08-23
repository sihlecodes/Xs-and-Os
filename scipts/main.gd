extends Node

class_name Main

func show_hint(text: String):
	%hint.text = text

func show_text(text: String):
	%display.text = text

func _on_restart_pressed() -> void:
	%Server.request_restart.rpc_id(1)

func _on_game_completed():
	%Game.game_completed = true
	show_hint("Press RESTART.")

func _on_game_tied():
	show_text("Game tied. :C")

func _on_game_won(_match: Board.Match):
	%Strike.animate(
		%Board.position + %Board.get_effective_cell_position(_match.start) + %Board.CELL_SIZE/2,
		%Board.position + %Board.get_effective_cell_position(_match.end) + %Board.CELL_SIZE/2)

	match _match.type:
		Piece.Types.X:
			show_text("X won the game!")
		Piece.Types.O:
			show_text("O won the game!")
