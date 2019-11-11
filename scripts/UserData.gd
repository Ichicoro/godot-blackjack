extends Node

signal credit_changed(new_credit)

var credit = 1000 setget set_credit

func _ready():
	load_data()


func save_data():
	var save_game: File = File.new()
	save_game.open("user://save_data.dat", File.WRITE)
	save_game.seek(0)
	save_game.store_16(credit)
	save_game.close()


func load_data():
	var save_game: File = File.new()
	if not save_game.file_exists("user://save_data.dat"):
		set_credit(1000)
	save_game.open("user://save_data.dat", File.READ)
	save_game.seek(0)
	set_credit(save_game.get_16(), false)
	save_game.close()


func set_credit(new_credit, save = true):
	credit = new_credit
	if save: save_data()
	emit_signal("credit_changed", new_credit)
