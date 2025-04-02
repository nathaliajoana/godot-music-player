extends HSlider

@onready var h_slider: HSlider = $"."

func _ready() -> void:
	AudioManager.new_song_playing.connect(_on_song_playing)
	h_slider.set_editable(true)
	h_slider.set_min(0)
	
func _process(_delta) -> void:
	h_slider.set_value(AudioManager.get_playback_position());

func _on_song_playing() -> void:
	h_slider.set_max(AudioManager.get_audio_stream_length())
