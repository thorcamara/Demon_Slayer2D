extends Area2D

var moedas = 1

func _ready():
	pass

func _on_Moeda_body_entered(body):
	if body.name == "Jogador":
		$Som_moeda.play()
		hide()
		Mundo.moedas += moedas 
		
		yield($Som_moeda, "finished")
		queue_free()
