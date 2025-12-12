extends Control

var tween_anim : Tween

func _ready() -> void:
	$Buttons/VSeparator.visible = !(OS.get_name() == "Web")
	$Buttons/BtnQuit.visible = !(OS.get_name() == "Web")
	$Intro.show()
	$Buttons.modulate = Color.TRANSPARENT
	for line in $Intro.get_children():
		line.modulate = Color.TRANSPARENT
	for line in $Intro.get_children():
		tween_anim = create_tween()
		tween_anim.tween_property(line, "modulate", Color.WHITE, 0.2)
		tween_anim.play()
		await tween_anim.finished
		await get_tree().create_timer(0.5).timeout
	tween_anim = create_tween()
	tween_anim.tween_property($Intro, "modulate", Color.TRANSPARENT, 0.2)
	await tween_anim.finished
	$AnimationPlayer.play("intro_slice")
	await $AnimationPlayer.animation_finished


func _on_btn_start_pressed() -> void:
	get_tree().change_scene_to_file("res://main/main_game.tscn")


func _on_btn_quit_pressed() -> void:
	get_tree().quit()
