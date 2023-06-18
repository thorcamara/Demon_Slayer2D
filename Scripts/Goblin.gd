extends KinematicBody2D

# Variáveis de movimento
var movimento = Vector2(0, 0)
var velocidade_movimento = 50
var gravidade = 10

# Variáveis de vida
var vida = 100.0
var vida_maxima = 100.0
var regen_vida = 1.0

# Sinal para notificar mudanças de status do Goblin
signal mudar_status_goblin

# Variáveis de estado
var sofreu_dano = false
var movendo_para_esquerda = false
var morto = false
var dentro_alcance = false

# Variáveis de Dano sofrido
var quantidade_dano 

onready var bomba_instancia = preload("res://Projeteis/Bomba.tscn")

func _ready():
	$AnimationPlayer.play("Correr")
	$Vida/Barra.color = Color(0.04, 0.50, 0.10, 1)

# Função principal de atualização
func _process(delta: float):
	if $AnimationPlayer.current_animation in (["Atacar", "Atacar2", "Dano", "Morte"]):
		return

	mover_inimigo()
	detectar_mudar_direcao()
	esta_dentro_alcance()
	esta_dentro_alcance_2()
	cor_barra()
	atualizar_barra_vida(delta)

# Finaliza o inimigo quando sua vida chega a 0
func finalizar_inimigo():
	morto = true
	$Particles2D.emitting = false
	$Detector_jogador_bomba.monitoring = false
	$Detector_jogador_ataque.monitoring = false
	$AnimationPlayer.clear_queue()
	$AnimationPlayer.play("Morte")
	$Som_morte.play()
	yield($AnimationPlayer, "animation_finished")
	yield($Som_morte, "finished")
	set_process(false)
	queue_free()
	return

# Movimenta o inimigo
func mover_inimigo():
	if morto: 
		return
	
	if !sofreu_dano:
		movimento.x = -velocidade_movimento if movendo_para_esquerda else velocidade_movimento
		movimento.y += gravidade
		$AnimationPlayer.play("Correr")
	
	movimento = move_and_slide(movimento, Vector2.UP)

# Detecta mudança de direção ao colidir com obstáculos
func detectar_mudar_direcao():
	if $RayCast2D.is_colliding() and is_on_floor():
		movendo_para_esquerda = !movendo_para_esquerda
		scale.x = -scale.x
		
	if not $RayCast2D2.is_colliding() and is_on_floor():
		movendo_para_esquerda = !movendo_para_esquerda
		scale.x = -scale.x

# Inicia movimento
func correr():
	if dentro_alcance == false and vida > 0 and !sofreu_dano:
		$AnimationPlayer.play("Correr")

# Inicia animação de atirar e desativa o monitoramento de bomba
func atirou():
	$Detector_jogador_bomba.monitoring = false

# Finaliza animação de atirar e reativa o monitoramento de bomba
func terminou_atirar():
	$Detector_jogador_bomba.monitoring = true

# Inicia animação de dano
func hit():
	$Detector_ataque.monitoring = true

# Finaliza animação de dano
func fim_do_hit():
	$Detector_ataque.monitoring = false

# Atira uma bomba
func _atirar_bomba():
	atirou()
	var bomba = bomba_instancia.instance()
	get_parent().add_child(bomba)
	bomba.global_position = $Position2D.global_position
	
	if movendo_para_esquerda:
		bomba.direcao = -1
	else:
		bomba.direcao = 1

# Verifica se o jogador entrou no alcance da bomba
func _on_Detector_jogador_bomba_body_entered(body):
	esta_dentro_alcance_2()

# Verifica se o jogador entrou no alcance do ataque
func esta_dentro_alcance_2():
	var sobrepondo_corpos = $Detector_jogador_bomba.get_overlapping_bodies()
	
	for corpo in sobrepondo_corpos:
		if corpo.name == "Jogador":
			dentro_alcance = true
			if !sofreu_dano:
				$AnimationPlayer.play("Atacar")
				yield($AnimationPlayer, "animation_finished")
			break
		else:
			dentro_alcance = false

# Verifica se o Goblin foi atingido por um projetil
func _on_Hurtbox_area_entered(area):
	var grupos_projetil = {
		"Projetil_habilidade1": 20,
		"Projetil_habilidade3": 40,
		"Projetil_habilidade1_hinokami": 60,
		"Projetil_habilidade3_hinokami": 100,
	}
	
	if area.name in grupos_projetil:
		sofreu_dano(grupos_projetil[area.name])

# Causa dano ao Goblin e atualiza a barra de vida
func sofreu_dano(quantidade_dano):
	if vida > 0:
		$AnimationPlayer.clear_queue()
		$Particles2D.emitting = true
		vida = max(vida - quantidade_dano, 0)
		emit_signal("mudar_status_goblin", self)
		$AnimationPlayer.play("Dano")
		$Som_dano.play()
		sofreu_dano = true
		yield($AnimationPlayer, "animation_finished")
		$Particles2D.emitting = false
		sofreu_dano = false
		
	if vida <= 0:
		finalizar_inimigo()

# Verifica se o jogador entrou no alcance do ataque corpo a corpo
func _on_Detector_jogador_ataque_body_entered(body):
	esta_dentro_alcance()

# Verifica se o Goblin está no alcance do jogador
func esta_dentro_alcance():
	var sobrepondo_corpos = $Detector_jogador_ataque.get_overlapping_bodies()
	
	for corpo in sobrepondo_corpos:
		if corpo.name == "Jogador":
			dentro_alcance = true
			if !sofreu_dano:
				$AnimationPlayer.play("Atacar2")
				yield($AnimationPlayer, "animation_finished")
			break
		else:
			dentro_alcance = false

# Dano que o Goblin aplica ao jogador
func _on_Detector_ataque_body_entered(body):
	if body.name == "Jogador":
		body.sofreu_dano(35)

# Atualiza a cor da barra de vida
func cor_barra():
	if $Vida/Barra.rect_size.x <= 28 and $Vida/Barra.rect_size.x >= 14:
		$Vida/Barra.color = Color(0.04, 0.50, 0.10, 1.00)
	elif $Vida/Barra.rect_size.x < 14 and $Vida/Barra.rect_size.x > 7:
		$Vida/Barra.color = Color(1.00, 0.50, 0.10, 1.00)
	elif $Vida/Barra.rect_size.x < 7:
		$Vida/Barra.color = Color(0.76, 0.00, 0.00, 1.00)

# Atualiza a barra de vida do Goblin
func atualizar_barra_vida(delta: float):
	var nova_vida = min(vida + regen_vida * delta, vida_maxima)
	if nova_vida != vida && vida > 0 && !morto:
		vida = nova_vida
		emit_signal("mudar_status_goblin", self)

func _on_Goblin_mudar_status_goblin(var Goblin):
	# Atualiza o tamanho da barra de vida com base na vida atual do cogumelo
	$Vida/Barra.rect_size.x = 28 * Goblin.vida / Goblin.vida_maxima
