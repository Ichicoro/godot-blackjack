extends Control

const CardScene = preload("res://scenes/Card.tscn")
const BettingButton = preload("res://scenes/BettingButton.tscn")

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
var round_state: int = RoundState.BETTING setget set_round_state

var player_bet: int = 0 setget set_player_bet 

onready var player_hand_container = $DealingPanel/PlayerHandPanel/GridContainer
onready var dealer_hand_container = $DealingPanel/DealerHandPanel/GridContainer
onready var ingame_bet_label = $DealingPanel/IngameBetLabel

onready var raise_buttons_container = $BettingPanel/RaiseButtonsContainer
onready var lower_buttons_container = $BettingPanel/LowerButtonsContainer
onready var betting_panel_bet_amount_label = $BettingPanel/BetAmount
onready var place_bet_button = $BettingPanel/PlaceBetButton


func _ready():
	# Setup deck
	deck = Card.generate_deck()
	
	# Set round state
	set_round_state(RoundState.BETTING)
	
	# Setup betting UI
	for child in raise_buttons_container.get_children():
		child.queue_free()
	for child in lower_buttons_container.get_children():
		child.queue_free()
	for i in [1, 10, 25, 100]:
		var btn = BettingButton.instance()
		btn.text = "+" + str(i)
		btn.connect("pressed_betting_button", self, "handle_bet_button")
		raise_buttons_container.add_child(btn)
		
		btn = BettingButton.instance()
		btn.text = "-" + str(i)
		btn.connect("pressed_betting_button", self, "handle_bet_button")
		lower_buttons_container.add_child(btn)
	
	update_button_states()
#	deal_card({"card_type": Card.CardType.FIVE, "card_sign": Card.CardSign.HEARTS}, Hand.DEALER)


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
	betting_panel_bet_amount_label.text = "$%s" % value
	print(ingame_bet_label.text)


func set_round_state(state):
	round_state = state
	if round_state == RoundState.IDLE:
		pass


func deal_card(which, to_who: int, flipped = false):
	var hand_container: Card = player_hand_container if to_who==Hand.PLAYER else dealer_hand_container
	var card = CardScene.instance().init(Card.CardSign[which.card_sign], Card.CardType[which.card_type])
	card.flipped = flipped
	hand_container.add_child(card)


func handle_bet_button(amount):
	set_player_bet(player_bet + amount)
	#UserData.credit -= amount
	update_button_states()


func update_button_states():
	place_bet_button.disabled = (player_bet == 0)
	for button in raise_buttons_container.get_children():
		button.disabled = (int(button.text)+player_bet > UserData.credit)
	for button in lower_buttons_container.get_children():
		button.disabled = (UserData.credit - (player_bet+int(button.text)) < 0)


func _on_PlaceBetButton_pressed():
	UserData.credit -= player_bet
	start_round()


func start_round():
	$BettingPanel.hide()
	$DealingPanel.show()
	set_round_state(RoundState.DEALING_INITIAL)
	yield(get_tree().create_timer(0.5), "timeout")
	
	# Deal cards
	deal_card(deck.pop_front(), Hand.PLAYER)
	yield(get_tree().create_timer(0.5), "timeout")
	deal_card(deck.pop_front(), Hand.PLAYER)
	yield(get_tree().create_timer(0.5), "timeout")
	deal_card(deck.pop_front(), Hand.DEALER)
	yield(get_tree().create_timer(0.5), "timeout")
	deal_card(deck.pop_front(), Hand.DEALER, true)
	
	# Wait for the player
	set_round_state(RoundState.IDLE)
