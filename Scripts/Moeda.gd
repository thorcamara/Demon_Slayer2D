extends Area2D

var moedas = 1  # Quantidade de moedas que esta área representa

func _ready():
	pass

func _on_Moeda_body_entered(body):
	if body.name == "Jogador":
		$Som_moeda.play()
		hide()
		Mundo.moedas += moedas
		yield($Som_moeda, "finished")
		queue_free()
	# Função chamada quando um corpo rígido entra na área.
	# Verifica se o corpo rígido tem o nome "Jogador".
	# Reproduz o som da moeda, esconde a área (para torná-la invisível), incrementa... 
	# ...o número de moedas na variável "moedas" do script "Mundo", ...
	# ...aguarda o término da reprodução do som antes de liberar o objeto da memória.
