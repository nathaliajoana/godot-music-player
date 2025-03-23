extends Node

var random : bool = false
var loop_current_song : bool = false # TODO: add logic to loop when toggled
var song_position : int

var stage_songs : Array = ["Cosy Coffee Shop", "Fading Memories", "Flavoured Water"]

@onready var music_player : AudioStreamPlayer = $MusicPlayer
@onready var play_button: Button = $VBoxContainer/HBoxContainer/PlayButton
@onready var back_button: Button = $VBoxContainer/HBoxContainer/BackButton


#region Main functions
func _ready() -> void:
	play_button.set_text("Play") # TODO: change icon using TexturedButton
	back_button.set_disabled(true) # TODO: enable after first song finishes
#endregion

#region Signals
func _on_play_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		play_button.set_text("Pause") 
		printerr("play")
		AudioManager.play_music(stage_songs, 0, false, random)
	else:
		play_button.set_text("Play")
		printerr("pause") 
		AudioManager.set_pause(true)	
	
func _on_randomize_button_toggled(toggled_on: bool) -> void:
	random = toggled_on

func _on_loop_button_toggled(toggled_on: bool) -> void:
	loop_current_song = toggled_on 
	
func _on_next_button_pressed() -> void:
	song_position = stage_songs.find(AudioManager.current_song) + 1
	if song_position > stage_songs.size() - 1: song_position = 0
	AudioManager.play_music(stage_songs, song_position, false, random)
	back_button.set_disabled(false)

func _on_back_button_pressed() -> void:
	song_position = stage_songs.find(AudioManager.current_song) - 1
	if song_position < stage_songs.size() - 1: back_button.set_disabled(true) # TODO: use seek?
	AudioManager.play_music(stage_songs, song_position, false, random)
#endregion
