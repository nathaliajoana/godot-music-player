extends Node

var random : bool = false
var stage_songs : Array = ["Cosy Coffee Shop", "Fading Memories", "Flavoured Water"]

#region Main functions
func _ready() -> void:
	pass
#endregion

#region Signals
func _on_play_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		AudioManager.play_music(stage_songs, 1, false, random)
	else:
		AudioManager.set_pause(true)	
	
func _on_randomize_button_toggled(toggled_on: bool) -> void:
	random = toggled_on
#endregion
