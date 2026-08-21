extends CharacterBody3D

@export_group("Movimentação")
@export var speed: float = 10.0
@export var jump_velocity: float = 4.5
@export var acceleration: float = 10.0 # Suaviza o arranque e a parada

@export_group("Câmera / Sensibilidade")
@export var mouse_sensitivity: float = 0.003
@export var camera: Camera3D # Pode arrastar no Inspetor ou o script acha sozinho

@onready var ray_cast: RayCast3D = $Camera3D/RayCast3D

# Guarda o ângulo vertical do olhar (olhar para cima e para baixo)
var rotation_x: float = 0.0

func _ready() -> void:
	# Se a câmera não foi arrastada no Inspetor, tenta achar no nó filho
	if camera == null:
		camera = get_node_or_null("Camera3D")
	
	# Trava o cursor no centro da tela e esconde
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	# Solta/trava o mouse com ESC
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Processa o olhar do jogador com o mouse
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# 1. Rotação Horizontal (Gira o corpo todo do jogador)
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		# 2. Rotação Vertical (Gira apenas a Câmera)
		rotation_x -= event.relative.y * mouse_sensitivity
		# Limita a visão a 85 graus para cima e 85 graus para baixo
		rotation_x = clamp(rotation_x, deg_to_rad(-85.0), deg_to_rad(85.0))
		
		if camera != null:
			camera.rotation.x = rotation_x

func _process(_delta: float) -> void:
	# Lógica do RayCast e Interação com E
	if Input.is_action_just_pressed("interact"):
		if ray_cast != null and ray_cast.is_colliding():
			var objeto = ray_cast.get_collider()
			
			var alvo = null
			if objeto.is_in_group("interativo"):
				alvo = objeto
			elif objeto.get_parent() != null and objeto.get_parent().is_in_group("interativo"):
				alvo = objeto.get_parent()
				
			if alvo != null:
				print("Interagindo com: ", alvo.name)
				if alvo.has_method("interagir"):
					alvo.interagir()
			else:
				print("Objeto '", objeto.name, "' não é interativo.")

func _physics_process(delta: float) -> void:
	# Aplica gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Pulo (Espaço)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Captura direção do movimento (WASD ou Setas)
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Caso ainda prefira usar W A S D manuais:
	if input_dir == Vector2.ZERO:
		if Input.is_physical_key_pressed(KEY_A): input_dir.x -= 1.0
		if Input.is_physical_key_pressed(KEY_D): input_dir.x += 1.0
		if Input.is_physical_key_pressed(KEY_W): input_dir.y -= 1.0
		if Input.is_physical_key_pressed(KEY_S): input_dir.y += 1.0
		input_dir = input_dir.normalized()

	# Calcula direção vetorial baseada para onde o jogador está olhando no plano XZ
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction != Vector3.ZERO:
		velocity.x = move_toward(velocity.x, direction.x * speed, acceleration * delta * speed)
		velocity.z = move_toward(velocity.z, direction.z * speed, acceleration * delta * speed)
	else:
		velocity.x = move_toward(velocity.x, 0, speed * delta * acceleration)
		velocity.z = move_toward(velocity.z, 0, speed * delta * acceleration)

	move_and_slide()	
