extends Control

const CardScene = preload("res://scenes/Card.tscn")

enum Hand {
	PLAYER,
	DEALER
}

enum RoundState {
	BETTING,
	DEALING_INITIAL,
	IDLE,
	DEALING_TO_PLAYER,
	DEALING_TO_DEALER,
	ENDED
}

var deck = []
var round_state: int = RoundState.BETTING

var player_bet: int = 0 setget set_player_bet 

onready var player_hand_container = $DealingPanel/PlayerHandPanel/GridContainer
onready var dealer_hand_container = $DealingPanel/DealerHandPanel/GridContainer
onready var ingame_bet_label = $DealingPanel/IngameBetLabel


func _ready():
	deck = Card.generate_deck()
	
	set_player_bet(500)
	
	deal_card({"card_type": Card.CardType.FIVE, "card_sign": Card.CardSign.HEARTS}, Hand.DEALER)
	
	print("-- player hand value --")
	get_hand_value(Hand.PLAYER)
	
	print("-- dealer hand value --")
	get_hand_value(Hand.DEALER)
#	var card = CardScene.instance().init(Card.CardSign.HEARTS, Card.CardType.FOUR)
#	$HandPanel/GridContainer.add_child(card)


func get_hand_value(whose: int):
	var hand_container: Card = player_hand_container if whose==Hand.PLAYER else dealer_hand_container
	var hand = hand_container.get_children()
	
	var aces = 0
	var total = 0
	for card in hand:
		print(card.card_type)					# TODO: DELETE THIS STUFF
		if card.card_type == Card.CardType.ACE:
			aces += 1
		else:
			total += Card.get_type_value(card.card_type)
	if aces > 1:
		total += aces-1
		aces = 1
	if total > 10:
		total += aces
	else:
		total += aces*11
	
	print("total points: ", total)   			# TODO: DELETE THIS STUFF


func set_player_bet(value):
	if value < 0: return
	player_bet = value
	ingame_bet_label.text = "YOUR BET: $%s" % str(value)
	print(ingame_bet_label.text)


func deal_card(which, to_who: int):
	var hand_container: Card = player_hand_container if to_who==Hand.PLAYER else dealer_hand_container
	var card = CardScene.instance().init(which.card_sign, which.card_type)
	hand_container.add_child(card)
