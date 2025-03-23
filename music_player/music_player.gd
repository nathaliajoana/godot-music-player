extends Node

var random : bool = false
var loop_current_song : bool = false # TODO: add logic to loop when toggled
var song_position : int = 0

var stage_songs : Array = ["Cosy Coffee Shop", "Fading Memories", "Flavoured Water"]

@onready var music_player : AudioStreamPlayer = $MusicPlayer
@onready var play_button: TextureButton = $VBoxContainer/HBoxContainer/PlayButton
@onready var random_button: TextureButton = $VBoxContainer/HBoxContainer/RandomButton
@onready var back_button: Button = $VBoxContainer/HBoxContainer/BackButton
@onready var next_button: Button = $VBoxContainer/HBoxContainer/NextButton

#region Main functions
func _ready() -> void:
	back_button.set_disabled(true) # TODO: enable after first song finishes
	next_button.set_disabled(true) # TODO: do we want this to be enabled at first?
#endregion

#region Signals

func _on_play_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		AudioManager.play_music(stage_songs, song_position, false, random)
		next_button.set_disabled(false)
	else:
		AudioManager.set_pause(true)	
	
func _on_random_button_toggled(toggled_on: bool) -> void:
	random = toggled_on

func _on_loop_button_toggled(toggled_on: bool) -> void:
	loop_current_song = toggled_on 
	
func _on_next_button_pressed() -> void:
	song_position = stage_songs.find(AudioManager.current_song) + 1
	if song_position > stage_songs.size() - 1: song_position = 0
	AudioManager.play_music(stage_songs, song_position, false, random, true)
	if !play_button.is_pressed(): play_button.set_pressed_no_signal(true)
	back_button.set_disabled(false)

func _on_back_button_pressed() -> void:
	song_position = stage_songs.find(AudioManager.current_song) - 1
	if song_position < stage_songs.size() - 1: back_button.set_disabled(true) # TODO: use seek?
	AudioManager.play_music(stage_songs, song_position, false, random, true)
	if !play_button.is_pressed(): play_button.set_pressed_no_signal(true)
#endregion
