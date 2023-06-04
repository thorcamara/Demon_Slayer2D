extends Control


func _ready():
	yield(get_tree().create_timer(5), "timeout")
	$Botao_skip.grab_focus()
	$Som_intro.play()
	yield($Som_intro, "finished")
	get_tree().change_scene("res://Scenes/Tela_inicial.tscn")



func _on_Botao_skip_pressed():
	$Som_intro.stop()
	$Som_pressionou.play()
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().change_scene("res://Scenes/Tela_inicial.tscn")
