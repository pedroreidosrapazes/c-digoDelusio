extends Node

# --- RECURSOS DO TYCOON ---
var dinheiro: int = 50
var trigo_coletado: int = 0

# --- PROGRESSO DO DIA / EVENTO DE TERROR ---
var tarefas_dia: int = 0
@export var total_tarefas_meta: int = 5

# Guardam as referências da tela
var label_dinheiro: Label
var label_trigo: Label

func _ready() -> void:
	# Busca as labels pelos grupos cadastrados
	var nodes_dinheiro = get_tree().get_nodes_in_group("label_dinheiro")
	if nodes_dinheiro.size() > 0:
		label_dinheiro = nodes_dinheiro[0]

	var nodes_trigo = get_tree().get_nodes_in_group("label_trigo")
	if nodes_trigo.size() > 0:
		label_trigo = nodes_trigo[0]

	# Atualiza o texto na tela assim que o jogo liga
	atualizar_hud()

# Atualiza a interface sempre que um valor muda
func atualizar_hud() -> void:
	if label_dinheiro != null:
		label_dinheiro.text = "Dinheiro: R$ " + str(dinheiro)
	if label_trigo != null:
		label_trigo.text = "Trigo no Estoque: " + str(trigo_coletado)

# Adiciona ou remove dinheiro
func adicionar_dinheiro(quantidade: int) -> void:
	dinheiro += quantidade
	atualizar_hud()

# Adiciona trigo ao inventário
func adicionar_trigo(quantidade: int) -> void:
	trigo_coletado += quantidade
	atualizar_hud()

# Registra uma tarefa/colheita concluída
func registrar_tarefa() -> void:
	tarefas_dia += 1
	print("Progresso das tarefas: ", tarefas_dia, "/", total_tarefas_meta)
	if tarefas_dia >= total_tarefas_meta:
		iniciar_noite_terror()

func iniciar_noite_terror() -> void:
	print("O sol se foi. O silêncio do isolamento toma conta...")
	
	# 1. Reduz a luz do sol para criar a noite
	var sol = get_tree().current_scene.get_node_or_null("Sol") # Seu DirectionalLight3D
	if sol:
		sol.light_energy = 0.05
