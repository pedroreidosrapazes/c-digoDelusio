extends Node3D

var estado: int = 0 # 0 = Vazio, 1 = Crescendo, 2 = Pronto

func _ready() -> void:
	add_to_group("interativo")

func interagir() -> void:
	if estado == 0:
		print("Semente plantada! Crescendo...")
		estado = 1
		if has_node("MeshInstance3D"):
			$MeshInstance3D.scale = Vector3(0.5, 0.5, 0.5)
		
		await get_tree().create_timer(5.0).timeout
		
		estado = 2
		if has_node("MeshInstance3D"):
			$MeshInstance3D.scale = Vector3(1.5, 1.5, 1.5)
		print("Trigo pronto para colher!")

	elif estado == 2:
		print("Trigo colhido com sucesso!")
		
		var manager = get_tree().current_scene.get_node_or_null("GameManager")
		if manager:
			manager.adicionar_trigo(1)
			manager.registrar_tarefa()
			
		estado = 0
		if has_node("MeshInstance3D"):
			$MeshInstance3D.scale = Vector3(1.0, 1.0, 1.0)
