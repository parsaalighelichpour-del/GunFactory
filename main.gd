extends Node3D

var coins := 120
var level := 1
var style_index := 0
var styles := ["نئون آبی", "کهکشانی", "طلایی", "یخی"]
var colors := [Color("#31b9ff"), Color("#a875ff"), Color("#ffc857"), Color("#8cf5e8")]
var coin_text: Label
var level_text: Label
var style_text: Label
var message: Label
var display: Node3D
var display_mat: StandardMaterial3D

func mat(color: Color, metal := 0.0) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.metallic = metal
    m.roughness = 0.35
    return m

func box(parent: Node3D, size: Vector3, pos: Vector3, color: Color) -> void:
    var mesh := BoxMesh.new()
    mesh.size = size
    var node := MeshInstance3D.new()
    node.mesh = mesh
    node.position = pos
    node.material_override = mat(color)
    parent.add_child(node)

func _ready() -> void:
    var env_node := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_SKY
    env.sky = Sky.new()
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color("#a9c5e8")
    env.ambient_light_energy = 0.7
    env_node.environment = env
    add_child(env_node)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48, -32, 0)
    sun.light_energy = 1.4
    add_child(sun)

    box(self, Vector3(14, 0.3, 14), Vector3(0, -0.25, 0), Color("#26364d"))
    box(self, Vector3(14, 5, 0.25), Vector3(0, 2.25, -6.8), Color("#344a66"))
    box(self, Vector3(0.25, 5, 14), Vector3(-6.8, 2.25, 0), Color("#2b405c"))
    box(self, Vector3(5.2, 0.35, 2.4), Vector3(0, 1.05, -0.4), Color("#8b654d"))
    for x in [-2.25, 2.25]:
        for z in [-1.25, 0.45]:
            box(self, Vector3(0.22, 1.05, 0.22), Vector3(x, 0.4, z), Color("#604633"))
    box(self, Vector3(3.6, 0.18, 0.7), Vector3(3.8, 2.5, -5.8), Color("#76563f"))
    box(self, Vector3(3.6, 0.18, 0.7), Vector3(3.8, 3.65, -5.8), Color("#76563f"))
    for i in range(3):
        box(self, Vector3(0.7, 0.72, 0.52), Vector3(2.6 + i * 1.15, 3.05, -5.8), Color("#527b9e"))
        box(self, Vector3(0.7, 0.72, 0.52), Vector3(2.6 + i * 1.15, 4.15, -5.8), Color("#8c6eb3"))

    # Abstract decorative collectible only; not a functional weapon model.
    display = Node3D.new()
    display.position = Vector3(0, 1.65, -0.35)
    add_child(display)
    var core := MeshInstance3D.new()
    var capsule := CapsuleMesh.new()
    capsule.radius = 0.34
    capsule.height = 1.7
    core.mesh = capsule
    core.rotation_degrees.z = 90
    display_mat = mat(colors[style_index], 0.55)
    core.material_override = display_mat
    display.add_child(core)
    var ring := MeshInstance3D.new()
    var torus := TorusMesh.new()
    torus.inner_radius = 0.42
    torus.outer_radius = 0.49
    ring.mesh = torus
    ring.position.y = 0.12
    ring.material_override = mat(Color("#d7eaff"), 0.7)
    display.add_child(ring)

    var camera := Camera3D.new()
    camera.position = Vector3(8.5, 8.5, 11.5)
    camera.look_at(Vector3(0, 1.0, -1.0), Vector3.UP)
    camera.current = true
    add_child(camera)
    _build_ui()
    refresh()

func _build_ui() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)
    var panel := PanelContainer.new()
    panel.anchor_left = 0.02
    panel.anchor_top = 0.02
    panel.anchor_right = 0.98
    panel.offset_bottom = 225
    var skin := StyleBoxFlat.new()
    skin.bg_color = Color(0.035, 0.07, 0.13, 0.93)
    skin.border_color = Color("#3986bd")
    skin.set_border_width_all(2)
    skin.set_corner_radius_all(14)
    skin.content_margin_left = 10
    skin.content_margin_right = 10
    skin.content_margin_top = 8
    skin.content_margin_bottom = 8
    panel.add_theme_stylebox_override("panel", skin)
    layer.add_child(panel)
    var layout := VBoxContainer.new()
    layout.add_theme_constant_override("separation", 5)
    panel.add_child(layout)
    var title := Label.new()
    title.text = "🏭 GUN FACTORY | کارگاه من"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 22)
    layout.add_child(title)
    var stats := HBoxContainer.new()
    stats.alignment = BoxContainer.ALIGNMENT_CENTER
    layout.add_child(stats)
    coin_text = Label.new()
    level_text = Label.new()
    stats.add_child(coin_text)
    stats.add_child(level_text)
    style_text = Label.new()
    style_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    layout.add_child(style_text)
    var row := HBoxContainer.new()
    row.alignment = BoxContainer.ALIGNMENT_CENTER
    layout.add_child(row)
    add_button(row, "🎨 طرح", change_style)
    add_button(row, "📦 سفارش +۴۰", deliver_order)
    add_button(row, "⬆ ارتقا", upgrade)
    message = Label.new()
    message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    message.add_theme_color_override("font_color", Color("#a6f3d0"))
    layout.add_child(message)

func add_button(parent: HBoxContainer, caption: String, action: Callable) -> void:
    var b := Button.new()
    b.text = caption
    b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    b.custom_minimum_size.y = 46
    b.pressed.connect(action)
    parent.add_child(b)

func refresh() -> void:
    coin_text.text = "🪙 %d سکه   " % coins
    level_text.text = "⭐ سطح %d" % level
    style_text.text = "🎨 طرح فعلی: %s" % styles[style_index]
    display_mat.albedo_color = colors[style_index]

func change_style() -> void:
    style_index = (style_index + 1) % styles.size()
    message.text = "طرح نمایشی جدید انتخاب شد!"
    refresh()

func deliver_order() -> void:
    coins += 40
    message.text = "سفارش خیالی بات‌ها تحویل شد؛ ۴۰ سکه گرفتی!"
    refresh()

func upgrade() -> void:
    var cost := level * 100
    if coins < cost:
        message.text = "برای ارتقا به %d سکه نیاز داری." % cost
        return
    coins -= cost
    level += 1
    message.text = "کارگاه ارتقا پیدا کرد! سطح جدید: %d" % level
    refresh()

func _process(delta: float) -> void:
    if display:
        display.rotate_y(delta * 0.45)
