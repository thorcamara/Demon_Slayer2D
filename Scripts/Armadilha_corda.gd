extends Area2D

signal JogadorCaiu

export var visibilidade = 0

func _ready():
	if visibilidade == 0:
		hide()
	elif visibilidade == 1:
		show()

func jogador_caiu():
	$Som_ativada.play()
	emit_signal("JogadorCaiu")
	print("1")
	yield($Som_ativada, "finished")
	queue_free()

func _on_Armadilha_corda_body_entered(body):
	if body.name == "Jogador":
		jogador_caiu()

func _on_Detector_jogador_body_entered(body):
	if body.name == "Jogador":
		show()

