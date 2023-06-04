extends Area2D


func _ready():
	pass

func _on_Chegada_body_entered(body):
	if body.name == "Jogador":
		Mundo.ultima_posicao_checkpoint = 0
		$AnimationPlayer.play("Alcancou")
		$Som_chegada.play()
		yield(get_tree().create_timer(1.5), "timeout")
		get_tree().change_scene("res://Scenes/Tela_venceu.tscn")
