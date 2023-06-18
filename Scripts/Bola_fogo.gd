extends Area2D

var velocidade_projetil = 300  # Velocidade do projetil

var movimento_projetil = Vector2.ZERO  # Vetor de movimento do projetil
var direcao = 1  # Direção do projetil (-1 para esquerda, 1 para direita)

func _ready():
	pass

func set_direcao(dir):
	direcao = dir
	# Define a direção do projetil e atualiza a orientação do Sprite e Particles2D
	if direcao == 1:
		$Sprite.flip_h = false
	else:
		$Sprite.flip_h = true
		$Particles2D.scale.x = -$Particles2D.scale.x
		$Particles2D.position.x = -$Particles2D.position.x
		# Inverte a escala e posição das partículas caso a direção seja para a esquerda.

func _physics_process(delta: float):
	movimento_projetil.x = velocidade_projetil * delta * direcao
	translate(movimento_projetil)
	# Atualiza o movimento do projetil multiplicando a velocidade pela direção e o tempo.

	som_diminuindo()
	# Chama a função para diminuir o volume do som do projetil.

func som_diminuindo():
	yield(get_tree().create_timer(0.5), "timeout")
	$Som_bola_de_fogo.volume_db = -5
	yield(get_tree().create_timer(0.5), "timeout")
	$Som_bola_de_fogo.volume_db = -10
	yield(get_tree().create_timer(0.5), "timeout")
	$Som_bola_de_fogo.volume_db = -15
	yield(get_tree().create_timer(0.5), "timeout")
	$Som_bola_de_fogo.volume_db = -20
	# Função para diminuir gradualmente o volume do som do projetil.
	# Utiliza yield para pausar a execução por um determinado tempo antes de diminuir o volume.

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	# Função chamada quando o projetil sai da tela.
	# Libera o objeto da memória.

func _on_Bola_fogo_area_entered(area):
	if area.is_in_group("projeteis") or area.is_in_group("espada"):
		print("Bola de Fogo causou dano")
		$Particles2D.queue_free()
		$AnimationPlayer.play("Colidiu")
		$Som_colisao.play()
		velocidade_projetil = 0
		$CollisionShape2D.set_deferred("disabled", true)
		yield($AnimationPlayer, "animation_finished")
		queue_free()
	# Função chamada quando o projetil colide com uma área.
	# Verifica se a área pertence aos grupos "projeteis" ou "espada".
	# Imprime uma mensagem de colisão, libera as partículas, reproduz a animação de colisão,
	# reproduz o som de colisão, para o movimento do projetil e desativa a forma de colisão.
	# Aguarda o término da animação antes de liberar o objeto da memória.

func _on_Bola_fogo_body_entered(body):
	if body.name == "Jogador":
		print("Bola de Fogo causou dano")
		$Particles2D.queue_free()
		$AnimationPlayer.play("Colidiu")
		#$Som_bomba.play()
		velocidade_projetil = 0
		body.sofreu_dano(30)
		$CollisionShape2D.set_deferred("disabled", true)
		yield($AnimationPlayer, "animation_finished")
		queue_free()
	# Função chamada quando o projetil colide com um corpo rígido.
	# Verifica se o corpo rígido tem o nome "Jogador".
	# Imprime uma mensagem de colisão, libera as partículas, reproduz a animação de colisão,
	# para o movimento do projetil, causa dano ao jogador, desativa a forma de colisão.
	# Aguarda o término da animação antes de liberar o objeto da memória.
