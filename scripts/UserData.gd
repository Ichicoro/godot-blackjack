extends Node

signal credit_changed(new_credit)
signal background_changed(type)

var save_version: int = 0

var credit = 1000 setget set_credit
var music_enabled: bool = true setget set_music_enabled
var sounds_enabled: bool = true setget set_sounds_enabled
var chosen_background: int = 0 setget set_chosen_background

func _ready():
	load_data()


func save_data():
	var save_game: File = File.new()
	save_game.open("user://save_data.dat", File.WRITE)
	save_game.seek(0)
	save_game.store_16(save_version)
	save_game.store_16(credit)
	save_game.store_8(music_enabled)
	save_game.store_8(sounds_enabled)
	save_game.store_8(chosen_background)
	save_game.close()


func load_data():
	var save_game: File = File.new()
	if not save_game.file_exists("user://save_data.dat"):
		set_credit(1000)
	save_game.open("user://save_data.dat", File.READ)
	save_game.seek(0)
	set_credit(save_game.get_16(), false)
	music_enabled = save_game.get_8()
	sounds_enabled = save_game.get_8()
	chosen_background = save_game.get_8()
	save_game.close()


func set_credit(new_credit, save = true):
	credit = new_credit
	if save: save_data()
	emit_signal("credit_changed", new_credit)


func set_music_enabled(enabled):
	music_enabled = enabled
	save_data()


func set_sounds_enabled(enabled):
	sounds_enabled = enabled
	save_data()


func set_chosen_background(id):
	chosen_background = id
	save_data()
	emit_signal("background_changed", id)
