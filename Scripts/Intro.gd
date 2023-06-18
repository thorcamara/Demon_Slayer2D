extends Control


func _ready():
	$Som_intro.play()
	yield($Som_intro, "finished")
	get_tree().change_scene("res://Telas/Tela_inicial.tscn")



func _on_Botao_skip_pressed():
	$Som_intro.stop()
	$Som_pressionou.play()
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().change_scene("res://Telas/Tela_inicial.tscn")
