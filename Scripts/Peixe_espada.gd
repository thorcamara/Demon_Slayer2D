extends KinematicBody2D

# Referência para o nó do jogador
onready var jogador = get_node("/root/Level_02/Jogador")

# Variáveis de movimento
var velocidade_movimento = 50
var gravidade = -100
var direcao

# Variáveis de estado
var seguindo_jogador = false
var dentro_agua = false
var sofreu_dano = false
var morto = false

# Variáveis de vida
var vida = 75.0
var vida_maxima = 75.0
var regen_vida = 1.0

# Sinal para atualizar a barra de vida
signal mudar_status_peixe_espada

func _ready():
	# Define a cor inicial da barra de vida
	$Vida/Barra.color = Color(0.04, 0.50, 0.10, 1)

func _physics_process(delta):
	if seguindo_jogador == false:
		return
	elif seguindo_jogador == true and dentro_agua == true and morto == false and jogador:
		# Calcula a direção até o jogador e atualiza a orientação do sprite
		direcao = (jogador.position - position).normalized()
		if direcao.x > 0:
			$Sprite.flip_h = false
		if direcao.x < 0:
			$Sprite.flip_h = true
		move_and_slide(direcao * velocidade_movimento)
		
	cor_barra()
	atualizar_barra_vida(delta)

func nadar():
	if vida > 0 and !sofreu_dano:
		$AnimationPlayer.play("Nadar")
	
func hit():
	$Detector_ataque.monitoring = true

func fim_do_hit():
	$Detector_ataque.monitoring = false

func _on_Detector_perseguir_jogador_body_entered(body):
	if body.is_in_group("jogador"):
		seguindo_jogador = true

func _on_Detector_perseguir_jogador_body_exited(body):
	if body.is_in_group("jogador"):
		seguindo_jogador = false

func _on_Hurtbox_area_entered(area):
	# Dicionário de grupos de projetil e a quantidade de dano associada a cada grupo
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
	if vida > 0:
		$AnimationPlayer.clear_queue()
		$Particles2D.emitting = true
		vida = max(vida - quantidade_dano, 0)
		emit_signal("mudar_status_peixe_espada", self)
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
	# Função para verificar se o jogador está dentro do alcance do personagem
	var sobrepondo_corpos = $Detector_jogador.get_overlapping_bodies()
	
	for corpo in sobrepondo_corpos:
		if corpo.name == "Jogador":
			if !sofreu_dano:
				$AnimationPlayer.play("Atacar")
				yield($AnimationPlayer, "animation_finished")
			break

func _on_Detector_ataque_body_entered(body):
	# Função chamada quando o personagem entra em contato com a área de ataque
	if body.name == "Jogador":
		body.sofreu_dano(35)

func cor_barra():
	# Atualiza a cor da barra de vida com base no valor atual da vida
	if $Vida/Barra.rect_size.x <= 28 and $Vida/Barra.rect_size.x >= 14:
		$Vida/Barra.color = Color(0.04, 0.50, 0.10, 1.00)
	elif $Vida/Barra.rect_size.x < 14 and $Vida/Barra.rect_size.x > 7:
		$Vida/Barra.color = Color(1.00, 0.50, 0.10, 1.00)
	elif $Vida/Barra.rect_size.x < 7:
		$Vida/Barra.color = Color(0.76, 0.00, 0.00, 1.00)

func _on_Agua4_body_entered(body):
	if body.name == "Peixe_espada":
		dentro_agua = true

func _on_Agua4_body_exited(body):
	if body.name == "Peixe_espada":
		dentro_agua = false

func _on_Peixe_espada_mudar_status_peixe_espada(var Peixe_espada):
	$Vida/Barra.rect_size.x = 28 * Peixe_espada.vida / Peixe_espada.vida_maxima
	
func atualizar_barra_vida(delta: float):
	# Atualiza a barra de vida com base no tempo decorrido e taxa de regeneração
	var nova_vida = min(vida + regen_vida * delta, vida_maxima)
	if nova_vida != vida && vida > 0 && !morto:
		vida = nova_vida
		emit_signal("mudar_status_peixe_espada", self)

