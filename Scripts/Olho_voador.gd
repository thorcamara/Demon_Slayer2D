extends KinematicBody2D

# Pegar a referência ao nó do jogador
onready var jogador = get_node("/root/Level_01/Jogador")

# Variáveis de movimento
var velocidade_movimento = 50
var gravidade = 50
var direcao

# Variáveis de estado
var seguindo_jogador = false
var sofreu_dano = false
var morto = false

# Variáveis de vida
var vida = 40.0
var vida_maxima = 40.0
var regen_vida = 1.0

# Sinal para mudar o status do olho
signal mudar_status_olho

func _ready():
	# Configura a cor da barra de vida
	$Vida/Barra.color = Color(0.04, 0.50, 0.10, 1)

func _physics_process(delta):
	if seguindo_jogador == false:
		return
	elif seguindo_jogador == true and morto == false and jogador:
		# Calcula a direção do movimento em relação ao jogador
		direcao = (jogador.position - position).normalized()
		
		# Verifica a direção horizontal para virar o sprite
		if direcao.x > 0:
			$Sprite.flip_h = false
		if direcao.x < 0:
			$Sprite.flip_h = true
			
		# Move o objeto e aplica a física de deslizamento
		move_and_slide(direcao * velocidade_movimento)
		
	# Atualiza a cor da barra de vida e a regeneração de vida
	cor_barra()
	atualizar_barra_vida(delta)

func voar():
	# Verifica se ainda tem vida e não sofreu dano antes de iniciar a animação de voar
	if vida > 0 and !sofreu_dano:
		$AnimationPlayer.play("Voando")

func hit():
	# Ativa o detector de ataque
	$Detector_ataque.monitoring = true

func fim_do_hit():
	# Desativa o detector de ataque
	$Detector_ataque.monitoring = false

func _on_Detector_perseguir_jogador_body_entered(body):
	# Verifica se o corpo que entrou é do jogador e começa a seguir o jogador
	if body.is_in_group("jogador"):
		seguindo_jogador = true

func _on_Hurtbox_area_entered(area):
	var grupos_projetil = {
		"Projetil_habilidade1": 20,
		"Projetil_habilidade3": 40,
		"Projetil_habilidade1_hinokami": 60,
		"Projetil_habilidade3_hinokami": 100,
	}
	
	# Verifica se a área que entrou está em algum grupo de projétil e aplica o dano correspondente
	if area.name in grupos_projetil:
		sofreu_dano(grupos_projetil[area.name])

func morrer():
	# Atualiza o estado para morto, aplica a gravidade, executa a animação de morte e toca o som de morte
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
	# Verifica se ainda tem vida
	if vida > 0:
		# Configurações para animação de dano e efeito de partículas
		$AnimationPlayer.clear_queue()
		$Particles2D.emitting = true
		
		# Aplica o dano à vida e emite o sinal para mudar o status do olho
		vida = max(vida - quantidade_dano, 0)
		emit_signal("mudar_status_olho", self)
		
		$AnimationPlayer.play("Dano")
		$Som_dano.play()
		sofreu_dano = true
		yield($AnimationPlayer, "animation_finished")
		$Particles2D.emitting = false
		sofreu_dano = false
	
	# Verifica se a vida chegou a zero para morrer
	if vida <= 0:
		morrer()

func _on_Detector_jogador_body_entered(body):
	esta_dentro_alcance()
	
func esta_dentro_alcance():
	var sobrepondo_corpos = $Detector_jogador.get_overlapping_bodies()
	
	# Verifica se o jogador está dentro do alcance e executa a animação de ataque
	for corpo in sobrepondo_corpos:
		if corpo.name == "Jogador":
			print("detectou jogador")
			if !sofreu_dano:
				$AnimationPlayer.play("Atacar")
				yield($AnimationPlayer, "animation_finished")
				queue_free()
			break

func _on_Detector_ataque_body_entered(body):
	# Verifica se o corpo que entrou é do jogador e aplica o dano
	if body.name == "Jogador":
		body.sofreu_dano(50)

func cor_barra():
	# Atualiza a cor da barra de vida com base no tamanho da barra
	if $Vida/Barra.rect_size.x <= 28 and $Vida/Barra.rect_size.x >= 14:
		$Vida/Barra.color = Color(0.04, 0.50, 0.10, 1.00)
	elif $Vida/Barra.rect_size.x < 14 and $Vida/Barra.rect_size.x > 7:
		$Vida/Barra.color = Color(1.00, 0.50, 0.10, 1.00)
	elif $Vida/Barra.rect_size.x < 7:
		$Vida/Barra.color = Color(0.76, 0.00, 0.00, 1.00)

func _on_Olho_voador_mudar_status_olho(var Olho):
	# Atualiza o tamanho da barra de vida com base na vida do olho
	$Vida/Barra.rect_size.x = 28 * Olho.vida / Olho.vida_maxima

func atualizar_barra_vida(delta: float):
	# Atualiza a vida com base na regeneração de vida
	var nova_vida = min(vida + regen_vida * delta, vida_maxima)
	
	# Verifica se a vida mudou e ainda há vida para atualizar a barra
	if nova_vida != vida && vida > 0 && !morto:
		vida = nova_vida
		emit_signal("mudar_status_olho", self)
