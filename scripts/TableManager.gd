extends Control

const CardScene = preload("res://scenes/Card.tscn")

var deck = []

var player_hand = []
var dealer_hand = []

enum Hand {
	PLAYER,
	DEALER
}

func _ready():
	pass
	get_hand_value(Hand.PLAYER)
#	var card = CardScene.instance().init(Card.CardSign.HEARTS, Card.CardType.FOUR)
#	$HandPanel/GridContainer.add_child(card)


func get_hand_value(whose: int):
	var hand = player_hand if whose==Hand.PLAYER else dealer_hand
	var aces = 0
	var total = 0
	for card in hand:
		if card.ctype == Card.CardType.ACE:
			aces += 1
		else:
			total += Card.get_type_value(card.ctype)
	if total >= 10:
		total += aces
	else:
		total += aces*10
	
	
