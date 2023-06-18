extends Control


func _ready() -> void:
	pass


func _on_Botao_retornar_pressed() -> void:
	$Som_pressionou.play()
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().change_scene("res://Telas/Tela_inicial.tscn")
