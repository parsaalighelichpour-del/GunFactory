extends Control

var coins: int = 120
var workshop_level: int = 1
var style_index: int = 0
var styles := ["نئون آبی", "کهکشانی", "طلایی", "یخی"]

var coins_label: Label
var level_label: Label
var style_label: Label
var message_label: Label
var display_label: Label

func _ready() -> void:
    _build_ui()
    _refresh()

func _build_ui() -> void:
    var bg := ColorRect.new()
    bg.color = Color("#10182b")
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(bg)

    var margin := MarginContainer.new()
    margin.name = "MarginContainer"
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    margin.add_theme_constant_override("margin_left", 22)
    margin.add_theme_constant_override("margin_right", 22)
    margin.add_theme_constant_override("margin_top", 22)
    margin.add_theme_constant_override("margin_bottom", 22)
    add_child(margin)

    var layout := VBoxContainer.new()
    layout.name = "VBoxContainer"
    layout.add_theme_constant_override("separation", 14)
    margin.add_child(layout)

    var title := Label.new()
    title.text = "🏭 کارگاه گان فکتوری"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 28)
    layout.add_child(title)

    var subtitle := Label.new()
    subtitle.text = "یک بازی مدیریتی و خیالی؛ طراحی، سفارش و ارتقای کارگاه"
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    subtitle.add_theme_color_override("font_color", Color("#b8c8e8"))
    layout.add_child(subtitle)

    coins_label = Label.new()
    level_label = Label.new()
    style_label = Label.new()
    for item in [coins_label, level_label, style_label]:
        item.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        item.add_theme_font_size_override("font_size", 20)
        layout.add_child(item)

    var display := PanelContainer.new()
    display.custom_minimum_size = Vector2(0, 110)
    display_label = Label.new()
    display_label.text = "◇  نمونه نمایشی انتزاعی  ◇"
    display_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    display_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    display_label.add_theme_font_size_override("font_size", 23)
    display.add_child(display_label)
    layout.add_child(display)

    var change_button := Button.new()
    change_button.text = "🎨 تغییر طرح نمایشی"
    change_button.custom_minimum_size.y = 52
    change_button.pressed.connect(_change_style)
    layout.add_child(change_button)

    var order_button := Button.new()
    order_button.text = "📦 تحویل سفارش بات‌ها  (+۴۰ سکه)"
    order_button.custom_minimum_size.y = 52
    order_button.pressed.connect(_deliver_order)
    layout.add_child(order_button)

    var upgrade_button := Button.new()
    upgrade_button.text = "⬆️ ارتقای کارگاه"
    upgrade_button.custom_minimum_size.y = 52
    upgrade_button.pressed.connect(_upgrade)
    layout.add_child(upgrade_button)

    message_label = Label.new()
    message_label.text = "سفارش‌های خیالی را تحویل بده و کارگاهت را گسترش بده!"
    message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    message_label.add_theme_color_override("font_color", Color("#9de5c2"))
    layout.add_child(message_label)

func _refresh() -> void:
    coins_label.text = "🪙 سکه‌ها: %d" % coins
    level_label.text = "⭐ سطح کارگاه: %d" % workshop_level
    style_label.text = "طرح فعلی: %s" % styles[style_index]
    display_label.text = "◇  %s  ◇" % styles[style_index]

func _change_style() -> void:
    style_index = (style_index + 1) % styles.size()
    message_label.text = "طرح جدید انتخاب شد!"
    _refresh()

func _deliver_order() -> void:
    coins += 40
    message_label.text = "سفارش نمایشی تحویل شد؛ ۴۰ سکه گرفتی!"
    _refresh()

func _upgrade() -> void:
    var cost := workshop_level * 100
    if coins < cost:
        message_label.text = "برای ارتقا به %d سکه نیاز داری." % cost
        return
    coins -= cost
    workshop_level += 1
    message_label.text = "آفرین! کارگاهت ارتقا پیدا کرد."
    _refresh()
