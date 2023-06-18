extends Area2D

signal Chegada_02

func _ready():
	pass

func _on_Chegada2_body_entered(body):
	if body.name == "Jogador":
		Mundo.ultima_posicao_checkpoint = 0
		emit_signal("Chegada_02")
		$Som_chegada.play()
		yield(get_tree().create_timer(1.5), "timeout")
		get_tree().change_scene("res://Telas/Tela_vencedor_level_02.tscn")
