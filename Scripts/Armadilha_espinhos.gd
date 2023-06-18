extends Area2D

var espinhos_colidindo

var som_tocado = false

func _ready():
	pass

func _on_Armadilha_grama5_JogadorPisou():
	$AnimationPlayer.play("Ativar")
	if som_tocado == false:
		$Som_espinhos.play()
		som_tocado = true
	yield($AnimationPlayer, "animation_finished")
	$AnimationPlayer.play("Ativada")


func _on_Armadilha_espinhos_body_entered(body):
	if body.name == "Jogador":
		espinhos_colidindo = true
		colidiu_espinhos(body)
		


func _on_Armadilha_espinhos_body_exited(body):
	if body.name == "Jogador":
		espinhos_colidindo = false


func colidiu_espinhos(body):
	var sobrepondo_corpos_espinhos = self.get_overlapping_bodies()
	
	while espinhos_colidindo == true and sobrepondo_corpos_espinhos:
		if body.name == "Jogador":
			body.sofreu_dano(30)
			yield(get_tree().create_timer(0.5), "timeout")
		else:
			break
