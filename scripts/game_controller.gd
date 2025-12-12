extends Node2D
class_name GameController

@onready var armies_root: Node = $MapRoot/HQ
@onready var messengers_root: Node2D = $MapRoot/Messengers
@onready var effects_root: Node2D = $MapRoot/Effects
@onready var plan_layer: PlanDrawLayer = $MapRoot/PlanDrawLayer
@onready var order_panel: OrderPanel = $UI/OrderPanel
@onready var intel_visualizer: IntelVisualizer = $MapRoot/IntelVisualizer

@export var hq_node: Node2D
@export var pulse_effect_scene: PackedScene
@export var messenger_scene: PackedScene

var armies: Array[Army] = []
var selected_army: Army
var current_time: float = 0.0
var intel_state: IntelState

var pending_plan_path: PackedVector2Array = PackedVector2Array()

func _ready() -> void:
	intel_state = IntelState.new()
	add_child(intel_state)

	_register_existing_armies()

	if plan_layer:
		plan_layer.path_committed.connect(_on_path_committed)

	if order_panel:
		order_panel.send_order_clicked.connect(_on_send_order_clicked)

	if intel_visualizer:
		intel_visualizer.intel_state = intel_state
		intel_visualizer.game_controller = self

func _register_existing_armies() -> void:
	armies.clear()
	for child in armies_root.get_children():
		if child is Army:
			var army := child as Army
			armies.append(army)
			army.clicked.connect(_on_army_clicked)
			army.movement_completed.connect(_on_army_movement_completed)

			# Seed intel with starting position
			intel_state.update_record(
				army.army_id,
				army.global_position,
				current_time,
                "initial"
			)

func _process(delta: float) -> void:
	current_time += delta

func _on_army_clicked(army: Army) -> void:
	selected_army = army
	pending_plan_path = PackedVector2Array()
	if plan_layer:
		plan_layer.start_planning()
	# You can also update some UI text showing which general is selected.

func _on_path_committed(path_points: PackedVector2Array) -> void:
	pending_plan_path = path_points

func _on_send_order_clicked(order_text: String) -> void:
	if selected_army == null:
		return
	if pending_plan_path.size() == 0:
		return

	var order := Order.new()
	order.id = "%s_%f" % [selected_army.army_id, current_time]
	order.army_id = selected_army.army_id
	order.general_id = selected_army.general.general_id if selected_army.general != null else &""
	order.text = order_text
	order.path_points = pending_plan_path.duplicate()
	order.created_time = current_time

	if selected_army.general != null:
		var summary := selected_army.general.summarize_order(order)
		print("GENERAL ACK:", summary)

	_send_order_messenger(order, selected_army)
	pending_plan_path = PackedVector2Array()

func _send_order_messenger(order: Order, target_army: Army) -> void:
	if messenger_scene == null or hq_node == null:
		# No messenger scene set; deliver instantly
		target_army.assign_order(order)
		_trigger_order_pulse(target_army.global_position)
		return

	var path := PackedVector2Array()
	path.append(hq_node.global_position)
	path.append(target_army.global_position)

	var messenger := messenger_scene.instantiate() as Messenger
	messengers_root.add_child(messenger)
	messenger.setup_order(path, order, target_army)
	messenger.order_arrived.connect(_on_order_arrived)

	# TODO: add gold shimmer along path (ORDER visual)

func _on_order_arrived(order: Order, army: Army) -> void:
	army.assign_order(order)
	_trigger_order_pulse(army.global_position)

func _on_army_movement_completed(army: Army) -> void:
	var report_text := "Army %s has completed its assigned movement." % [army.army_id]
	_send_report_messenger(report_text, army)

func _send_report_messenger(report_text: String, source_army: Army) -> void:
	if messenger_scene == null or hq_node == null:
		intel_state.update_record(
			source_army.army_id,
			source_army.global_position,
			current_time,
            "instant_report"
		)
		_trigger_report_pulse(hq_node.global_position)
		print("REPORT:", report_text)
		return

	var path := PackedVector2Array()
	path.append(source_army.global_position)
	path.append(hq_node.global_position)

	var messenger := messenger_scene.instantiate() as Messenger
	messengers_root.add_child(messenger)
	messenger.setup_report(path, report_text, source_army)
	messenger.report_arrived.connect(_on_report_arrived)

	# TODO: add blue shimmer along path (REPORT visual)

func _on_report_arrived(report_text: String, source_army: Army) -> void:
	_trigger_report_pulse(hq_node.global_position)

	intel_state.update_record(
		source_army.army_id,
		source_army.global_position,
		current_time,
        "messenger_report"
	)

	print("REPORT:", report_text)

func _trigger_order_pulse(position: Vector2) -> void:
	if pulse_effect_scene == null:
		return
	var pulse = pulse_effect_scene.instantiate()
	effects_root.add_child(pulse)
	var gold: Color = Color(1.0, 0.84, 0.14, 1.0)
	pulse.call("start_at", position, gold)

func _trigger_report_pulse(position: Vector2) -> void:
	if pulse_effect_scene == null:
		return
	var pulse = pulse_effect_scene.instantiate()
	effects_root.add_child(pulse)
	var blue: Color = Color(0.3, 0.6, 1.0, 1.0)
	pulse.call("start_at", position, blue)
