extends KinematicBody2D

# Obtém a referência ao nó do jogador
onready var jogador = get_node("/root/Level_02/Jogador")

# Variáveis de movimento
var velocidade_movimento = 50
var gravidade = -100
var direcao

# Variáveis de estado
var seguindo_jogador = false
var dentro_agua = true
var sofreu_dano = false
var morto = false

# Variáveis de vida
export var vida = 40.0
export var vida_maxima = 40.0
var regen_vida = 1.0

# Variável de dano causado ao jogador
export var dano_player = 25

# Sinal emitido ao mudar o status do polvo
signal mudar_status_polvo

func _ready():
	# Configura a cor da barra de vida
	$Vida/Barra.color = Color(0.04, 0.50, 0.10, 1)

func _physics_process(delta):
	# Atualização física do personagem
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
	# Inicia a animação de nadar
	if vida > 0 and !sofreu_dano:
		$AnimationPlayer.play("Nadar")
	
func hit():
	# Monitora o detector de ataque
	$Detector_ataque.monitoring = true

func fim_do_hit():
	# Para de monitorar o detector de ataque
	$Detector_ataque.monitoring = false

func _on_Detector_perseguir_jogador_body_entered(body):
	# Verifica se o jogador entrou no alcance de perseguição
	if body.is_in_group("jogador"):
		seguindo_jogador = true

func _on_Detector_perseguir_jogador_body_exited(body):
	# Verifica se o jogador saiu do alcance de perseguição
	if body.is_in_group("jogador"):
		seguindo_jogador = false

func _on_Hurtbox_area_entered(area):
	# Lógica de dano ao polvo quando entra em contato com uma área de ataque
	var grupos_projetil = {
		"Projetil_habilidade1": 20,
		"Projetil_habilidade3": 40,
		"Projetil_habilidade1_hinokami": 60,
		"Projetil_habilidade3_hinokami": 100,
	}
	
	if area.name in grupos_projetil:
		sofreu_dano(grupos_projetil[area.name])
		
func morrer():
	# Lógica de morte do polvo
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
	# Lógica de quando o polvo sofre dano
	if vida > 0:
		$AnimationPlayer.clear_queue()
		$Particles2D.emitting = true
		vida = max(vida - quantidade_dano, 0)
		emit_signal("mudar_status_polvo", self)
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
	# Verifica se o jogador está dentro do alcance de ataque
	var sobrepondo_corpos = $Detector_jogador.get_overlapping_bodies()
	
	for corpo in sobrepondo_corpos:
		if corpo.name == "Jogador":
			if !sofreu_dano:
				$AnimationPlayer.play("Atacar")
				yield($AnimationPlayer, "animation_finished")
			break

func _on_Detector_ataque_body_entered(body):
	# Verifica se o jogador entrou no alcance do ataque
	if body.name == "Jogador":
		body.sofreu_dano(dano_player)

func cor_barra():
	# Define a cor da barra de acordo com a quantidade de vida
	if $Vida/Barra.rect_size.x <= 28 and $Vida/Barra.rect_size.x >= 14:
		$Vida/Barra.color = Color(0.04, 0.50, 0.10, 1.00)
	elif $Vida/Barra.rect_size.x < 14 and $Vida/Barra.rect_size.x > 7:
		$Vida/Barra.color = Color(1.00, 0.50, 0.10, 1.00)
	elif $Vida/Barra.rect_size.x < 7:
		$Vida/Barra.color = Color(0.76, 0.00, 0.00, 1.00)

func _on_Polvo_mudar_status_polvo(var Polvo):
	# Atualiza a barra de vida do polvo
	$Vida/Barra.rect_size.x = 28 * Polvo.vida / Polvo.vida_maxima

func atualizar_barra_vida(delta: float):
	# Atualiza a barra de vida com base na regeneração de vida e no tempo delta
	var nova_vida = min(vida + regen_vida * delta, vida_maxima)
	if nova_vida != vida && vida > 0 && !morto:
		vida = nova_vida
		emit_signal("mudar_status_polvo", self)

func _on_Agua3_body_entered(body):
	# Verifica se o polvo entrou na água
	if body.name == "Polvo":
		dentro_agua = true


func _on_Agua3_body_exited(body):
	# Verifica se o polvo saiu da água
	if body.name == "Polvo":
		dentro_agua = false


func _on_Agua5_body_entered(body):
	# Verifica se o polvo entrou na água
	if body.name == "Polvo":
		dentro_agua = true


func _on_Agua5_body_exited(body):
	# Verifica se o polvo saiu da água
	if body.name == "Polvo":
		dentro_agua = false


func _on_Agua4_body_entered(body):
	# Verifica se o polvo entrou na água
	if body.name == "Polvo":
		dentro_agua = true


func _on_Agua4_body_exited(body):
	# Verifica se o polvo saiu da água
	if body.name == "Polvo":
		dentro_agua = false
