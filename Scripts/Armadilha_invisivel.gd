extends Area2D

signal JogadorPassou

func _ready():
	pass


func _on_Armadilha_invisivel_body_entered(body):
	if body.name == "Jogador":
			emit_signal("JogadorPassou")
			queue_free()
