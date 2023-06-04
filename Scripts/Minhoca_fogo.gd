extends KinematicBody2D


var movimento = Vector2(0, 0)
var velocidade_movimento = 50
var gravidade = 10

var vida = 200.0
var vida_maxima = 200.0
var regen_vida = 1.0

signal mudar_status_minhoca

var sofreu_dano = false
var movendo_para_esquerda = false

var dentro_alcance = false

var quantidade_dano = 10

onready var bola_fogo_instancia = preload("res://Projeteis/Bola_fogo.tscn")

func _ready():
	$Vida/Barra.color = Color(0.04, 0.50, 0.10, 1)
	
func _process(delta: float):
	if $AnimationPlayer.current_animation == "Atacar":
		return
		
	mover_inimigo()
	detectar_mudar_direcao()
	esta_dentro_alcance()
	cor_barra()
	
	var nova_vida = min(vida + regen_vida * delta, vida_maxima)
	if nova_vida != vida:
		vida = nova_vida
		emit_signal("mudar_status_minhoca", self)
		
func mover_inimigo():
	movimento.x = -velocidade_movimento if movendo_para_esquerda else velocidade_movimento
	movimento.y += gravidade
	if !sofreu_dano:
		$AnimationPlayer.play("Andar")
	
	movimento = move_and_slide(movimento, Vector2.UP)

func detectar_mudar_direcao():
	if $RayCast2D.is_colliding() and is_on_floor():
		print("Horizontal acionando")
		movendo_para_esquerda = !movendo_para_esquerda
		scale.x = -scale.x
		
	if not $RayCast2D2.is_colliding() and is_on_floor():
		print("Vertical acionando")
		movendo_para_esquerda = !movendo_para_esquerda
		scale.x = -scale.x
		

func andar():
	if dentro_alcance == false:
		$AnimationPlayer.play("Andar")

func atirou():
	$Detector_jogador.monitoring = false
	
func terminou_atirar():
	$Detector_jogador.monitoring = true
	
func _atirar_bola_fogo():
	atirou()
	var bola_fogo = bola_fogo_instancia.instance()
	get_parent().add_child(bola_fogo)
	bola_fogo.global_position = $Position2D.global_position
	
	if sign($Position2D.position.x) == 1:
		bola_fogo.set_direcao(-1)
	else:
		bola_fogo.set_direcao(-1)

func _on_Detector_jogador_body_entered(body):
	esta_dentro_alcance()
		
func esta_dentro_alcance():
	var sobrepondo_corpos = $Detector_jogador.get_overlapping_bodies()
	
	for corpo in sobrepondo_corpos:
		if corpo.name == "Jogador":
			dentro_alcance = true
			if !sofreu_dano:
				$AnimationPlayer.play("Atacar")
				yield($AnimationPlayer, "animation_finished")
			break
		else:
			dentro_alcance = false

func _on_Hurtbox_area_entered(area):
	if area.is_in_group("projetil1"):
		_sofreu_dano(20)
	elif area.is_in_group("projetil3"):
		_sofreu_dano(40)
	elif area.is_in_group("projetil1_hinokami"):
		_sofreu_dano(60)
	elif area.is_in_group("projetil3_hinokami"):
		_sofreu_dano(100)
		
func _sofreu_dano(quantidade_dano):
	$AnimationPlayer.clear_queue()
	$Particles2D.emitting = true
	vida = vida - quantidade_dano
	emit_signal("mudar_status_minhoca", self)
	$AnimationPlayer.play("Dano")
	$Som_dano.play()
	sofreu_dano = true
	velocidade_movimento = 0
	yield($AnimationPlayer, "animation_finished")
	$Particles2D.emitting = false
	velocidade_movimento = 50
	sofreu_dano = false
	if vida < 0:
		queue_free()

func cor_barra():
	if $Vida/Barra.rect_size.x <= 48 and $Vida/Barra.rect_size.x >= 24:
		$Vida/Barra.color = Color(0.04, 0.50, 0.10, 1.00)
	elif $Vida/Barra.rect_size.x < 24 and $Vida/Barra.rect_size.x > 12:
		$Vida/Barra.color = Color(1.00, 0.50, 0.10, 1.00)
	elif $Vida/Barra.rect_size.x < 12:
		$Vida/Barra.color = Color(0.76, 0.00, 0.00, 1.00)


func _on_Minhoca_fogo_mudar_status_minhoca(var Minhoca):
	$Vida/Barra.rect_size.x = 48 * Minhoca.vida / Minhoca.vida_maxima

