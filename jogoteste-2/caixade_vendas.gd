extends StaticBody3D

@export var preco_por_trigo: int = 15

func _ready() -> void:
	add_to_group("interativo")

func interagir() -> void:
	var manager = get_tree().current_scene.get_node_or_null("GameManager")
	
	if manager != null:
		if manager.trigo_coletado > 0:
			# Calcula o valor total das vendas
			var valor_total = manager.trigo_coletado * preco_por_trigo
			
			# Adiciona o dinheiro ganho
			manager.adicionar_dinheiro(valor_total)
			print("Venda realizada! Você vendeu ", manager.trigo_coletado, " trigo(s) por R$", valor_total)
			
			# Zera o estoque e registra o progresso
			manager.trigo_coletado = 0
			manager.atualizar_hud()
			manager.registrar_tarefa()
		else:
			print("Você não tem trigo no estoque para vender!")
	else:
		print("ERRO: GameManager não encontrado na cena!")
