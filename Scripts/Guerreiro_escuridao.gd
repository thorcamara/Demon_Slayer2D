extends KinematicBody2D

# Sinais
signal Guerreiro_trevas_morto  # Sinal emitido quando o guerreiro das trevas morre
signal Retirar_musica  # Sinal emitido para retirar a música

# Variáveis de movimento
var movimento = Vector2(0, 0)
var velocidade_movimento = 100
var gravidade = 10

# Variáveis de vida
var vida = 500.0
var vida_maxima = 500.0
var regen_vida = 2.0

# Sinal emitido quando o status do guerreiro das trevas muda
signal mudar_status_guerreiro_escuridao

# Variáveis de controle do guerreiro das trevas
var sofreu_dano = false
var movendo_para_esquerda = true
var dentro_alcance = false
var morto = false

var quantidade_dano = 10

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
 
func _process(delta: float):
	# Verifica se o guerreiro das trevas está em uma animação que não permite movimento
	if $AnimationPlayer.current_animation in (["Aparecer","Atacar", "Dano", "Morte"]):
		return
		
	mover_inimigo()
	detectar_mudar_direcao()
	esta_dentro_alcance()
	atualizar_barra_vida(delta)

func mover_inimigo():
	# Verifica se o guerreiro das trevas está morto
	if morto:
		return
		
	if !sofreu_dano:
		movimento.x = -velocidade_movimento if movendo_para_esquerda else velocidade_movimento
		movimento.y += gravidade
		$AnimationPlayer.play("Correr")
	
	movimento = move_and_slide(movimento, Vector2.UP)

func detectar_mudar_direcao():
	# Verifica se o guerreiro das trevas colidiu com algum objeto e muda a direção
	if $RayCast2D.is_colliding() and is_on_floor():
		movendo_para_esquerda = !movendo_para_esquerda
		scale.x = -scale.x
	
	if not $RayCast2D2.is_colliding() and is_on_floor():
		movendo_para_esquerda = !movendo_para_esquerda
		scale.x = -scale.x

func correr():
	# Faz o guerreiro das trevas entrar no estado de correr
	if dentro_alcance == false and vida > 0 and !sofreu_dano:
		$AnimationPlayer.play("Correr")

func hit():
	# Ativa o detector de ataque
	$Detector_ataque.monitoring = true

func fim_do_hit():
	# Desativa o detector de ataque
	$Detector_ataque.monitoring = false

func _on_Detector_jogador_body_entered(body):
	esta_dentro_alcance()

func esta_dentro_alcance():
	# Verifica se o jogador está dentro do alcance de ataque
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

func _on_Detector_ataque_body_entered(body):
	# Verifica se o guerreiro das trevas atingiu o jogador
	if body.name == "Jogador":
		body.sofreu_dano(65)

func _on_Hurtbox_area_entered(area):
	# Verifica se o guerreiro das trevas sofreu dano
	var grupos_projetil = {
		"Projetil_habilidade1": 20,
		"Projetil_habilidade3": 40,
		"Projetil_habilidade1_hinokami": 60,
		"Projetil_habilidade3_hinokami": 100,
	}

	if area.name in grupos_projetil:
		sofreu_dano(grupos_projetil[area.name])

func finalizar_inimigo():
	# Finaliza o guerreiro das trevas quando ele morre
	morto = true
	emit_signal("Retirar_musica")
	$Particles2D.emitting = false
	$Detector_jogador.monitoring = false
	$AnimationPlayer.clear_queue()
	$AnimationPlayer.play("Morte")
	yield($AnimationPlayer, "animation_finished")
	emit_signal("Guerreiro_trevas_morto")
	set_process(false)
	queue_free()
	return

func sofreu_dano(quantidade_dano):
	# Aplica dano ao guerreiro das trevas
	if vida > 0:
		$AnimationPlayer.clear_queue()
		$Particles2D.emitting = true
		vida = vida - quantidade_dano
		emit_signal("mudar_status_guerreiro_escuridao", self)
		$AnimationPlayer.play("Dano")
		$Som_dano.play()
		sofreu_dano = true
		yield($AnimationPlayer, "animation_finished")
		$Particles2D.emitting = false
		sofreu_dano = false
	if vida <= 0:
		finalizar_inimigo()
	
func _on_Acionar_JogadorEntrou():
	# Inicia o guerreiro das trevas quando o jogador entra na área de ativação
	show()
	$AnimationPlayer.play("Aparecer")
	$Hurtbox.monitoring = false
	yield(get_tree().create_timer(1), "timeout")
	set_process(true)
	$Hurtbox.monitoring = true
	
	$CollisionShape2D.set_deferred("disabled", false)
	$Hurtbox/CollisionShape2D.set_deferred("disabled", false)
	$Detector_jogador.monitoring = true
	$Detector_jogador/CollisionShape2D.set_deferred("disabled", false)
	$Detector_ataque/CollisionShape2D.set_deferred("disabled", false)

func _on_Jogador_jogador_morto():
	# Para o processamento quando o jogador morre
	set_process(false)
	$AnimationPlayer.play("Aparecer")
	$Som_aparecer.play()

func atualizar_barra_vida(delta: float):
	# Atualiza a barra de vida com base na regeneração de vida
	var nova_vida = min(vida + regen_vida * delta, vida_maxima)
	if nova_vida != vida && vida > 0 && !morto:
		vida = nova_vida
		emit_signal("mudar_status_guerreiro_escuridao", self)
