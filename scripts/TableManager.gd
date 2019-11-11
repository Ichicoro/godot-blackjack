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

onready var dealer_label = $Dealer/DealerText

onready var player_hand_container = $DealingPanel/PlayerHandPanel/GridContainer
onready var dealer_hand_container = $DealingPanel/DealerHandPanel/GridContainer
onready var ingame_bet_label = $DealingPanel/IngameBetLabel
onready var hit_button = $DealingPanel/HitButton
onready var stand_button = $DealingPanel/StandButton

onready var raise_buttons_container = $BettingPanel/RaiseButtonsContainer
onready var lower_buttons_container = $BettingPanel/LowerButtonsContainer
onready var betting_panel_bet_amount_label = $BettingPanel/BetAmount
onready var place_bet_button = $BettingPanel/PlaceBetButton


func _ready():
	$DealingPanel.hide()
	$BettingPanel.show()
	$DealingPanel/PlayerHandTotal.text = ""
	$DealingPanel/DealerHandTotal.text = ""
	
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
	return total

func set_player_bet(value):
	if value < 0: return
	player_bet = value
	ingame_bet_label.text = "YOUR BET: $%s" % str(value)
	betting_panel_bet_amount_label.text = "$%s" % value
	#print(ingame_bet_label.text)


func set_round_state(state):
	round_state = state
	if round_state == RoundState.IDLE:
		hit_button.disabled = false
		stand_button.disabled = false
	else:
		hit_button.disabled = true
		stand_button.disabled = true
	if round_state == RoundState.ENDED:
		hit_button.hide()
		stand_button.hide()
		$DealingPanel/EndRoundButton.show()
	else:
		hit_button.show()
		stand_button.show()
		$DealingPanel/EndRoundButton.hide()


func deal_card(which, to_who: int, flipped = false):
	var hand_container: Card = player_hand_container if to_who==Hand.PLAYER else dealer_hand_container
	var card = CardScene.instance().init(Card.CardSign[which.card_sign], Card.CardType[which.card_type])
	card.flipped = flipped
	hand_container.add_child(card)
	if to_who == Hand.PLAYER:
		var total_label = $DealingPanel/PlayerHandTotal
		total_label.text = "TOTAL = %s" % str(get_hand_value(to_who))
	else:
		var total_label = $DealingPanel/DealerHandTotal
		var thing = str(get_hand_value(to_who))
		if len(dealer_hand_container.get_children()) <= 2:
			thing = "?"
		total_label.text = "TOTAL = %s" % thing


func handle_bet_button(amount):
	set_player_bet(player_bet + amount)
	#UserData.credit -= amount
	update_button_states()


func update_button_states():
	place_bet_button.disabled = (player_bet == 0)
	for button in raise_buttons_container.get_children():
		button.disabled = (int(button.text)+player_bet > UserData.credit)
	for button in lower_buttons_container.get_children():
		button.disabled = (player_bet + int(button.text)) < 0


func _on_PlaceBetButton_pressed():
	UserData.credit -= player_bet
	start_round()


func check_cards():
	if round_state == RoundState.DEALING_TO_PLAYER:
		var hand_value = get_hand_value(Hand.PLAYER)
		if hand_value > 21:
			set_round_state(RoundState.ENDED)
			dealer_label.set_text("Too bad! You've gone over.")
		elif hand_value == 21:
			dealer_label.set_text("Nice! A blackjack!")
			UserData.credit += player_bet*2
			set_round_state(RoundState.ENDED)
		else:
			set_round_state(RoundState.IDLE)
	elif round_state == RoundState.DEALING_TO_DEALER:
		set_round_state(RoundState.ENDED)
		var hand_value = get_hand_value(Hand.DEALER)
		if hand_value > 21:
			dealer_label.set_text("Aw, too bad. I busted...")
			UserData.credit += player_bet*2
		else:
			if get_hand_value(Hand.PLAYER) > hand_value:
				dealer_label.set_text("Nice job! You've won $%d" % player_bet)
				UserData.credit += player_bet*2
			elif get_hand_value(Hand.PLAYER) == hand_value:
				dealer_label.set_text("And.. it's a DRAW!")
				UserData.credit += player_bet
			else:
				dealer_label.set_text("You've lost! I AM ZE BEST :>")
	return round_state == RoundState.ENDED


func start_round():
	$BettingPanel.hide()
	$DealingPanel.show()
	set_round_state(RoundState.DEALING_INITIAL)
	yield(get_tree().create_timer(0.5), "timeout")
	
	# Deal cards
	deal_card(deck.pop_front(), Hand.PLAYER)
#	deal_card({"card_type": 2, "card_sign": 2}, Hand.PLAYER)
	yield(get_tree().create_timer(0.5), "timeout")
	deal_card(deck.pop_front(), Hand.PLAYER)
#	deal_card({"card_type": 2, "card_sign": 1}, Hand.PLAYER)
	yield(get_tree().create_timer(0.5), "timeout")
	deal_card(deck.pop_front(), Hand.DEALER)
	yield(get_tree().create_timer(0.5), "timeout")
	deal_card(deck.pop_front(), Hand.DEALER, true)
	
#	var hand_value = get_hand_value(Hand.PLAYER)
#	$DealingPanel/PlayerHandTotal.text = "TOTAL = %d" % hand_value
	
	# Wait for the player
	set_round_state(RoundState.IDLE)



func reset_state():
	# Setup deck
	deck = Card.generate_deck()
	
	# Set round state
	set_round_state(RoundState.BETTING)
	
	dealer_label.set_text("Wanna play again? Place a bet.")
	
	# Reset bets and stuff
	set_player_bet(0)
	update_button_states()
	
	$DealingPanel/PlayerHandTotal.text = ""
	$DealingPanel/DealerHandTotal.text = ""
	
	for card in player_hand_container.get_children():
		card.queue_free()
	for card in dealer_hand_container.get_children():
		card.queue_free()
	
	$DealingPanel.hide()
	$BettingPanel.show()



### DEALING PANEL HANDLERS ###

func _on_HitButton_pressed():
	set_round_state(RoundState.DEALING_TO_PLAYER)
	yield(get_tree().create_timer(0.3), "timeout")
	deal_card(deck.pop_front(), Hand.PLAYER)
	yield(get_tree().create_timer(0.3), "timeout")
	dealer_label.set_text("Dealt " + player_hand_container.get_children()[-1].get_card_name())
	check_cards()


func _on_StandButton_pressed():
	if check_cards(): return							### FIXME
	yield(get_tree().create_timer(0.3), "timeout")
	dealer_hand_container.get_children()[1].flipped = false
	$DealingPanel/DealerHandTotal.text = "TOTAL = %s" % str(get_hand_value(Hand.DEALER))
	
	set_round_state(RoundState.DEALING_TO_DEALER)
	while (get_hand_value(Hand.DEALER) < 15) or (get_hand_value(Hand.DEALER) < get_hand_value(Hand.PLAYER) and get_hand_value(Hand.DEALER)<19):
		yield(get_tree().create_timer(0.75), "timeout")
		deal_card(deck.pop_front(), Hand.DEALER)
	
	yield(get_tree().create_timer(0.3), "timeout")
	check_cards()


func _on_EndRoundButton_pressed():
	reset_state()


func _on_TopBar_quit_pressed():
	yield(get_tree().create_timer(0.3), "timeout")
	get_tree().change_scene("res://scenes/MainMenu.tscn")
