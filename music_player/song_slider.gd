extends HSlider

@onready var h_slider: HSlider = $"."

func _ready() -> void:
	AudioManager.new_song_playing.connect(_on_song_playing)
	
	h_slider.set_editable(true)
	h_slider.set_min(0)

func _on_song_playing() -> void: # TODO: rename
	var song_length = AudioManager.get_audio_stream_length()
	printerr("song length is ", song_length)
	h_slider.set_max(song_length)
	
