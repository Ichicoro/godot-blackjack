extends Control
class_name Card
#signal ready

tool

enum CardSign {
	CLUBS,
	DIAMONDS,
	HEARTS,
	SPADES
}

enum CardType {
	ACE = 1,
	TWO,
	THREE,
	FOUR,
	FIVE,
	SIX,
	SEVEN,
	EIGHT,
	NINE,
	TEN,
	JACK,
	QUEEN,
	KING
}

export(CardType) var card_type: int setget card_type_set, card_type_get
export(CardSign) var card_sign: int setget card_sign_set, card_sign_get


const sign_images = [
	preload("res://assets/card_icons/clubs.png"),
	preload("res://assets/card_icons/diamonds.png"),
	preload("res://assets/card_icons/hearts.png"),
	preload("res://assets/card_icons/spades.png")
]


func init(card_sign: int, card_type: int):
	card_type_set(card_type)
	card_sign_set(card_sign)
	return self


func _ready():
	print(get_children())
	#print("CardSignTexture: ", $CardSignTexture)
	$CardTypeLabel.text = get_type_name(self.card_type)
	$CardSignTexture.texture = get_sign_icon(self.card_sign)
	emit_signal("ready")


static func get_sign_icon(card_sign):
	return sign_images[card_sign]

static func get_type_name(card_type):
	return [
		"1",
		"2",
		"3",
		"4",
		"5",
		"6",
		"7",
		"8",
		"9",
		"10",
		"J",
		"Q",
		"K",
	][card_type-1]

static func get_sign_color(card_sign):
	if card_sign in [CardSign.CLUBS, CardSign.SPADES]:
		return Color(0, 0, 0)
	else:
		return Color(0.674509804, 0.196078431, 0.196078431)


func card_type_set(new_card_type):
	if not Engine.is_editor_hint():
		yield(self, "ready")
	card_type = new_card_type
	$CardTypeLabel.text = get_type_name(self.card_type)

func card_type_get():
	return card_type


func card_sign_set(new_card_sign):
	if not Engine.is_editor_hint():
		yield(self, "ready")
	card_sign = new_card_sign
	$CardSignTexture.texture = get_sign_icon(self.card_sign)
	if card_sign == CardSign.DIAMONDS:
		$CardSignTexture.rect_position = Vector2(9, 15) # was 8
	else:
		$CardSignTexture.rect_position = Vector2(7, 15)
	$CardTypeLabel.add_color_override("font_color", get_sign_color(self.card_sign))

func card_sign_get():
	return card_sign
