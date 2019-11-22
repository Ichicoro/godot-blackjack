extends Control
class_name BackgroundPanel

const colors = [ Color("#2f663d"), Color("#662f2f") ]

enum BackgroundType {
	PLAIN_GREEN,
	PLAIN_RED
}

func _ready():
	UserData.connect("background_changed", self, "handle_bg_changed")
	set_background_type(UserData.chosen_background, true)

func set_color(col: int):
	$Panel.modulate = colors[col]

func set_background_type(type: int, first = false):
	if not first: UserData.chosen_background = type
	if type in [0,1]:
		set_color(type)

func handle_bg_changed(type):
#	return
	set_background_type(type, true)
