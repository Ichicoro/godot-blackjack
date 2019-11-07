extends Node

signal credit_changed(new_credit)

var credit = 1000 setget set_credit

func _ready():
	pass

func set_credit(new_credit):
	credit = new_credit
	emit_signal("credit_changed", new_credit)
