extends Control

# ==============================================================================
# BootSplash (boot_splash.gd)
# Implements two-stage mobile startup sequence:
# Stage 1 (0.0s - 2.2s): "DR RANK" Studio Splash with elastic bounce, sheen sweep,
#                         and synth chime stinger.
# Stage 2 (2.2s - 4.5s): Mobile game loading screen with sunburst bg, floating title,
#                         golden beveled loading bar, and pulsing "TAP TO START" button.
# ==============================================================================

@onready var stage1: Control = $Stage1_DRRank
@onready var stage2: Control = $Stage2_Diner
@onready var navy_bg: ColorRect = $Stage1_DRRank/NavyBackground
@onready var radial_glow: TextureRect = $Stage1_DRRank/RadialGlow
@onready var studio_logo_container: Control = $Stage1_DRRank/LogoContainer
@onready var studio_logo: TextureRect = $Stage1_DRRank/LogoContainer/StudioLogo
@onready var sheen_mask: Control = $Stage1_DRRank/LogoContainer/SheenMask
@onready var sheen_bar: TextureRect = $Stage1_DRRank/LogoContainer/SheenMask/SheenBar

@onready var sunburst_bg: TextureRect = $Stage2_Diner/SunburstBackground
@onready var title_container: Control = $Stage2_Diner/TitleContainer
@onready var title_logo: TextureRect = $Stage2_Diner/TitleContainer/TitleLogo

@onready var bottom_controls: Control = $Stage2_Diner/BottomControls
@onready var loading_bar_container: Control = $Stage2_Diner/BottomControls/LoadingBarContainer
@onready var bar_fill_clip: Control = $Stage2_Diner/BottomControls/LoadingBarContainer/BarFillClip
@onready var bar_fill: Panel = $Stage2_Diner/BottomControls/LoadingBarContainer/BarFillClip/BarFill
@onready var loading_label: Label = $Stage2_Diner/BottomControls/LoadingBarContainer/LoadingLabel
@onready var tap_button: Button = $Stage2_Diner/BottomControls/TapToPlayButton
@onready var watermark_label: Label = $Stage2_Diner/WatermarkLabel

@onready var fade_overlay: ColorRect = $FadeOverlay

var _game_started: bool = false
var _loading_progress: float = 0.0
var _bar_max_width: float = 480.0
var _pulse_tween: Tween = null
var _floating_tween: Tween = null
var _bar_tween: Tween = null

const STATUS_TEXTS = [
	"Prepping Kitchen Stoves...",
	"Polishing Mahogany Bar...",
	"Chilling Milkshakes...",
	"Opening Idle Diner..."
]

func should_skip_splash() -> bool:
	if DisplayServer.get_name() == "headless":
		return true
	var gm = get_node_or_null("/root/GameManager")
	if gm != null and gm.get("skip_boot_splash") == true:
		return true
	for arg in OS.get_cmdline_args():
		if "run_all_tests.gd" in arg:
			return true
	return false

func _ready() -> void:
	if should_skip_splash():
		_game_started = true
		call_deferred("_transition_to_main")
		return

	# Ensure audio ambience is stopped during boot sequence
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("stop_ambience"):
		am.stop_ambience()

	_setup_textures()
	_setup_radial_glow()
	_setup_sheen_gradient()

	# Initial states
	stage1.visible = true
	stage1.modulate.a = 1.0
	stage2.visible = true
	stage2.modulate.a = 0.0

	fade_overlay.visible = true
	fade_overlay.modulate.a = 0.0

	tap_button.visible = false
	tap_button.modulate.a = 0.0
	tap_button.pivot_offset = tap_button.size * 0.5
	tap_button.pressed.connect(_on_tap_to_start_pressed)

	_bar_max_width = loading_bar_container.size.x
	bar_fill.custom_minimum_size = Vector2(_bar_max_width, loading_bar_container.size.y)
	_update_bar_display(0.0)

	# Launch sequence
	_play_stage1_studio_splash()

func _setup_textures() -> void:
	# 1. DR RANK studio logo
	var dr_rank_tex = _load_dynamic_texture("res://assets/textures/dr_rank_logo.png")
	if dr_rank_tex != null:
		studio_logo.texture = dr_rank_tex

	# 2. Sunburst mobile splash background
	var bg_tex = _load_dynamic_texture("res://assets/textures/splash_bg_pattern.png")
	if bg_tex != null:
		sunburst_bg.texture = bg_tex

	# 3. Game title logo
	var title_tex = _load_dynamic_texture("res://assets/textures/idle_diner_title_logo.png")
	if title_tex != null:
		title_logo.texture = title_tex

