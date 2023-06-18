extends Area2D

signal JogadorPisou

func _ready():
	pass

func _on_Armadilha_grama_body_entered(body):
	if body.name == "Jogador":
		print("Pisou")
		$Som_pisou.play()
		emit_signal("JogadorPisou")
