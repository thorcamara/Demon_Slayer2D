extends KinematicBody2D

# Definição de sinais personalizados
signal Portador_morte_morto
signal Retirar_musica
signal mudar_status_portador_morte

# Variáveis de controle de movimento e física
var movimento = Vector2(0, 0)
var velocidade_movimento = 100
var gravidade = 10

# Variáveis de vida do inimigo
var vida = 2000.0
var vida_maxima = 2000.0
var regen_vida = 2.0

# Variáveis de controle de estado do inimigo
var sofreu_dano = false
var movendo_para_esquerda = true
var dentro_alcance = false
var morto = false

# Variável para definir a quantidade de dano causado pelo jogador
var quantidade_dano = 10

# Método chamado quando o nó é carregado e pronto para uso
func _ready():
	set_process(false)
	hide()
	$CollisionShape2D.set_deferred("disabled", true)
	$Hurtbox.monitoring = false
	$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
	$Detector_jogador.monitoring = false
	$Detector_jogador/CollisionShape2D.set_deferred("disabled", true)
	$Detector_ataque.monitoring = false
	$Detector_ataque/CollisionShape2D.set_deferred("disabled", true)

# Método chamado a cada quadro de atualização do jogo
func _process(delta: float):
	# Verifica se o inimigo está em um estado de animação que não requer atualização
	if $AnimationPlayer.current_animation in (["Aparecer","Atacar", "Dano", "Morte", "Castar_feitico"]):
		return
	
	# Executa as ações do inimigo
	mover_inimigo()
	detectar_mudar_direcao()
	esta_dentro_alcance()
	atualizar_barra_vida(delta)

# Move o inimigo
func mover_inimigo():
	if morto:
		return
	
	# Define o movimento horizontal e vertical do inimigo
	if !sofreu_dano:
		movimento.x = -velocidade_movimento if movendo_para_esquerda else velocidade_movimento
		movimento.y += gravidade
		$AnimationPlayer.play("Correr")
	
	# Move o inimigo de acordo com a física definida
	movimento = move_and_slide(movimento, Vector2.UP)

# Verifica se o inimigo deve mudar a direção de movimento
func detectar_mudar_direcao():
	if $RayCast2D.is_colliding() and is_on_floor():
		movendo_para_esquerda = !movendo_para_esquerda
		scale.x = -scale.x
	
	if not $RayCast2D2.is_colliding() and is_on_floor():
		movendo_para_esquerda = !movendo_para_esquerda
		scale.x = -scale.x

# Executa a animação de corrida do inimigo
func correr():
	if dentro_alcance == false and vida > 0 and !sofreu_dano:
		$AnimationPlayer.play("Correr")

# Inicia a ação de ataque do inimigo
func hit():
	$Detector_ataque.monitoring = true

# Finaliza a ação de ataque do inimigo
func fim_do_hit():
	$Detector_ataque.monitoring = false

# Método chamado quando o corpo do jogador entra no detector de alcance do inimigo
func _on_Detector_jogador_body_entered(body):
	esta_dentro_alcance()

# Verifica se o jogador está dentro do alcance de ataque do inimigo
func esta_dentro_alcance():
	var sobrepondo_corpos = $Detector_jogador.get_overlapping_bodies()
	
	for corpo in sobrepondo_corpos:
		if corpo.name == "Jogador":
			dentro_alcance = true
			if !sofreu_dano:
				$AnimationPlayer.play("Atacar")
				yield($AnimationPlayer, "animation_finished")
			break
		else:
			dentro_alcance = false

# Método chamado quando o corpo do ataque do inimigo entra em colisão com algum outro corpo
func _on_Detector_ataque_body_entered(body):
	if body.name == "Jogador":
		body.sofreu_dano(25)

# Método chamado quando a área de colisão de dano do inimigo é ativada
func _on_Hurtbox_area_entered(area):
	var grupos_projetil = {
		"Projetil_habilidade1": 20,
		"Projetil_habilidade3": 40,
		"Projetil_habilidade1_hinokami": 60,
		"Projetil_habilidade3_hinokami": 100,
	}

	if area.name in grupos_projetil:
		sofreu_dano(grupos_projetil[area.name])

# Finaliza o inimigo, ativando o sinal de morte
func finalizar_inimigo():
	morto = true
	emit_signal("Retirar_musica")
	$Particles2D.emitting = false
	$Detector_jogador.monitoring = false
	$AnimationPlayer.clear_queue()
	$AnimationPlayer.play("Morte")
	$Som_morte.play()
	yield($AnimationPlayer, "animation_finished")
	yield(get_tree().create_timer(3), "timeout")
	emit_signal("Portador_morte_morto")
	set_process(false)
	queue_free()
	return

# Aplica o dano ao inimigo
func sofreu_dano(quantidade_dano):
	if vida > 0:
		$AnimationPlayer.clear_queue()
		$Particles2D.emitting = true
		vida = vida - quantidade_dano
		emit_signal("mudar_status_portador_morte", self)
		$AnimationPlayer.play("Dano")
		$Som_dano.play()
		sofreu_dano = true
		yield($AnimationPlayer, "animation_finished")
		$Particles2D.emitting = false
		sofreu_dano = false
	if vida <= 0:
		finalizar_inimigo()

# Método chamado quando o jogador é ativado no jogo
func _on_Acionar_JogadorEntrou():
	show()
	$Som_aparecer.play()
	$AnimationPlayer.play("Aparecer")
	$Hurtbox.monitoring = false
	yield(get_tree().create_timer(1), "timeout")
	set_process(true)
	$Hurtbox.monitoring = true
	
	$CollisionShape2D.set_deferred("disabled", false)
	$Hurtbox/CollisionShape2D.set_deferred("disabled", false)
	$Detector_jogador.monitoring = true
	$Detector_jogador/CollisionShape2D.set_deferred("disabled", false)
	#$Detector_ataque.monitoring = true
	$Detector_ataque/CollisionShape2D.set_deferred("disabled", false)
	$Cooldown_feitico.start()

# Método chamado quando o jogador é morto
func _on_Jogador_jogador_morto():
	set_process(false)
	$AnimationPlayer.play("Morto")

# Atualiza a barra de vida do inimigo com base na regeneração de vida
func atualizar_barra_vida(delta: float):
	var nova_vida = min(vida + regen_vida * delta, vida_maxima)
	if nova_vida != vida && vida > 0 && !morto:
		vida = nova_vida
		emit_signal("mudar_status_portador_morte", self)

# Método chamado quando o tempo de cooldown do feitiço é concluído
func _on_Cooldown_feitico_timeout():
	if vida > 0 and morto == false:
		$AnimationPlayer.clear_queue()
		$AnimationPlayer.play("Castar_feitico")
		Mundo.castando_feitico = true
