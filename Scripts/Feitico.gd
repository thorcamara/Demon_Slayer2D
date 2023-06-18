extends Area2D


func _ready():
	pass


func _on_Feitico_body_entered(body):
	if body.is_in_group("jogador"):
		body.sofreu_dano(35)
