extends Control

const RES_INFO_OBJ = preload("res://main/res_info.tscn")

const RULES_TEXT = "I.   [color=red][b]%d[/b][/color] Dice of Fate shall be cast, each result added to the tally of damage.
II.  Should a Die yield a result lower than [color=orange][b]%d[/b][/color], it shall be cast anew [color=yellow][b]%d[/b][/color] times, with the highest result added to the tally of damage.
III. Should a Die yield a result higher than [color=green][b]%d[/b][/color], it shall be cast anew [color=blue][b]%d[/b][/color] times, with each of the results added to the tally of damage.
IV.  For every Die cast, [color=indigo][b]%d[/b][/color] shall be added to the tally of damage.
V.   Thereafter, [color=violet][b]%d[/b][/color] shall be added to the tally of damage.
VI.  Finally, the tally of damage shall be multiplied by [color=gray][b]%d[/b][/color]."
const COUNTDOWN_TEXT = "%d days remain before the arrival of the Destroyer."
const RESULT_TEXT = "Your expedition has yielded the following ores:\n"
const ORE_LIST = [
	"Silver",
	"Gold",
	"Platinum",
	"Tungsten",
	"Palladium",
	"Rhodium",
	"Iridium",
	"Osmium",
]

# Sword params
var dice_amount = 1
var fail_threshold = 0
var fail_reroll_limit = 1
var crit_threshold = 7
var crit_reroll_limit = 1
var per_die_modifier = 0
var final_modifier = 0
var final_multiplier = 1

# Game params
var days_left = 5
var resources = []
var resource_info_list = []
var boss_hp = 1000


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	resources.clear()
	for info in resource_info_list:
		info.queue_free()
	resource_info_list.clear()
	$Main/Info/Content/BtnExpedition.show()
	$Main/Info/Content/BtnNext.hide()
	$Main/Info/Content/BtnBoss.hide()
	$Main/Info/Content/BtnRestart.hide()
	$Main/Info/Content/Rules.text = RULES_TEXT % [
		dice_amount, fail_threshold, fail_reroll_limit, crit_threshold,
		crit_reroll_limit, per_die_modifier,
		final_modifier, final_multiplier,
	]


# For each of the 5 days, roll d20 to see how many materials you gathered. 
# Roll d8 to see each material and its effect
func _on_btn_expedition_pressed() -> void:
	var amount = randi_range(1, 20)
	resources.clear()
	resource_info_list.clear()
	for i in amount:
		var resource = randi_range(0, 7)
		resources.append(resource)
	for i in ORE_LIST.size():
		if resources.count(i) > 0:
			var res_info_inst = RES_INFO_OBJ.instantiate()
			$Main/Resources/Content.add_child(res_info_inst)
			res_info_inst.res_type = i
			res_info_inst.amount = resources.count(i)
			resource_info_list.append(res_info_inst)
	days_left -= 1
	$Main/Info/Content/Countdown.text = COUNTDOWN_TEXT % days_left
	$Main/Info/Content/BtnExpedition.hide()
	$Main/Info/Content/BtnNext.show()


func _on_btn_next_pressed() -> void:
	for resource in resources:
		match resource:
			0: # Silver: +1 to the number of dice rolled
				dice_amount += 1
			1: # Gold: +1 to the critical failure re-roll number
				fail_threshold += 1
				fail_threshold = min(fail_threshold, 6)
			2: # Platinum: +1 to the times you can re-roll new critical failures
				fail_reroll_limit += 1
			3: # Tungsten: -1 to the critical hit target
				crit_threshold -= 1
				crit_threshold = max(crit_threshold, 1)
			4: # Palladium: +1 to the times you can re-roll new critical hits
				crit_reroll_limit += 1
			5: # Rhodium: +2 to the per-die modifier
				per_die_modifier += 2
			6: # Iridium: +10 to the final modifier
				final_modifier += 10
			7: # Osmium: +1 to the multiplier
				final_multiplier += 1
	for info in resource_info_list:
		info.queue_free()
	$Main/Info/Content/Rules.text = RULES_TEXT % [
		dice_amount, fail_threshold, fail_reroll_limit, crit_threshold,
		crit_reroll_limit, per_die_modifier,
		final_modifier, final_multiplier,
	]
	$Main/Info/Content/BtnNext.hide()
	if days_left <= 0:
		$Main/Info/Content/BtnBoss.show()
	else:
		$Main/Info/Content/BtnExpedition.show()

# Ideas
# Randomly generated boss name and form
# Animate the attack, damage calculation as weapon is striking the boss
# Big running total as dice are rolled, crits explode, fails rerolled, etc.
# If boss is killed, finish cut animation
# If boss survives, weapon breaks
# Based on damage amount, zoom out to magical explosion of increasing scale 
func _on_btn_boss_pressed() -> void:
	var damage_amount = 0
	var fail_reroll_count = 0
	var crit_reroll_count = 0
	
	# Roll (dice_amount) d6.
	for i in dice_amount:
		fail_reroll_count = 0
		var die_roll = randi_range(1, 6)
		# Re-roll any (fail_threshold)s or below and keep the higher number (fail_reroll_limit) times.
		if die_roll <= 0:
			while fail_reroll_count < fail_reroll_limit:
				var new_roll = randi_range(1, 6)
				die_roll = max(new_roll, die_roll)
				fail_reroll_count += 1
		# Re-roll any (crit_threshold)s or above and sum the numbers (crit_reroll_limit) times.
		elif die_roll >= crit_threshold:
			while crit_reroll_count < crit_reroll_limit:
				die_roll += randi_range(1, 6)
				crit_reroll_count += 1
		damage_amount += die_roll
		# Add (per_die_bonus) for every die used.
		damage_amount += per_die_modifier
	# Add a final modifier of (final_modifier).
	damage_amount += final_modifier
	# Multiply the total by (final_multiplier) to get your final damage.
	damage_amount *= final_multiplier
	var final_result = "The blade strikes true, inflicting %d HP of damage on the Destroyer!\n" % damage_amount
	if damage_amount >= boss_hp:
		final_result += "The fateful strike fells the Destroyer! The land is saved!"
	else:
		final_result += "The fateful strike fails to slay the Destroyer! The land is doomed!"
	$Main/Info/Content/Countdown.text = final_result
	$Main/Info/Content/BtnBoss.hide()
	$Main/Info/Content/BtnRestart.show()


func _on_btn_restart_pressed() -> void:
	_ready()


func _on_btn_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://title/title.tscn")
