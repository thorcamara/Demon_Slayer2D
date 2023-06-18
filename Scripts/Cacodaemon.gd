extends KinematicBody2D

# Pegar a referência ao nó do jogador
onready var jogador = get_node("/root/Level_02/Jogador")

# Variáveis de movimento
var velocidade_movimento = 50
var gravidade = 50
var direcao

# Variáveis de estado
var seguindo_jogador = false
var sofreu_dano = false
var morto = false

# Variáveis de estado de vida
var vida = 35.0
var vida_maxima = 35.0
var regen_vida = 1.0

# Sinal para mudar o status do olho
signal mudar_status_cacodaemon

func _ready():
	# Define a cor da barra de vida do Cacodaemon
	$Vida/Barra.color = Color(0.04, 0.50, 0.10, 1)

func _physics_process(delta):
	# Verifica se o Cacodaemon está seguindo o jogador e atualiza sua posição
	if seguindo_jogador == false:
		return
	elif seguindo_jogador == true and morto == false and jogador:
		direcao = (jogador.position - position).normalized()
		if direcao.x > 0:
			$Sprite.flip_h = false
		if direcao.x < 0:
			$Sprite.flip_h = true
		move_and_slide(direcao * velocidade_movimento)
		
	cor_barra()
	atualizar_barra_vida(delta)

func voar():
	# Verifica se o Cacodaemon pode voar e reproduz a animação correspondente
	if vida > 0 and !sofreu_dano:
		$AnimationPlayer.play("Voando")

func hit():
	# Ativa a detecção de ataques
	$Detector_ataque.monitoring = true

func fim_do_hit():
	# Desativa a detecção de ataques
	$Detector_ataque.monitoring = false

func _on_Detector_perseguir_jogador_body_entered(body):
	# Verifica se o corpo que entrou em contato é o jogador e inicia o seguimento
	if body.is_in_group("jogador"):
		print("Seguindo")
		seguindo_jogador = true

func _on_Hurtbox_area_entered(area):
	var grupos_projetil = {
		# Mapeamento dos nomes dos grupos de projéteis para a quantidade de dano
		"Projetil_habilidade1": 20,
		"Projetil_habilidade3": 40,
		"Projetil_habilidade1_hinokami": 60,
		"Projetil_habilidade3_hinokami": 100,
	}
	
	if area.name in grupos_projetil:
		# Verifica se a área de colisão pertence a um grupo de projéteis e causa dano ao Cacodaemon
		sofreu_dano(grupos_projetil[area.name])

func morrer():
	# Realiza as ações de morte do Cacodaemon
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
	# Realiza as ações quando o Cacodaemon sofre dano
	if vida > 0:
		$AnimationPlayer.clear_queue()
		$Particles2D.emitting = true
		vida = max(vida - quantidade_dano, 0)
		emit_signal("mudar_status_cacodaemon", self)
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
	# Verifica se o corpo que entrou em contato é o jogador e chama a função "esta_dentro_alcance"
	esta_dentro_alcance()
	
func esta_dentro_alcance():
	# Verifica se o jogador está dentro do alcance do Cacodaemon
	var sobrepondo_corpos = $Detector_jogador.get_overlapping_bodies()
	
	for corpo in sobrepondo_corpos:
		if corpo.name == "Jogador":
			print("detectou jogador")
			if !sofreu_dano:
				$AnimationPlayer.play("Atacar")
				yield($AnimationPlayer, "animation_finished")
				queue_free()
			break

func _on_Detector_ataque_body_entered(body):
	# Verifica se o corpo que entrou em contato é o jogador e causa dano ao jogador
	if body.name == "Jogador":
		body.sofreu_dano(75)
		queue_free()

func cor_barra():
	# Define a cor da barra de vida com base no valor atual da vida
	if $Vida/Barra.rect_size.x <= 28 and $Vida/Barra.rect_size.x >= 14:
		$Vida/Barra.color = Color(0.04, 0.50, 0.10, 1.00)
	elif $Vida/Barra.rect_size.x < 14 and $Vida/Barra.rect_size.x > 7:
		$Vida/Barra.color = Color(1.00, 0.50, 0.10, 1.00)
	elif $Vida/Barra.rect_size.x < 7:
		$Vida/Barra.color = Color(0.76, 0.00, 0.00, 1.00)

func _on_Cacodaemon_mudar_status_cacodaemon(var Cacodaemon):
	# Atualiza o tamanho da barra de vida com base nos valores atuais de vida e vida máxima
	$Vida/Barra.rect_size.x = 28 * Cacodaemon.vida / Cacodaemon.vida_maxima

func atualizar_barra_vida(delta: float):
	# Atualiza a barra de vida com base no valor atual da vida e taxa de regeneração
	var nova_vida = min(vida + regen_vida * delta, vida_maxima)
	if nova_vida != vida && vida > 0 && !morto:
		vida = nova_vida
		emit_signal("mudar_status_cacoedemon", self)
