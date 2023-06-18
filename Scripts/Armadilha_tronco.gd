extends Node2D


func _ready():
	hide()

func tronco_ativado():
	$Som_corda.play()
	$Som_rapido.play()
	show()
	$AnimationPlayer.play("Balancar")
	yield(get_tree().create_timer(3), "timeout")
	print("0.4")
	$AnimationPlayer.playback_speed = 0.4
	yield(get_tree().create_timer(3), "timeout")
	print("0.3")
	$AnimationPlayer.playback_speed = 0.3
	yield(get_tree().create_timer(3), "timeout")
	print("0.2")
	$Som_rapido.max_distance = 250
	$AnimationPlayer.playback_speed = 0.2
	yield(get_tree().create_timer(3), "timeout")
	print("0.1")
	$Som_rapido.max_distance = 75
	$Som_corda.max_distance = 1000
	$AnimationPlayer.playback_speed = 0.1
	yield(get_tree().create_timer(5.73), "timeout")
	$Som_rapido.max_distance = 40
	$Som_corda.max_distance = 500
	print("0.0")
	$AnimationPlayer.playback_speed = 0.0
	yield(get_tree().create_timer(1), "timeout")
	queue_free()

func _on_Detector_body_entered(body):
	if body.is_in_group("jogador"):
		body.sofreu_dano(30)
		
func _on_Armadilha_corda3_JogadorCaiu():
	tronco_ativado()


func _on_Armadilha_corda6_JogadorCaiu():
	tronco_ativado()


func _on_Armadilha_invisivel_JogadorPassou():
	yield(get_tree().create_timer(1), "timeout")
	tronco_ativado()


func _on_Detector_audivel_body_entered(body):
	if body.name == "Jogador":
		$Som_corda.volume_db = 0
		$Som_rapido.volume_db = 0


func _on_Detector_audivel_body_exited(body):
	if body.name == "Jogador":
		$Som_corda.volume_db = -20
		$Som_rapido.volume_db = -20