func _load_dynamic_texture(res_path: String) -> Texture2D:
	var global_path = ProjectSettings.globalize_path(res_path)
	if FileAccess.file_exists(global_path):
		var img = Image.load_from_file(global_path)
		if img != null and not img.is_empty():
			return ImageTexture.create_from_image(img)
	if ResourceLoader.exists(res_path):
		var res = load(res_path)
		if res is Texture2D:
			return res
	return null

func _setup_radial_glow() -> void:
	var grad = Gradient.new()
	grad.colors = PackedColorArray([
		Color(0.18, 0.52, 0.95, 0.45), # Bright cyan/royal core
		Color(0.09, 0.28, 0.60, 0.22), # Mid blue glow
		Color(0.051, 0.075, 0.133, 0.0) # Fades out to deep navy
	])
	grad.offsets = PackedFloat32Array([0.0, 0.45, 1.0])

	var grad_tex = GradientTexture2D.new()
	grad_tex.gradient = grad
	grad_tex.fill = GradientTexture2D.FILL_RADIAL
	grad_tex.fill_from = Vector2(0.5, 0.5)
	grad_tex.fill_to = Vector2(0.5, 0.0)
	grad_tex.width = 512
	grad_tex.height = 512

	radial_glow.texture = grad_tex

func _setup_sheen_gradient() -> void:
	var sheen_grad = Gradient.new()
	sheen_grad.colors = PackedColorArray([
		Color(1.0, 1.0, 1.0, 0.0),
		Color(1.0, 1.0, 1.0, 0.85),
		Color(1.0, 1.0, 1.0, 0.0)
	])
	sheen_grad.offsets = PackedFloat32Array([0.0, 0.5, 1.0])

	var sheen_tex = GradientTexture2D.new()
	sheen_tex.gradient = sheen_grad
	sheen_tex.width = 120
	sheen_tex.height = 360

	sheen_bar.texture = sheen_tex
	sheen_bar.rotation_degrees = -25.0
	sheen_bar.position = Vector2(-260, -50)
	sheen_bar.visible = false

	var add_mat = CanvasItemMaterial.new()
	add_mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	sheen_bar.material = add_mat

# ──────────────────────────────────────────────────────────────────────────────
# STAGE 1 — "DR RANK" Studio Splash (0.0s to 2.2s)
# ──────────────────────────────────────────────────────────────────────────────
func _play_stage1_studio_splash() -> void:
	# Center pivot offset for elastic scaling
	studio_logo_container.pivot_offset = studio_logo_container.size * 0.5
	studio_logo_container.scale = Vector2(0.4, 0.4)
	studio_logo_container.modulate.a = 0.0

	var tw = create_tween()
	# Step 1: Scale in with elastic bounce (0.4 -> 1.08 over 0.36s, then 1.08 -> 1.0 over 0.19s)
	tw.parallel().tween_property(studio_logo_container, "modulate:a", 1.0, 0.22)
	tw.parallel().tween_property(studio_logo_container, "scale", Vector2(1.08, 1.08), 0.36).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.chain().tween_property(studio_logo_container, "scale", Vector2(1.0, 1.0), 0.19).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# Sound cue right when emblem expands
	tw.parallel().tween_callback(func():
		var am = get_node_or_null("/root/AudioManager")
		if am != null and am.has_method("play_studio_stinger"):
			am.play_studio_stinger()
	)

	# Step 2: Sweep additive light sheen across emblem over 0.50s
	tw.tween_interval(0.12)
	tw.tween_callback(func():
		sheen_bar.visible = true
		sheen_bar.position.x = -260.0
	)
	tw.tween_property(sheen_bar, "position:x", studio_logo_container.size.x + 220.0, 0.52).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tw.tween_callback(func():
		sheen_bar.visible = false
	)

	# Step 3: Hold emblem, then trigger transition to Stage 2 at ~2.0s
	tw.tween_interval(0.65)
	tw.tween_callback(_transition_to_stage2)

