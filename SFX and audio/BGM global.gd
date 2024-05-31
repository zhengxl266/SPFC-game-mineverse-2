extends AudioStreamPlayer2D

const level_music = preload("res://SFX and audio/DAY.mp3")
const night_music = preload("res://SFX and audio/Night_Time.mp3")

func _play_music(music: AudioStream, volume = 0.0):
	if stream == music:
		return
		
	stream = music
	volume_db = volume
	play()

func play_music_level():
	_play_music(level_music)

func play_music_night():
	_play_music(night_music)
