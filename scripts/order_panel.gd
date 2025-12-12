extends Control
class_name OrderPanel

signal send_order_clicked(order_text: String)

@onready var order_text_edit: TextEdit = %OrderTextEdit
@onready var send_button: Button = %SendButton

func _ready() -> void:
    send_button.pressed.connect(_on_send_button_pressed)

func _on_send_button_pressed() -> void:
    send_order_clicked.emit(order_text_edit.text)
