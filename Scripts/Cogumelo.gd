extends KinematicBody2D

# Variáveis do movimento
var movimento = Vector2(0, 0)
var velocidade_movimento = 50
var gravidade = 10

# Variáveis de vida
var vida = 120.0
var vida_maxima = 120.0
var regen_vida = 1.0

# Sinal para atualizar o status do cogumelo
signal mudar_status_cogumelo

# Variáveis de estado
var sofreu_dano = false
var movendo_para_esquerda = true
var morto = false
var dentro_alcance = false

# Quantidade de dano sofrido
var quantidade_dano = 10

func _ready():
	# Inicializa a animação de corrida e a cor da barra de vida
	$AnimationPlayer.play("Correr")
	$Vida/Barra.color = Color(0.04, 0.50, 0.10, 1)
 
func _process(delta: float):
	# Verifica se o cogumelo está executando uma animação que não permite a atualização do processo
	if $AnimationPlayer.current_animation in (["Atacar", "Dano", "Morte"]):
		return
	
	# Atualiza o movimento, direção, alcance e barra de vida
	mover_inimigo()
	detectar_mudar_direcao()
	esta_dentro_alcance()
	cor_barra()
	atualizar_barra_vida(delta)

func finalizar_inimigo():
	# Executa o estado de morte
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
	
func mover_inimigo():
	# Verifica se o cogumelo está morto
	if morto:
		return
		
	# Atualiza o movimento de acordo com a direção e a gravidade
	if !sofreu_dano:
		movimento.x = -velocidade_movimento if movendo_para_esquerda else velocidade_movimento
		movimento.y += gravidade
		$AnimationPlayer.play("Correr")
	
	# Move o cogumelo e lida com colisões
	movimento = move_and_slide(movimento, Vector2.UP)

func detectar_mudar_direcao():
	# Verifica colisões e muda a direção do movimento se necessário
	if $RayCast2D.is_colliding() and is_on_floor():
		movendo_para_esquerda = !movendo_para_esquerda
		scale.x = -scale.x
	
	if not $RayCast2D2.is_colliding() and is_on_floor():
		movendo_para_esquerda = !movendo_para_esquerda
		scale.x = -scale.x

func correr():
	# Executa a animação de corrida se o cogumelo não estiver dentro do alcance, vivo e não tiver sofrido dano
	if dentro_alcance == false and vida > 0 and !sofreu_dano:
		$AnimationPlayer.play("Correr")

func hit():
	# Habilita a detecção de ataques
	$Detector_ataque.monitoring = true

func fim_do_hit():
	# Desabilita a detecção de ataques
	$Detector_ataque.monitoring = false

func _on_Detector_jogador_body_entered(body):
	# Verifica se o cogumelo está dentro do alcance
	esta_dentro_alcance()

func esta_dentro_alcance():
	# Verifica se o cogumelo está sobrepondo com o corpo do jogador
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

# Dano que o Cogumelo aplica ao jogador
func _on_Detector_ataque_body_entered(body):
	if body.name == "Jogador":
		body.sofreu_dano(20)

func _on_Hurtbox_area_entered(area):
	# Mapeia os grupos de projéteis e aplica dano correspondente
	var grupos_projetil = {
		"Projetil_habilidade1": 20,
		"Projetil_habilidade3": 40,
		"Projetil_habilidade1_hinokami": 60,
		"Projetil_habilidade3_hinokami": 100,
	}
	
	if area.name in grupos_projetil:
		sofreu_dano(grupos_projetil[area.name])

func sofreu_dano(quantidade_dano):
	if vida > 0:
		# Executa a animação de dano, reduz a vida, emite sinal de atualização e lida com o estado de sofrer dano
		$AnimationPlayer.clear_queue()
		$Particles2D.emitting = true
		vida = max(vida - quantidade_dano, 0)
		emit_signal("mudar_status_cogumelo", self)
		$AnimationPlayer.play("Dano")
		$Som_dano.play()
		sofreu_dano = true
		yield($AnimationPlayer, "animation_finished")
		$Particles2D.emitting = false
		sofreu_dano = false
	if vida <= 0:
		finalizar_inimigo()

func cor_barra():
	# Define a cor da barra de vida com base no tamanho atual
	if $Vida/Barra.rect_size.x <= 28 and $Vida/Barra.rect_size.x >= 14:
		$Vida/Barra.color = Color(0.04, 0.50, 0.10, 1.00)
	elif $Vida/Barra.rect_size.x < 14 and $Vida/Barra.rect_size.x > 7:
		$Vida/Barra.color = Color(1.00, 0.50, 0.10, 1.00)
	elif $Vida/Barra.rect_size.x < 7:
		$Vida/Barra.color = Color(0.76, 0.00, 0.00, 1.00)

func _on_Cogumelo_mudar_status_cogumelo(var Cogumelo):
	# Atualiza o tamanho da barra de vida com base na vida atual do cogumelo
	$Vida/Barra.rect_size.x = 28 * Cogumelo.vida / Cogumelo.vida_maxima

func atualizar_barra_vida(delta: float):
	# Atualiza a vida do cogumelo com base na taxa de regeneração
	var nova_vida = min(vida + regen_vida * delta, vida_maxima)
	if nova_vida != vida && vida > 0 && !morto:
		vida = nova_vida
		emit_signal("mudar_status_cogumelo", self)
