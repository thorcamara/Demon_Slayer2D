extends KinematicBody2D

# Variáveis de movimento
var movimento = Vector2(0, 0)
var velocidade_movimento = 50
var gravidade = 10

# Variáveis de vida
var vida = 400.0
var vida_maxima = 400.0
var regen_vida = 1.0

# Sinal emitido quando o status da minhoca muda
signal mudar_status_minhoca

# Variáveis de controle
var sofreu_dano = false
var movendo_para_esquerda = false
var dentro_alcance = false
var morto = false

# Variáveis de dano
var quantidade_dano = 10
var espinhos_colidindo = false

# Variável de tempo intangível após sofrer dano
var tempo_intangivel = 0.5

# Referência para o recurso da instância de Bola_fogo
onready var bola_fogo_instancia = preload("res://Projeteis/Bola_fogo.tscn")

func _ready():
	# Configura a cor da barra de vida
	$Vida/Barra.color = Color(0.04, 0.50, 0.10, 1)
	
func _process(delta: float):
	# Verifica se tem alguma animação que precisa ser aguardada
	if $AnimationPlayer.current_animation in (["Atacar", "Dano", "Morte"]):
		return
		
	# Atualiza o movimento da minhoca
	mover_inimigo()
	
	# Verifica e muda a direção da minhoca quando necessário
	detectar_mudar_direcao()
	
	# Verifica se o jogador está dentro do alcance de ataque
	esta_dentro_alcance()
	
	# Atualiza a cor da barra de vida
	cor_barra()
	
	# Atualiza a barra de vida ao longo do tempo
	atualizar_barra_vida(delta)
	

func mover_inimigo():
	# Verifica se a minhoca está morta e interrompe o movimento
	if morto:
		return
		
	# Aplica o movimento horizontal à minhoca
	if !sofreu_dano:
		movimento.x = -velocidade_movimento if movendo_para_esquerda else velocidade_movimento
		movimento.y += gravidade
		$AnimationPlayer.play("Andar")
	
	movimento = move_and_slide(movimento, Vector2.UP)

func detectar_mudar_direcao():
	# Verifica se a minhoca colidiu com algum objeto e muda a direção
	if $RayCast2D.is_colliding() and is_on_floor():
		movendo_para_esquerda = !movendo_para_esquerda
		scale.x = -scale.x
		
	if not $RayCast2D2.is_colliding() and is_on_floor():
		movendo_para_esquerda = !movendo_para_esquerda
		scale.x = -scale.x

func andar():
	# Faz a minhoca andar se não estiver dentro do alcance, viva e não tiver sofrido dano
	if dentro_alcance == false and vida > 0 and !sofreu_dano:
		$AnimationPlayer.play("Andar")

func atirou():
	# Desativa o monitoramento do Detector_jogador quando a minhoca atira
	$Detector_jogador.monitoring = false

func terminou_atirar():
	# Reativa o monitoramento do Detector_jogador após a minhoca terminar de atirar
	$Detector_jogador.monitoring = true

func _atirar_bola_fogo():
	# Executa a ação de atirar bola de fogo
	atirou()
	
	# Instancia uma nova bola de fogo e a posiciona
	var bola_fogo = bola_fogo_instancia.instance()
	get_parent().add_child(bola_fogo)
	bola_fogo.global_position = $Position2D.global_position
	
	# Define a direção da bola de fogo com base na direção da minhoca
	if movendo_para_esquerda:
		bola_fogo.set_direcao(-1)
	else:
		bola_fogo.set_direcao(1)

func _on_Detector_jogador_body_entered(body):
	# Verifica se o jogador entrou no alcance da minhoca
	esta_dentro_alcance()

func esta_dentro_alcance():
	# Verifica se a minhoca está dentro do alcance de ataque
	var sobrepondo_corpos = $Detector_jogador.get_overlapping_bodies()
	
	for corpo in sobrepondo_corpos:
		if corpo.name == "Jogador":
			dentro_alcance = true
			
			# Executa a animação de ataque se não tiver sofrido dano
			if !sofreu_dano:
				$AnimationPlayer.play("Atacar")
				yield($AnimationPlayer, "animation_finished")
			
			break
		else:
			dentro_alcance = false

