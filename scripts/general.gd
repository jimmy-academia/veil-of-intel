extends Resource
class_name General

@export var general_id: StringName = &""
@export var display_name: String = "Unnamed"
@export var personality: String = "cautious" # bold / cunning / rigid...
@export var loyalty: float = 0.8  # 0..1
@export var competence: float = 0.7 # 0..1
@export var autonomy_mode: int = 1 # 0 strict, 1 guided, 2 free

func summarize_order(order: Order) -> String:
    # Placeholder: this is where you’d call an LLM later.
    # For now we just echo a simple summary.
    return "I, %s, understand that you want army %s to: %s" % [
        display_name,
        order.army_id,
        order.text
    ]

func decide_execution(order: Order) -> Dictionary:
    # Placeholder for personality/autonomy logic.
    # For MVP: always follow the provided path exactly.
    return { "use_path": true }
