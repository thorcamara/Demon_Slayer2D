extends KinematicBody2D

# Variáveis de controle de movimento
var movimento = Vector2(0, 0)
var velocidade_movimento = 50
var gravidade = 10

# Variáveis de controle de vida
var vida = 120.0
var vida_maxima = 120.0
var regen_vida = 1.0

# Sinal emitido quando o status do inimigo é alterado
signal mudar_status_slasher

# Variáveis de controle de estado
var sofreu_dano = false
var movendo_para_esquerda = false
var dentro_alcance = false
var morto = false

# Dano causado pelo jogador
var quantidade_dano = 10

func _ready():
	# Inicializa a animação de corrida e define a cor da barra de vida
	$AnimationPlayer.play("Correr")
	$Vida/Barra.color = Color(0.04, 0.50, 0.10, 1)

func _process(delta: float):
	# Verifica o estado atual do inimigo e executa as ações correspondentes
	if $AnimationPlayer.current_animation in (["Atacar", "Dano", "Morte"]):
		return

	mover_inimigo()
	detectar_mudar_direcao()
	esta_dentro_alcance()
	cor_barra()
	atualizar_barra_vida(delta)

func mover_inimigo():
	# Move o inimigo com base no estado atual
	if morto:
		return

	if !sofreu_dano:
		movimento.x = -velocidade_movimento if movendo_para_esquerda else velocidade_movimento
		movimento.y += gravidade
		$AnimationPlayer.play("Correr")

	movimento = move_and_slide(movimento, Vector2.UP)

func detectar_mudar_direcao():
	# Verifica colisões para mudar a direção do inimigo
	if $RayCast2D.is_colliding() and is_on_floor():
		movendo_para_esquerda = !movendo_para_esquerda
		scale.x = -scale.x

	if not $RayCast2D2.is_colliding() and is_on_floor():
		movendo_para_esquerda = !movendo_para_esquerda
		scale.x = -scale.x

func correr():
	# Executa a animação de corrida se o inimigo estiver fora do alcance e com vida
	if dentro_alcance == false and vida > 0 and !sofreu_dano:
		$AnimationPlayer.play("Correr")

func hit():
	# Ativa o monitoramento do detector de ataque
	$Detector_ataque.monitoring = true

func fim_do_hit():
	# Desativa o monitoramento do detector de ataque
	$Detector_ataque.monitoring = false

func _on_Detector_jogador_body_entered(body):
	# Verifica se o jogador entrou no alcance do inimigo
	esta_dentro_alcance()

func esta_dentro_alcance():
	# Verifica se há corpos sobrepostos no detector de jogador
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
	# Verifica se o corpo colidido é o jogador e causa dano a ele
	if body.name == "Jogador":
		body.sofreu_dano(40)

func _on_Hurtbox_area_entered(area):
	# Verifica se a área colidida é um projetil e causa dano ao inimigo
	var grupos_projetil = {
		"Projetil_habilidade1": 20,
		"Projetil_habilidade3": 40,
		"Projetil_habilidade1_hinokami": 60,
		"Projetil_habilidade3_hinokami": 100,
	}

	if area.name in grupos_projetil:
		sofreu_dano(grupos_projetil[area.name])

func finalizar_inimigo():
	# Finaliza o inimigo quando ele está morto
	morto = true
	$Particles2D.emitting = false
	$Detector_jogador.monitoring = false
	$AnimationPlayer.clear_queue()
	$AnimationPlayer.play("Morte")
	$Som_morte.play()
	yield($AnimationPlayer, "animation_finished")
	yield($Som_morte, "finished")
	set_process(false)
	queue_free()
	return

func sofreu_dano(quantidade_dano):
	# Processa o dano recebido pelo inimigo
	if vida > 0:
		$AnimationPlayer.clear_queue()
		$Particles2D.emitting = true
		vida = vida - quantidade_dano
		emit_signal("mudar_status_slasher", self)
		$AnimationPlayer.play("Dano")
		$Som_dano.play()
		sofreu_dano = true
		yield($AnimationPlayer, "animation_finished")
		$Particles2D.emitting = false
		sofreu_dano = false
	if vida <= 0:
		finalizar_inimigo()

func cor_barra():
	# Define a cor da barra de vida com base na quantidade de vida restante
	if $Vida/Barra.rect_size.x <= 28 and $Vida/Barra.rect_size.x >= 14:
		$Vida/Barra.color = Color(0.04, 0.50, 0.10, 1.00)
	elif $Vida/Barra.rect_size.x < 14 and $Vida/Barra.rect_size.x > 7:
		$Vida/Barra.color = Color(1.00, 0.50, 0.10, 1.00)
	elif $Vida/Barra.rect_size.x < 7:
		$Vida/Barra.color = Color(0.76, 0.00, 0.00, 1.00)

func _on_Slasher_mudar_status_slasher(var Slasher):
	# Atualiza o tamanho da barra de vida com base na vida atual do inimigo
	$Vida/Barra.rect_size.x = 28 * Slasher.vida / Slasher.vida_maxima

func atualizar_barra_vida(delta: float):
	# Atualiza a barra de vida com base na regeneração de vida
	var nova_vida = min(vida + regen_vida * delta, vida_maxima)
	if nova_vida != vida && vida > 0 && !morto:
		vida = nova_vida
		emit_signal("mudar_status_slasher", self)