func _on_Hurtbox_area_entered(area):
	# Mapeamento de grupos de projéteis e a quantidade de dano que causam
	var grupos_projetil = {
		"Projetil_habilidade1": 20,
		"Projetil_habilidade3": 40,
		"Projetil_habilidade1_hinokami": 60,
		"Projetil_habilidade3_hinokami": 100,
	}
	
	# Verifica se o projétil pertence a algum grupo e causa dano à minhoca
	if area.name in grupos_projetil:
		sofreu_dano(grupos_projetil[area.name])

func finalizar_inimigo():
	# Executa a sequência de morte da minhoca
	morto = true
	$Particles2D.emitting = false
	$Detector_jogador.monitoring = false
	$Espinhos.monitoring = false
	$AnimationPlayer.clear_queue()
	$AnimationPlayer.play("Morte")
	$Som_morte.play()

	# Aguarda o término da animação de morte e encerra a minhoca
	yield($Som_morte, "finished")
	yield($AnimationPlayer, "animation_finished")
	set_process(false)
	queue_free()

func sofreu_dano(quantidade_dano):
	if vida > 0:
		# Executa a sequência de sofrimento de dano da minhoca
		$AnimationPlayer.clear_queue()
		$Particles2D.emitting = true
		vida = max(vida - quantidade_dano, 0)
		emit_signal("mudar_status_minhoca", self)
		$AnimationPlayer.play("Dano")
		$Som_dano.play()
		sofreu_dano = true
		yield($AnimationPlayer, "animation_finished")
		
		# Desativa a emissão de partículas
		$Particles2D.emitting = false
		sofreu_dano = false
		
	# Verifica se a minhoca ficou sem vida e finaliza a minhoca
	if vida <= 0:
		finalizar_inimigo()

func cor_barra():
	# Atualiza a cor da barra de vida com base no valor atual
	if $Vida/Barra.rect_size.x <= 48 and $Vida/Barra.rect_size.x >= 24:
		$Vida/Barra.color = Color(0.04, 0.50, 0.10, 1.00)
	elif $Vida/Barra.rect_size.x < 24 and $Vida/Barra.rect_size.x > 12:
		$Vida/Barra.color = Color(1.00, 0.50, 0.10, 1.00)
	elif $Vida/Barra.rect_size.x < 12:
		$Vida/Barra.color = Color(0.76, 0.00, 0.00, 1.00)

func _on_Minhoca_fogo_mudar_status_minhoca(var Minhoca):
	# Atualiza o tamanho da barra de vida com base na vida atual da minhoca
	$Vida/Barra.rect_size.x = 48 * Minhoca.vida / Minhoca.vida_maxima

func atualizar_barra_vida(delta: float):
	# Atualiza a barra de vida ao longo do tempo com base na regeneração de vida
	var nova_vida = min(vida + regen_vida * delta, vida_maxima)
	
	# Verifica se houve alteração na vida e emite o sinal de mudança de status da minhoca
	if nova_vida != vida && vida > 0 && !morto:
		vida = nova_vida
		emit_signal("mudar_status_minhoca", self)

func _on_Espinhos_body_entered(body):
	# Verifica se o jogador colidiu com os espinhos
	if body.name == "Jogador":
		espinhos_colidindo = true
		colidiu_espinhos(body)

func _on_Espinhos_body_exited(body):
	# Verifica se o jogador saiu dos espinhos
	if body.name == "Jogador":
		espinhos_colidindo = false

func colidiu_espinhos(body):
	# Verifica se o jogador está colidindo com os espinhos e causa dano
	var sobrepondo_corpos_espinhos = $Espinhos.get_overlapping_bodies()
	
	while espinhos_colidindo == true and sobrepondo_corpos_espinhos:
		if body.name == "Jogador":
			body.sofreu_dano(20)
			$Som_espinhos.play()
			yield(get_tree().create_timer(0.5), "timeout")
		else:
			break
