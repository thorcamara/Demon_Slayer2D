extends KinematicBody2D

onready var jogador = get_node("/root/Level_02/Jogador") # Pegar a referência ao nó do jogador

# Variáveis de movimento
var velocidade_movimento = 50
var gravidade = -100
var direcao

# Estado do personagem
var seguindo_jogador = false
var dentro_agua = true
var sofreu_dano = false
var morto = false

# Vida do personagem
var vida = 35.0
var vida_maxima = 35.0
var regen_vida = 1.0

signal mudar_status_enguia

func _ready():
	# Configuração inicial
	$Vida/Barra.color = Color(0.04, 0.50, 0.10, 1) # Define a cor inicial da barra de vida

func _physics_process(delta):
	# Atualização física do personagem
	if seguindo_jogador == false:
		return
	elif seguindo_jogador == true and dentro_agua == true and morto == false and jogador:
		# Seguir o jogador na água
		direcao = (jogador.position - position).normalized()
		if direcao.x > 0:
			$Sprite.flip_h = false # Vira o sprite para a direção do jogador
		if direcao.x < 0:
			$Sprite.flip_h = true # Vira o sprite para a direção oposta do jogador
		move_and_slide(direcao * velocidade_movimento) # Move o personagem na direção do jogador
		
	cor_barra() # Atualiza a cor da barra de vida
	atualizar_barra_vida(delta) # Atualiza a barra de vida

func nadar():
	# Lógica de nadar
	if vida > 0 and !sofreu_dano:
		$AnimationPlayer.play("Nadar") # Inicia a animação de nadar

func hit():
	# Lógica de realizar um ataque
	$Detector_ataque.monitoring = true

func fim_do_hit():
	# Fim de um ataque
	$Detector_ataque.monitoring = false

func _on_Detector_perseguir_jogador_body_entered(body):
	# Detecção do jogador para começar a segui-lo
	if body.is_in_group("jogador"):
		seguindo_jogador = true

func _on_Detector_perseguir_jogador_body_exited(body):
	# Parar de seguir o jogador quando ele sai de contato
	if body.is_in_group("jogador"):
		seguindo_jogador = false

func _on_Hurtbox_area_entered(area):
	# Lógica de receber dano quando entra em contato com certos grupos de projéteis
	var grupos_projetil = {
		"Projetil_habilidade1": 20,
		"Projetil_habilidade3": 40,
		"Projetil_habilidade1_hinokami": 60,
		"Projetil_habilidade3_hinokami": 100,
	}
	
	if area.name in grupos_projetil:
		sofreu_dano(grupos_projetil[area.name])

func morrer():
	# Lógica de morte do personagem
	morto = true
	direcao.y += gravidade
	$Detector_jogador.monitoring = false
	$AnimationPlayer.clear_queue()
	$Particles2D.emitting = false
	$AnimationPlayer.play("Morte") # Inicia a animação de morte
	$Som_morte.play() # Reproduz o som de morte
	velocidade_movimento = 0
	yield($AnimationPlayer, "animation_finished")
	yield($Som_morte, "finished")
	set_physics_process(false)
	queue_free()

func sofreu_dano(quantidade_dano):
	# Lógica de receber dano
	if vida > 0:
		$AnimationPlayer.clear_queue()
		$Particles2D.emitting = true
		vida = max(vida - quantidade_dano, 0)
		emit_signal("mudar_status_enguia", self)
		$AnimationPlayer.play("Dano")
		$Som_dano.play()
		sofreu_dano = true
		velocidade_movimento = 0
		yield($AnimationPlayer, "animation_finished")
		$Particles2D.emitting = false
		velocidade_movimento = 50
		sofreu_dano = false
	if vida <= 0:
		morrer()

func _on_Detector_jogador_body_entered(body):
	esta_dentro_alcance()

func esta_dentro_alcance():
	# Verifica se o jogador está dentro do alcance do personagem
	var sobrepondo_corpos = $Detector_jogador.get_overlapping_bodies()
	
	for corpo in sobrepondo_corpos:
		if corpo.name == "Jogador":
			if !sofreu_dano:
				$AnimationPlayer.play("Atacar") # Inicia a animação de ataque
				yield($AnimationPlayer, "animation_finished")
			break

func _on_Detector_ataque_body_entered(body):
	# Lógica de ataque quando o corpo entra em contato com o jogador
	if body.name == "Jogador":
		body.sofreu_dano(50) # Aplica dano ao jogador

func cor_barra():
	# Atualiza a cor da barra de vida com base no valor atual
	if $Vida/Barra.rect_size.x <= 28 and $Vida/Barra.rect_size.x >= 14:
		$Vida/Barra.color = Color(0.04, 0.50, 0.10, 1.00) # Verde
	elif $Vida/Barra.rect_size.x < 14 and $Vida/Barra.rect_size.x > 7:
		$Vida/Barra.color = Color(1.00, 0.50, 0.10, 1.00) # Laranja
	elif $Vida/Barra.rect_size.x < 7:
		$Vida/Barra.color = Color(0.76, 0.00, 0.00, 1.00) # Vermelho

func _on_Enguia_mudar_status_enguia(var Enguia):
	# Atualiza o tamanho da barra de vida com base na vida atual da enguia
	$Vida/Barra.rect_size.x = 28 * Enguia.vida / Enguia.vida_maxima

func atualizar_barra_vida(delta: float):
	# Atualiza a barra de vida com base na regeneração de vida e no tempo delta
	var nova_vida = min(vida + regen_vida * delta, vida_maxima)
	if nova_vida != vida && vida > 0 && !morto:
		vida = nova_vida
		emit_signal("mudar_status_enguia", self)

func _on_Agua2_body_entered(body):
	# Lógica para detectar quando o personagem entra na água
	if body.name == "Enguia":
		dentro_agua = true

func _on_Agua2_body_exited(body):
	# Lógica para detectar quando o personagem sai da água
	if body.name == "Enguia":
		dentro_agua = false

func _on_Agua4_body_entered(body):
	# Lógica para detectar quando o personagem entra na água
	if body.name == "Enguia":
		print("Enguia2 =", dentro_agua)
		dentro_agua = true

func _on_Agua4_body_exited(body):
	# Lógica para detectar quando o personagem sai da água
	if body.name == "Enguia":
		print("Enguia2 =", dentro_agua)
		dentro_agua = false