# ──────────────────────────────────────────────────────────────────────────────
# STAGE 2 — Mobile Game Loading Screen & "TAP TO START" (2.2s to 4.5s)
# ──────────────────────────────────────────────────────────────────────────────
func _transition_to_stage2() -> void:
	# Cross-fade Stage 1 -> Stage 2
	var cross_tw = create_tween()
	cross_tw.parallel().tween_property(stage1, "modulate:a", 0.0, 0.35)
	cross_tw.parallel().tween_property(stage2, "modulate:a", 1.0, 0.35)

	# Idle floating tween for game title logo
	_start_title_floating()

	# Start golden loading bar fill (0% -> 100%)
	_start_loading_bar()

func _start_title_floating() -> void:
	if _floating_tween != null:
		_floating_tween.kill()

	var orig_y = title_container.position.y
	_floating_tween = create_tween().set_loops()
	_floating_tween.tween_property(title_container, "position:y", orig_y - 8.0, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_floating_tween.tween_property(title_container, "position:y", orig_y + 4.0, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _start_loading_bar() -> void:
	_loading_progress = 0.0
	_update_bar_display(0.0)

	_bar_tween = create_tween()
	# Fills from 0% to 100% smoothly over 1.7s
	_bar_tween.tween_method(_on_progress_update, 0.0, 1.0, 1.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	_bar_tween.tween_callback(_on_loading_complete)

func _on_progress_update(val: float) -> void:
	_loading_progress = val
	_update_bar_display(val)

func _update_bar_display(val: float) -> void:
	var clamped_val = clampf(val, 0.0, 1.0)
	bar_fill_clip.size = Vector2(clamped_val * _bar_max_width, loading_bar_container.size.y)

	var pct = int(clamped_val * 100.0)
	var status_idx = 0
	if clamped_val < 0.25:
		status_idx = 0
	elif clamped_val < 0.55:
		status_idx = 1
	elif clamped_val < 0.85:
		status_idx = 2
	else:
		status_idx = 3

	loading_label.text = "%s %d%%" % [STATUS_TEXTS[status_idx], pct]

func _on_loading_complete() -> void:
	if _bar_tween != null:
		_bar_tween.kill()
		_bar_tween = null
	_loading_progress = 1.0
	_update_bar_display(1.0)

	# Reveal TAP TO START button immediately with smooth transition
	tap_button.visible = true
	tap_button.modulate.a = 0.0
	tap_button.scale = Vector2(0.85, 0.85)
	tap_button.pivot_offset = tap_button.size * 0.5

	var tw = create_tween()
	tw.parallel().tween_property(loading_bar_container, "modulate:a", 0.0, 0.2)
	tw.parallel().tween_property(tap_button, "modulate:a", 1.0, 0.25)
	tw.parallel().tween_property(tap_button, "scale", Vector2(1.0, 1.0), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func():
		loading_bar_container.visible = false
		_start_button_pulse()
	)

	# 1.5s auto-start fallback timer so tests and unattended runs never stall
	get_tree().create_timer(1.5).timeout.connect(func():
		if not _game_started:
			_start_game()
	)

func _start_button_pulse() -> void:
	if _pulse_tween != null:
		_pulse_tween.kill()
	_pulse_tween = create_tween().set_loops()
	_pulse_tween.tween_property(tap_button, "scale", Vector2(1.06, 1.06), 0.65).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_pulse_tween.tween_property(tap_button, "scale", Vector2(1.0, 1.0), 0.65).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _gui_input(event: InputEvent) -> void:
	# Allow tapping anywhere on screen once in Stage 2 to start immediately
	if (event is InputEventMouseButton and event.pressed) or (event is InputEventScreenTouch and event.pressed):
		if not _game_started:
			_start_game()

func _on_tap_to_start_pressed() -> void:
	_start_game()

func _start_game() -> void:
	if _game_started:
		return
	_game_started = true

	if _pulse_tween != null:
		_pulse_tween.kill()
	if _floating_tween != null:
		_floating_tween.kill()
	if _bar_tween != null:
		_bar_tween.kill()

	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("play_sfx"):
		am.play_sfx("click")

	# Smooth fade out to main scene
	var fade_tw = create_tween()
	fade_tw.tween_property(fade_overlay, "modulate:a", 1.0, 0.35)
	fade_tw.tween_callback(_transition_to_main)

func _transition_to_main() -> void:
	# Restart restaurant audio ambience
	var am = get_node_or_null("/root/AudioManager")
	if am != null and am.has_method("start_ambience"):
		am.start_ambience()

	if is_inside_tree() and get_tree().current_scene == self:
		get_tree().change_scene_to_file("res://scenes/main.tscn")
	else:
		# If running as high-priority CanvasLayer overlay child
		queue_free()
