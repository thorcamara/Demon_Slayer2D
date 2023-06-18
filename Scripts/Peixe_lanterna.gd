extends KinematicBody2D

# Referência ao nó do jogador
onready var jogador = get_node("/root/Level_02/Jogador")

# Variáveis de movimento e física
var velocidade_movimento = 50
var gravidade = -100
var direcao

# Estados do personagem
var seguindo_jogador = false
var dentro_agua = false
var sofreu_dano = false
var morto = false

# Vida do personagem
var vida = 40.0
var vida_maxima = 40.0
var regen_vida = 1.0

# Sinal para atualizar a barra de vida
signal mudar_status_peixe_lanterna

func _ready():
	# Configuração inicial da cor da barra de vida
	$Vida/Barra.color = Color(0.04, 0.50, 0.10, 1)

func _physics_process(delta):
	# Lógica de movimento do personagem
	if seguindo_jogador == false:
		return
	elif seguindo_jogador == true and dentro_agua == true and morto == false and jogador:
		direcao = (jogador.position - position).normalized()
		if direcao.x > 0:
			$Sprite.flip_h = false
		if direcao.x < 0:
			$Sprite.flip_h = true
		move_and_slide(direcao * velocidade_movimento)
		
	cor_barra()
	atualizar_barra_vida(delta)

func nadar():
	# Função para iniciar a animação de natação
	if vida > 0 and !sofreu_dano:
		$AnimationPlayer.play("Nadar")

func hit():
	# Função para iniciar a detecção de ataque
	$Detector_ataque.monitoring = true

func fim_do_hit():
	# Função para encerrar a detecção de ataque
	$Detector_ataque.monitoring = false

func _on_Detector_perseguir_jogador_body_entered(body):
	# Função chamada quando o personagem entra no alcance do jogador
	if body.is_in_group("jogador"):
		seguindo_jogador = true

func _on_Detector_perseguir_jogador_body_exited(body):
	# Função chamada quando o personagem sai do alcance do jogador
	if body.is_in_group("jogador"):
		seguindo_jogador = false

func _on_Hurtbox_area_entered(area):
	# Função chamada quando o personagem entra em uma área de dano
	var grupos_projetil = {
		"Projetil_habilidade1": 20,
		"Projetil_habilidade3": 40,
		"Projetil_habilidade1_hinokami": 60,
		"Projetil_habilidade3_hinokami": 100,
	}
	
	if area.name in grupos_projetil:
		sofreu_dano(grupos_projetil[area.name])
		
func morrer():
	# Função para definir o personagem como morto
	morto = true
	direcao.y += gravidade
	$Detector_jogador.monitoring = false
	$AnimationPlayer.clear_queue()
	$Particles2D.emitting = false
	$AnimationPlayer.play("Morte") 
	$Som_morte.play()  
	velocidade_movimento = 0
	yield($AnimationPlayer, "animation_finished")
	yield($Som_morte, "finished")
	set_physics_process(false)
	queue_free()
	
func sofreu_dano(quantidade_dano):
	# Função para aplicar dano ao personagem
	if vida > 0:
		$AnimationPlayer.clear_queue()
		$Particles2D.emitting = true
		vida = max(vida - quantidade_dano, 0)
		emit_signal("mudar_status_peixe_lanterna", self)
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
		body.sofreu_dano(30)

func cor_barra():
	# Função para atualizar a cor da barra de vida
	if $Vida/Barra.rect_size.x <= 28 and $Vida/Barra.rect_size.x >= 14:
		$Vida/Barra.color = Color(0.04, 0.50, 0.10, 1.00)
	elif $Vida/Barra.rect_size.x < 14 and $Vida/Barra.rect_size.x > 7:
		$Vida/Barra.color = Color(1.00, 0.50, 0.10, 1.00)
	elif $Vida/Barra.rect_size.x < 7:
		$Vida/Barra.color = Color(0.76, 0.00, 0.00, 1.00)

func _on_Agua4_body_entered(body):
	# Função chamada quando o personagem entra na água
	if body.name == "Peixe_lanterna":
		dentro_agua = true

func _on_Agua4_body_exited(body):
	# Função chamada quando o personagem sai da água
	if body.name == "Peixe_lanterna":
		dentro_agua = false

func _on_Peixe_lanterna_mudar_status_peixe_lanterna(var Peixe_lanterna):
	# Função chamada quando ocorre o sinal para atualizar a barra de vida
	$Vida/Barra.rect_size.x = 28 * Peixe_lanterna.vida / Peixe_lanterna.vida_maxima

func atualizar_barra_vida(delta: float):
	# Função para atualizar a barra de vida ao longo do tempo
	var nova_vida = min(vida + regen_vida * delta, vida_maxima)
	if nova_vida != vida && vida > 0 && !morto:
		vida = nova_vida
		emit_signal("mudar_status_peixe_lanterna", self)
