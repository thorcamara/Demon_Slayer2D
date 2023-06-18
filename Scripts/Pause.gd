extends Control



func _process(delta):
	if Input.is_action_just_pressed("t"):
		var novo_pause = not get_tree().paused
		get_tree().paused = novo_pause
		visible = novo_pause


func _on_Botao_resume_pressed() -> void:
	var novo_pause = not get_tree().paused
	get_tree().paused = novo_pause
	visible = novo_pause


func _on_Botao_restart_pressed() -> void:
	var novo_pause = not get_tree().paused
	get_tree().paused = novo_pause
	visible = novo_pause
	get_tree().reload_current_scene()

func _on_Botao_exit_pressed() -> void:
	var novo_pause = not get_tree().paused
	get_tree().paused = novo_pause
	visible = novo_pause
	if Mundo.level_00 == true:
		Mundo.level_00 = false
	elif Mundo.level_01 == true:
		Mundo.level_01 = false
	elif Mundo.level_02 == true:
		Mundo.level_02 = false
	get_tree().change_scene("res://Telas/Tela_inicial.tscn")
