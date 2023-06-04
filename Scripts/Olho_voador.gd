extends KinematicBody2D

onready var jogador = get_node("/root/Level_01/Jogador") #Pegar a referência ao nó do jogador

var velocidade_movimento = 50

var seguindo_jogador = false

var direcao_knockback = -1
var intensidade_knockback = 100

var ataque = 1

var sofreu_dano = false

var vida = 40.0
var vida_maxima = 40.0
var regen_vida = 1.0

signal mudar_status_olho

func _ready():
	$Vida/Barra.color = Color(0.04, 0.50, 0.10, 1)

func _physics_process(delta):
	if seguindo_jogador == false:
		return
	elif seguindo_jogador == true and jogador:
		var direcao = (jogador.position - position).normalized()
		if direcao.x > 0:
			$Sprite.flip_h = false
		if direcao.x < 0:
			$Sprite.flip_h = true
		move_and_slide(direcao * velocidade_movimento)
	cor_barra()
		
	var nova_vida = min(vida + regen_vida * delta, vida_maxima)
	if nova_vida != vida:
		vida = nova_vida
		emit_signal("mudar_status_olho", self)
				
				
func voar():
	$AnimationPlayer.play("Voando")
	
func hit():
	$Detector_ataque.monitoring = true


func fim_do_hit():
	$Detector_ataque.monitoring = false

func _on_Detector_perseguir_jogador_body_entered(body):
	if body.is_in_group("jogador"):
		seguindo_jogador = true


func _on_Hurtbox_area_entered(area):
	if area.is_in_group("projetil1"):
		_sofreu_dano(20)
	elif area.is_in_group("projetil3"):
		_sofreu_dano(40)
	elif area.is_in_group("projetil1_hinokami"):
		_sofreu_dano(60)
	elif area.is_in_group("projetil3_hinokami"):
		_sofreu_dano(100)
		
func morrer():
	$AnimationPlayer.clear_queue()
	$Particles2D.emitting = true
	$AnimationPlayer.play("Dano")
	$Som_dano.play()
	velocidade_movimento = 0
	yield($AnimationPlayer, "animation_finished")
	queue_free()
	
func _sofreu_dano(quantidade_dano):
	$AnimationPlayer.clear_queue()
	$Particles2D.emitting = true
	vida = vida - quantidade_dano
	emit_signal("mudar_status_goblin", self)
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


func _on_Detector_jogador_body_entered(body):
	esta_dentro_alcance()
	
func esta_dentro_alcance():
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
	if body.name == "Jogador":
		body._sofreu_dano(50)
		print("jogador sofreu dano")

func cor_barra():
	if $Vida/Barra.rect_size.x >= 28:
		$Vida/Barra.color = Color(0.04, 0.50, 0.10, 1.00)
	elif $Vida/Barra.rect_size.x < 14 and $Vida/Barra.rect_size.x > 7:
		$Vida/Barra.color = Color(1.00, 0.50, 0.10, 1.00)
	elif $Vida/Barra.rect_size.x < 7:
		$Vida/Barra.color = Color(0.76, 0.00, 0.00, 1.00)


func _on_Olho_voador_mudar_status_olho(var Olho):
	$Vida/Barra.rect_size.x = 28 * Olho.vida / Olho.vida_maxima
