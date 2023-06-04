extends Control


func _ready():
	$Botao_reiniciar.grab_focus()

func _on_Botao_reiniciar_pressed():
	$Som_pressionou.play()
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().change_scene("res://Levels/Level_01.tscn")


func _on_Botao_sair_pressed():
	$Som_pressionou.play()
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().quit()


func _on_Botao_menu_pressed():
	$Som_pressionou.play()
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().change_scene("res://Scenes/Tela_inicial.tscn")
