extends Node2D

@export var die_scene: PackedScene
var dice = []

func _ready():
	pass

# Roll
func _on_roll_dice_button_pressed():
	for die in dice:
		die._roll()
	_roll_dispatch()
	
# Add Dice
func _on_add_die_pressed():
	if $DiceSelect.get_selected_id() > 0:
		_add_die(die_scene.instantiate(),$DiceSelect.get_selected_id())

func _add_die(die, type):
	die.position.y = 280
	die._set_type(type)
	die.index = len(dice)
	dice.append(die)
	add_child(die)
	_roll_dispatch()

# Remove Dice
func _on_remove_dice_button_pressed():
	var dupe_dice = []
	for die in dice:
		if die.selected:
			die.index = len(dupe_dice)
			dupe_dice.append(die)
		else:
			remove_child(die)
	dice = dupe_dice
	_roll_dispatch()

# Fix dice
func _reorder_dice():
	_reset_dice_by_index()
	_align_dice()

func _roll_dispatch():
	_align_dice()
	_calc_total()

func _reset_dice_by_index():
	var dupe_dice = []
	dupe_dice.resize(len(dice))
	for die in dice:
		dupe_dice[die.index] = die
	dice = dupe_dice

func _align_dice():
	for i in range(0,len(dice)):
		dice[i].position = dice[i]._find_position(len(dice))

func _calc_total():
	var total_string = "Total: "
	var total = 0
	for die in dice:
		total += die.score
	total_string += str(total)
	$RollTotal.text = total_string
