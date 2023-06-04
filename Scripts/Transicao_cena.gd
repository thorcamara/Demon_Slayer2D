extends CanvasLayer

func mudar_cena(alvo: String):
	$AnimationPlayer.play("Dissolver")
	yield($AnimationPlayer, "animation_finished")
	get_tree().change_scene(alvo)
	$AnimationPlayer.play_backwards("Dissolver")
