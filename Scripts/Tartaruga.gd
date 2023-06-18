extends KinematicBody2D

# Referência ao nó do jogador
onready var jogador = get_node("/root/Level_02/Jogador")

# Variáveis para controlar o movimento da tartaruga
var velocidade_movimento = 50
var gravidade = -100
var direcao

# Variáveis de estado da tartaruga
var seguindo_jogador = false
var dentro_agua = false
var sofreu_dano = false
var morto = false

# Variáveis de vida da tartaruga
var vida = 80.0
var vida_maxima = 80.0
var regen_vida = 1.0

# Sinal emitido quando o estado da tartaruga muda
signal mudar_status_tartaruga

func _ready():
	# Configura a cor inicial da barra de vida
	$Vida/Barra.color = Color(0.04, 0.50, 0.10, 1)

func _physics_process(delta):
	# Verifica se a tartaruga está seguindo o jogador
	if seguindo_jogador == false:
		return
	elif seguindo_jogador == true and dentro_agua == true and morto == false and jogador:
		# Calcula a direção em que a tartaruga deve se mover em direção ao jogador
		direcao = (jogador.position - position).normalized()
		if direcao.x > 0:
			$Sprite.flip_h = false
		if direcao.x < 0:
			$Sprite.flip_h = true
		move_and_slide(direcao * velocidade_movimento)
	
	# Atualiza a cor da barra de vida
	cor_barra()
	
	# Atualiza a barra de vida com base na regeneração de vida e no tempo delta
	atualizar_barra_vida(delta)

func nadar():
	# Verifica se a tartaruga pode nadar (vida maior que zero e sem sofrer dano)
	if vida > 0 and !sofreu_dano:
		$AnimationPlayer.play("Nadar")
	
func hit():
	$Detector_ataque.monitoring = true

func fim_do_hit():
	$Detector_ataque.monitoring = false

func _on_Detector_perseguir_jogador_body_entered(body):
	# Verifica se a tartaruga detectou o jogador
	if body.is_in_group("jogador"):
		seguindo_jogador = true

func _on_Detector_perseguir_jogador_body_exited(body):
	# Verifica se a tartaruga perdeu o jogador de vista
	if body.is_in_group("jogador"):
		seguindo_jogador = false

func _on_Hurtbox_area_entered(area):
	# Verifica se a tartaruga sofreu dano de uma área de colisão específica
	var grupos_projetil = {
		"Projetil_habilidade1": 20,
		"Projetil_habilidade3": 40,
		"Projetil_habilidade1_hinokami": 60,
		"Projetil_habilidade3_hinokami": 100,
	}
	
	if area.name in grupos_projetil:
		sofreu_dano(grupos_projetil[area.name])
		
func morrer():
	morto = true
	direcao.y += gravidade
	$Detector_jogador.monitoring = false
	$AnimationPlayer.clear_queue()
	$Particles2D.emitting = false
	$AnimationPlayer.play("Morte")  # Inicia a animação de morte
	$Som_morte.play()  # Reproduz o som de morte
	velocidade_movimento = 0
	yield($AnimationPlayer, "animation_finished")
	yield($Som_morte, "finished")
	set_physics_process(false)
	queue_free()
	
func sofreu_dano(quantidade_dano):
	# Verifica se a tartaruga ainda tem vida e não sofreu dano recentemente
	if vida > 0:
		$AnimationPlayer.clear_queue()
		$Particles2D.emitting = true
		vida = max(vida - quantidade_dano, 0)
		emit_signal("mudar_status_tartaruga", self)
		$AnimationPlayer.play("Dano")
		$Som_dano.play()
		sofreu_dano = true
		velocidade_movimento = 0
		yield($AnimationPlayer, "animation_finished")
		$Particles2D.emitting = false
		velocidade_movimento = 50
		sofreu_dano = false
	
	# Verifica se a tartaruga está morta
	if vida <= 0:
		morrer()


func _on_Detector_jogador_body_entered(body):
	esta_dentro_alcance()
	
func esta_dentro_alcance():
	# Verifica se o jogador está dentro do alcance da tartaruga
	var sobrepondo_corpos = $Detector_jogador.get_overlapping_bodies()
	
	for corpo in sobrepondo_corpos:
		if corpo.name == "Jogador":
			if !sofreu_dano:
				 $AnimationPlayer.play("Atacar")
				 yield($AnimationPlayer, "animation_finished")
			break

func _on_Detector_ataque_body_entered(body):
	# Verifica se a tartaruga colidiu com o jogador durante um ataque
	if body.name == "Jogador":
		body.sofreu_dano(15)

func cor_barra():
	# Atualiza a cor da barra de vida com base no tamanho da barra
	if $Vida/Barra.rect_size.x <= 28 and $Vida/Barra.rect_size.x >= 14:
		$Vida/Barra.color = Color(0.04, 0.50, 0.10, 1.00)
	elif $Vida/Barra.rect_size.x < 14 and $Vida/Barra.rect_size.x > 7:
		$Vida/Barra.color = Color(1.00, 0.50, 0.10, 1.00)
	elif $Vida/Barra.rect_size.x < 7:
		$Vida/Barra.color = Color(0.76, 0.00, 0.00, 1.00)


func _on_Tartaruga_mudar_status_tartaruga(var Tartaruga):
	# Atualiza o tamanho da barra de vida com base na vida da tartaruga
	$Vida/Barra.rect_size.x = 28 * Tartaruga.vida / Tartaruga.vida_maxima

func atualizar_barra_vida(delta: float):
	# Atualiza a barra de vida com base na regeneração de vida e no tempo delta
	var nova_vida = min(vida + regen_vida * delta, vida_maxima)
	if nova_vida != vida && vida > 0 && !morto:
		vida = nova_vida
		emit_signal("mudar_status_tartaruga", self)

func _on_Agua4_body_entered(body):
	# Verifica se a tartaruga entrou na água
	if body.name == "Tartaruga":
		dentro_agua = true


func _on_Agua4_body_exited(body):
	# Verifica se a tartaruga saiu da água
	if body.name == "Tartaruga":
		dentro_agua = false
