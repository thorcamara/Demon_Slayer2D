extends Control


func _ready():
	$Estrela.hide()
	$Estrela2.hide()
	$Estrela3.hide()
	$Som_estrela.play()
	$Som_musica.play()

func _process(delta: float):
	if Mundo.moedas <= 30:
		$Estrela.show()
	elif Mundo.moedas > 30 and Mundo.moedas <= 60:
		$Estrela.show()
		$Estrela2.show()
	elif Mundo.moedas > 60:
		$Estrela.show()
		$Estrela2.show()
		$Estrela3.show()


func _on_Botao_reiniciar_pressed():
	$Som_pressionou.play()
	yield(get_tree().create_timer(0.5), "timeout")
	if Mundo.level_00 == true:
		get_tree().change_scene("res://Levels/Level_00.tscn")
	elif Mundo.level_01 == true:
		get_tree().change_scene("res://Levels/Level_01.tscn")
	elif Mundo.level_02 == true:
		get_tree().change_scene("res://Levels/Level_02.tscn")


func _on_Botao_sair_pressed():
	$Som_pressionou.play()
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().quit()


func _on_Botao_menu_pressed():
	$Som_pressionou.play()
	yield(get_tree().create_timer(0.5), "timeout")
	if Mundo.level_00 == true:
		Mundo.level_00 = false
	elif Mundo.level_01 == true:
		Mundo.level_01 = false
	elif Mundo.level_02 == true:
		Mundo.level_02 = false
	get_tree().change_scene("res://Telas/Tela_inicial.tscn")
