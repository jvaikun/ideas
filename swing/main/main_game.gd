extends Control

const RES_INFO_OBJ = preload("res://main/res_info.tscn")
const COLLECT_OBJ = preload("res://main/res_collect.tscn")
const DICE_OBJ = preload("res://main/dice_roll.tscn")
const HP_MAX = 1000

signal resources_collected

@onready var dice_container = $Boss/Attacks/Damage/Dice
@onready var prop_list = [
	[$Main/Content/Rules/Rule1/Num1, Color.RED, "dice_amount"],
	[$Main/Content/Rules/Rule2/Num2, Color.ORANGE, "fail_threshold"],
	[$Main/Content/Rules/Rule2/Num3, Color.YELLOW, "fail_reroll_limit"],
	[$Main/Content/Rules/Rule3/Num4, Color.GREEN, "crit_threshold"],
	[$Main/Content/Rules/Rule3/Num5, Color.BLUE, "crit_reroll_limit"],
	[$Main/Content/Rules/Rule4/Num6, Color.INDIGO, "per_die_modifier"],
	[$Main/Content/Rules/Rule5/Num7, Color.VIOLET, "final_modifier"],
	[$Main/Content/Rules/Rule6/Num8, Color.GRAY, "final_multiplier"],
]
@onready var msg_list = [
	[$Boss/Attacks/Messages/Rule1/Num1, Color.RED, "dice_amount"],
	[$Boss/Attacks/Messages/Rule2/Num2, Color.ORANGE, "fail_threshold"],
	[$Boss/Attacks/Messages/Rule2/Num3, Color.YELLOW, "fail_reroll_limit"],
	[$Boss/Attacks/Messages/Rule3/Num4, Color.GREEN, "crit_threshold"],
	[$Boss/Attacks/Messages/Rule3/Num5, Color.BLUE, "crit_reroll_limit"],
	[$Boss/Attacks/Messages/Rule4/Num6, Color.INDIGO, "per_die_modifier"],
	[$Boss/Attacks/Messages/Rule5/Num7, Color.VIOLET, "final_modifier"],
	[$Boss/Attacks/Messages/Rule6/Num8, Color.GRAY, "final_multiplier"],
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
var resource_collect_list = []
var boss_hp : int = HP_MAX

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	resources.clear()
	resource_info_list.clear()
	$Boss.modulate = Color.TRANSPARENT
	$Boss/Attacks/Messages/Result.modulate = Color.TRANSPARENT
	$Boss.hide()
	$Main.modulate = Color.WHITE
	$Main.show()
	$Boss/Info/BossHP.max_value = HP_MAX
	$Boss/Info/BossHP.value = HP_MAX
	$Main/Content/Buttons/BtnExpedition.show()
	$Main/Content/Buttons/BtnBoss.hide()
	_update_rules()


func _update_rules():
	for property in prop_list:
		var this_prop = property[0]
		this_prop.modulate = property[1]
		this_prop.text = str(get(property[2]))
	for message in msg_list:
		var this_msg = message[0]
		this_msg.modulate = message[1]
		this_msg.text = str(get(message[2]))


func _change_message(index):
	var tween_change = create_tween()
	tween_change.parallel()
	for i in $Boss/Attacks/Messages.get_child_count():
		if i == index:
			tween_change.tween_property($Boss/Attacks/Messages.get_child(i), "modulate", Color.WHITE, 0.1)
		else:
			tween_change.tween_property($Boss/Attacks/Messages.get_child(i), "modulate", Color.TRANSPARENT, 0.1)
	tween_change.play()


func _target_reached(effect, info):
	match info.res_type:
		0: # Silver: +1 to the number of dice rolled
			dice_amount += info.amount
		1: # Gold: +1 to the critical failure re-roll number
			fail_threshold += info.amount
			fail_threshold = min(fail_threshold, 6)
		2: # Platinum: +1 to the times you can re-roll new critical failures
			fail_reroll_limit += info.amount
		3: # Tungsten: -1 to the critical hit target
			crit_threshold -= info.amount
			crit_threshold = max(crit_threshold, 1)
		4: # Palladium: +1 to the times you can re-roll new critical hits
			crit_reroll_limit += info.amount
		5: # Rhodium: +2 to the per-die modifier
			per_die_modifier += 2 * info.amount
		6: # Iridium: +10 to the final modifier
			final_modifier += 10 * info.amount
		7: # Osmium: +1 to the multiplier
			final_multiplier += info.amount
	var this_prop = prop_list[info.res_type]
	this_prop[0].text = str(get(this_prop[2]))
	effect.queue_free()
	await get_tree().create_timer(0.1).timeout
	for collect in resource_collect_list:
		if is_instance_valid(collect):
			return
	resources_collected.emit()


# For each of the 5 days, roll d20 to see how many materials you gathered. 
# Roll d8 to see each material and its effect
func _on_btn_expedition_pressed() -> void:
	for info in resource_info_list:
		info.queue_free()
	resource_info_list.clear()
	resources.clear()
	var amount = randi_range(1, 20)
	for i in amount:
		var resource = randi_range(0, 7)
		resources.append(resource)
	for i in prop_list.size():
		if resources.count(i) > 0:
			var res_info_inst = RES_INFO_OBJ.instantiate()
			$Main/Content/Resources/Body/ResList.add_child(res_info_inst)
			res_info_inst.res_type = i
			res_info_inst.amount = resources.count(i)
			resource_info_list.append(res_info_inst)
	$Main/Content/Buttons.hide()
	$Main/Content/Resources.show()


func _on_btn_continue_pressed() -> void:
	resource_collect_list.clear()
	for info in resource_info_list:
		var collect_inst = COLLECT_OBJ.instantiate()
		add_child(collect_inst)
		collect_inst.global_position = info.global_position
		collect_inst.modulate = prop_list[info.res_type][1]
		resource_collect_list.append(collect_inst)
		var target_pos = prop_list[info.res_type][0].global_position + Vector2(32, 32)
		var move_time = target_pos.distance_to(info.global_position) / 480
		var tween_move = create_tween()
		tween_move.tween_property(collect_inst, "global_position", target_pos, move_time)
		tween_move.tween_callback(_target_reached.bind(collect_inst, info))
		tween_move.play()
	$Main/Content/Resources.hide()
	await resources_collected
	days_left -= 1
	if days_left <= 0:
		$Main/Content/Countdown.text = "The Destroyer has come! Bring forth the Fated Blade!"
		$Main/Content/Buttons/BtnExpedition.hide()
		$Main/Content/Buttons/BtnBoss.show()
	elif days_left == 1:
		$Main/Content/Countdown.text = "1 day remains before the arrival of the Destroyer."
		$Main/Content/Buttons/BtnExpedition.show()
	else:
		$Main/Content/Countdown.text = "%d days remain before the arrival of the Destroyer." % days_left
		$Main/Content/Buttons/BtnExpedition.show()
	$Main/Content/Buttons.show()


# Randomly generated boss name and form
# Animate the attack, damage calculation as weapon is striking the boss
# Big running total as dice are rolled, crits explode, fails rerolled, etc.
# If boss is killed, finish cut animation
# If boss survives, weapon breaks
# Based on damage amount, zoom out to magical explosion of increasing scale 
func _on_btn_boss_pressed() -> void:
	_update_rules()
	$Boss/Buttons/BtnRestart.hide()
	$Boss/Buttons/BtnQuit.hide()
	$Boss/Buttons/BtnNext.hide()
	$Boss.show()
	var tween_fade = create_tween()
	tween_fade.tween_property($Main, "modulate", Color.TRANSPARENT, 0.5)
	tween_fade.tween_property($Boss, "modulate", Color.WHITE, 0.5)
	tween_fade.play()
	await tween_fade.finished
	$Main.hide()
	var dice_rolls = []
	var crit_indices = []
	var fail_indices = []
	var crit_reroll_count = 0
	var fail_reroll_count = 0
	var damage_amount = 0
	$Boss/Buttons/BtnNext.show()
	await $Boss/Buttons/BtnNext.pressed
	$Boss/Buttons/BtnNext.hide()
	# Roll (dice_amount) d6.
	for i in dice_amount:
		dice_rolls.append(randi_range(1,6))
		var dice_inst = DICE_OBJ.instantiate()
		dice_container.add_child(dice_inst)
		dice_inst.text = str(dice_rolls[-1])
		if dice_rolls[-1] <= fail_threshold:
			fail_indices.append(i)
		elif dice_rolls[-1] > crit_threshold:
			crit_indices.append(i)
		await get_tree().create_timer(0.1).timeout
	_change_message(1)
	$Boss/Buttons/BtnNext.show()
	await $Boss/Buttons/BtnNext.pressed
	$Boss/Buttons/BtnNext.hide()
	# Re-roll any (fail_threshold)s or below and keep the higher number (fail_reroll_limit) times.
	for index in fail_indices:
		fail_reroll_count = 0
		while fail_reroll_count < fail_reroll_limit:
			var new_roll = randi_range(1, 6)
			dice_rolls[index] = max(new_roll, dice_rolls[index])
			fail_reroll_count += 1
		dice_container.get_child(index).text = str(dice_rolls[index])
		await get_tree().create_timer(0.1).timeout
	_change_message(2)
	$Boss/Buttons/BtnNext.show()
	await $Boss/Buttons/BtnNext.pressed
	$Boss/Buttons/BtnNext.hide()
	# Re-roll any (crit_threshold)s or above and sum the numbers (crit_reroll_limit) times.
	for index in crit_indices:
		crit_reroll_count = 0
		while crit_reroll_count < crit_reroll_limit:
			dice_rolls[index] += randi_range(1, 6)
			crit_reroll_count += 1
		dice_container.get_child(index).text = str(dice_rolls[index])
		await get_tree().create_timer(0.1).timeout
	_change_message(3)
	$Boss/Buttons/BtnNext.show()
	await $Boss/Buttons/BtnNext.pressed
	$Boss/Buttons/BtnNext.hide()
	# Add (per_die_bonus) for every die used.
	for i in dice_amount:
		dice_rolls[i] += per_die_modifier
		damage_amount += dice_rolls[i]
		dice_container.get_child(i).text = str(dice_rolls[i])
		await get_tree().create_timer(0.1).timeout
	var tween_merge = create_tween()
	tween_merge.tween_property(dice_container, "theme_override_constants/separation", -64, 1.0)
	tween_merge.play()
	await tween_merge.finished
	dice_container.hide()
	$Boss/Attacks/Damage/Total.text = str(damage_amount)
	$Boss/Attacks/Damage/Total.show()
	_change_message(4)
	$Boss/Buttons/BtnNext.show()
	await $Boss/Buttons/BtnNext.pressed
	$Boss/Buttons/BtnNext.hide()
	# Add a final modifier of (final_modifier).
	damage_amount += final_modifier
	$Boss/Attacks/Damage/Total.text = str(damage_amount)
	_change_message(5)
	$Boss/Buttons/BtnNext.show()
	await $Boss/Buttons/BtnNext.pressed
	$Boss/Buttons/BtnNext.hide()
	# Multiply the total by (final_multiplier) to get your final damage.
	damage_amount *= final_multiplier
	$Boss/Attacks/Damage/Total.text = str(damage_amount)
	boss_hp -= damage_amount
	var tween_damage = create_tween()
	tween_damage.tween_property($Boss/Info/BossHP, "value", boss_hp, 1.0)
	tween_damage.play()
	await tween_damage.finished
	var final_result = "The blade strikes true, inflicting %d HP of damage on the Destroyer!\n" % damage_amount
	if boss_hp <= 0:
		final_result += "The fateful strike fells the Destroyer! The land is saved!"
	else:
		final_result += "The fateful strike fails to slay the Destroyer! The land is doomed!"
	$Boss/Attacks/Messages/Result.text = final_result
	_change_message(6)
	$Boss/Buttons/BtnRestart.show()
	$Boss/Buttons/BtnQuit.show()


func _on_btn_restart_pressed() -> void:
	get_tree().reload_current_scene()


func _on_btn_next_pressed() -> void:
	pass # Replace with function body.


func _on_btn_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://title/title.tscn")
