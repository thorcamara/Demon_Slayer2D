extends Control


func _ready():
	pass


func _on_Botao_retornar_pressed():
	$Som_pressionou.play()
	yield(get_tree().create_timer(0.5), "timeout")
	queue_free()
#	Mundo.controle_desligado = false
	get_tree().change_scene("res://Telas/Tela_inicial.tscn")
