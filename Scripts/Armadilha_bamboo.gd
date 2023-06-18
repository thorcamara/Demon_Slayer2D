extends Node2D

export var sentido_bamboo = 1

func _ready():
	self.rotation_degrees = 0
	$Detector.monitoring = false
	pass

func _on_Detector_body_entered(body):
	if body.is_in_group("jogador"):
		$Som_bamboo_hit.play()
		body.sofreu_dano(30)

func bamboo_ativado():
	yield(get_tree().create_timer(0.25), "timeout")
	if sentido_bamboo == 1:
		$Detector.monitoring = true
		$AnimationPlayer.play("Balacar_direita")
		$Som_bamboo.play()
		yield($AnimationPlayer, "animation_finished")
		$Detector.monitoring = false
	elif sentido_bamboo == 0:
		$Detector.monitoring = true
		$AnimationPlayer.play("Balacar_esquerda")
		$Som_bamboo.play()
		yield($AnimationPlayer, "animation_finished")
		$Detector.monitoring = false
		
func _on_Armadilha_grama_JogadorPisou():
	print("Executou")
	bamboo_ativado()


func _on_Armadilha_grama2_JogadorPisou():
	print("Executou")
	bamboo_ativado()


func _on_Armadilha_grama3_JogadorPisou():
	print("Executou")
	bamboo_ativado()
