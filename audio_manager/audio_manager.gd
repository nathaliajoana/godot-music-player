## Modular AudioManager V1.1
extends Node

const music_fade_timer : float = 2.5
const pitch_bend_delay = 0.5
const effects_dir_path = "res://assets/audio/sfx/"
const music_dir_path = "res://assets/audio/music/"

@export var loop_music : bool = true
@export var debug : bool = true

@export_group("Global Button Sounds")
@export var button_pressed_sound_id : String = "clank"
@export var button_focused_sound_id : String = "plop"
@export var button_hovered_sound_id : String = "plop"

@onready var music_player : AudioStreamPlayer = $MusicPlayer #? Global music player
@onready var effects : Node2D = $EffectsPositions #? Node2D on which effects are globally positioned and heard by direction

var randomized_songs : bool = false
var randomized_songs_array : Array = []
var pause_tween : Tween
var effects_list : Dictionary = {}
var music_list : Dictionary = {}
var current_song : String

#region Main functions
func _ready() -> void:
	load_from_dir(music_list, music_dir_path)
	load_from_dir(effects_list, effects_dir_path)
	connect_buttons(get_tree().root) ## Connects to all buttons (and Button inheriting classes)
	get_tree().node_added.connect(_on_scenetree_node_added)

func load_from_dir(target_dict : Dictionary, dir_path) -> void:
	## Loads all files from a directory into an dictionary, with the name of the file as key and a loaded resource object as value.
	## Use this function to load sounds and not bother manually adding new sounds to a constant dict.
	var source_dir = DirAccess.open(dir_path)
	if source_dir:
		source_dir.list_dir_begin()
		var file_name = source_dir.get_next()
		while file_name != "":
			if source_dir.current_is_dir(): pass #? Found directory, skip.
			elif file_name.ends_with(".import"): #? Found an import file
				var file = file_name.split(".import")
				if target_dict.has(file[0]): pass #? File was already loaded, skipping.
				else: #? File not detected, thus loaded normally
					var file_path = str(dir_path + file[0] + file[1])
					target_dict[file[0].left(-4)] = load(file_path)
			else: pass #? Found normal file
			file_name = source_dir.get_next() #? Continue
	else:
		printerr("An error occurred when trying to access the constant path. Have you moved the folder? Check if path %s exists." % dir_path)
	###
# Additional info if you've tried something similar but failed: 
# If you invert the sequence loading only normal files instead of the .import (as it seems logical), this will only work in Editor.
# The reason is normal files disappear after compilation, while .import files maintain their original reachable path even after compiled!
# You can also set the export configuration to maintain the original path of certain extensions (.mp3, .ogg, etc.) to prevent this
	###
#endregion

#region Music player
func set_pause(pause : bool, smooth : bool = false) -> void:
	if !is_instance_valid(music_player): await ready
	if smooth:
		var target_value : float
		if pause_tween: pause_tween.kill()
		pause_tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		if pause:
			music_player.pitch_scale = 1
			target_value = 0.1
		else:
			music_player.pitch_scale = 0.1
			target_value = 1.0
		pause_tween.tween_property(music_player, "pitch_scale", target_value, pitch_bend_delay)
		await pause_tween.finished
		
	music_player.set_stream_paused(pause)
	if debug: printerr("stream paused set to ", music_player.stream_paused)

func set_music(music_id, fade_if_active : bool = true, random : bool = false, stage_songs : Array = []) -> void:
	randomized_songs_array = stage_songs
	
	if random:
		randomize()
		randomized_songs = true
		randomized_songs_array = stage_songs
		music_id = randomized_songs_array[randi_range(0, randomized_songs_array.size() - 1)]
	else: randomized_songs = false
	
	if music_player.playing and fade_if_active:
		var volume_tween : Tween = get_tree().create_tween()
		volume_tween.tween_property(music_player, "volume_db", -20, music_fade_timer)
		await volume_tween.finished
	
	current_song = music_id
	music_player.stream = music_list[music_id]
	music_player.volume_db = 0
	music_player.play()

func play_music(
		music_array : Array,
		music_id : int = 0,
		fade : bool = true,
		random : bool = false
	) -> void:
		if random: music_id = randi_range(0, music_array.size() - 1)
		var selected_music = music_array[music_id]
		if music_player.stream_paused:
			music_player.set_stream_paused(false)
		else: 
			set_music(selected_music, fade, random, music_array)

func _on_music_finished() -> void:
	if randomized_songs and loop_music: set_music(0, true, true, randomized_songs_array)
	elif loop_music: music_player.play()
#endregion

#region Sound effects
func play_random_sound_effect(
		position : Vector2,
		r_sfx_array : Array,
		bus_id : String = "Effects",
		pitch_variation : Vector2 = Vector2(0.9, 1.1)
	) -> void:
	if r_sfx_array.is_empty(): return
	var effect_id = r_sfx_array[randi_range(0, r_sfx_array.size() - 1)]
	play_sound_effect(effect_id, position, bus_id, pitch_variation)

func play_sound_effect(
		effect_id : String,
		position : Vector2 = Vector2.ZERO,
		bus_id : String = "Effects",
		pitch_variation : Vector2 = Vector2(0.9, 1.1)
	) -> void:
	if !effects_list.has(effect_id) or !effect_id: printerr('EMPTY SOUND REQUEST | effect_id %s is invalid, returning without emission' % effect_id); return
	var player #? Audio player node
	if position == Vector2.ZERO: #? Global sound effect
		player = AudioStreamPlayer.new()
	else: #? Positional sound effect
		player = AudioStreamPlayer2D.new()
		player.global_position = position
	player.bus = bus_id
	effects.add_child(player)
	player.stream = effects_list[effect_id]
	player.pitch_scale *= randf_range(pitch_variation.x, pitch_variation.y)
	player.play()
	await player.finished
	player.queue_free()
#endregion

#region Signals
## Global button sounds
## Check for each type and needed adjustment
func check_button(node : Node) -> void:
	if node is Button:
		connect_to_button(node)

 ## Connect to newly added buttons. Ex.: Loaded stages, modules, etc.
func _on_scenetree_node_added(node : Node) -> void: check_button(node)

## Connect all buttons currently present on root tree
func connect_buttons(root) -> void:
	for child in root.get_children():
		check_button(child)
		connect_buttons(child) ## Recursion loop that makes every node and its respective children (includind internals) are connected

func connect_to_button(button : Button)  -> void:
	button.pressed.connect(_on_button_pressed)
	button.focus_entered.connect(_on_button_focused)
	button.mouse_entered.connect(_on_button_hovered)

func _on_button_pressed() -> void: pass #play_sound_effect(button_pressed_sound_id)
func _on_button_focused() -> void: pass #play_sound_effect(button_focused_sound_id)
func _on_button_hovered() -> void: pass #play_sound_effect(button_hovered_sound_id)
#endregion
