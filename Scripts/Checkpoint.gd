extends Area2D


func _ready():
	pass


func _on_Checkpoint_body_entered(body):
	if body.name == "Jogador":
		Mundo.ultima_posicao_checkpoint = global_position
		$Particles2D.emitting = true
		$CollisionShape2D.queue_free()
		$Som_arvore.play()
		yield(get_tree().create_timer(5), "timeout")
		$Particles2D.emitting = false
	
