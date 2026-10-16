extends SceneTree

# ==============================================================================
# test_boot_splash.gd
# Validates Stage 1 (DR RANK Studio Splash) and Stage 2 (Mobile Loading & Tap)
# and renders visual snapshots of both stages.
# ==============================================================================

var _frame: int = 0
var splash_node: Control = null

func _init() -> void:
	print("==================================================================")
	print(">>> [TEST] Running BootSplash Startup Sequence Validation <<<")
	print("==================================================================")

func _process(_delta: float) -> bool:
	_frame += 1

	match _frame:
		1:
			_setup_splash_scene()
		15:
			_validate_stage1_and_capture()
		35:
			_step_into_stage2()
		70:
			_validate_stage2_loading_and_capture()
		90:
			_trigger_loading_complete()
		115:
			_validate_stage2_tap_button_and_capture()
		125:
			_finish_test()
			return true

	return false

func _setup_splash_scene() -> void:
	print("[FRAME 1] Instantiating boot_splash.tscn...")
	var scn = load("res://scenes/ui/boot_splash.tscn")
	if scn == null:
		printerr("[FAIL] Could not load res://scenes/ui/boot_splash.tscn")
		quit(1)
		return

	splash_node = scn.instantiate()
	root.add_child(splash_node)
	print("[PASS] boot_splash.tscn instantiated successfully.")

func _validate_stage1_and_capture() -> void:
	print("[FRAME 15] Validating Stage 1: DR RANK Studio Splash...")
	assert(splash_node != null, "Splash node must exist")

	var stage1 = splash_node.get_node_or_null("Stage1_DRRank")
	assert(stage1 != null, "Stage1_DRRank node must exist")
	assert(stage1.visible, "Stage 1 must be visible initially")

	var navy_bg = stage1.get_node_or_null("NavyBackground")
	assert(navy_bg != null, "NavyBackground must exist")
	print("  Navy BG Color: ", navy_bg.color)

	var radial = stage1.get_node_or_null("RadialGlow")
	assert(radial != null and radial.texture != null, "RadialGlow texture must be generated")

	var logo = stage1.get_node_or_null("LogoContainer/StudioLogo")
	assert(logo != null and logo.texture != null, "StudioLogo texture must be loaded")

	var sheen = stage1.get_node_or_null("LogoContainer/SheenMask/SheenBar")
	assert(sheen != null and sheen.texture != null, "SheenBar texture must be generated")
	assert(sheen.material is CanvasItemMaterial and sheen.material.blend_mode == CanvasItemMaterial.BLEND_MODE_ADD, "Sheen must use ADD blend mode")

	var img = root.get_viewport().get_texture().get_image()
	img.save_png("c:/Users/Ian/Documents/Apps/Idle-1/boot_splash_stage1.png")
	print("[PASS] Stage 1 assertions passed. Saved boot_splash_stage1.png.")

func _step_into_stage2() -> void:
	print("[FRAME 40] Forcing transition to Stage 2...")
	if splash_node.has_method("_transition_to_stage2"):
		splash_node._transition_to_stage2()

func _validate_stage2_loading_and_capture() -> void:
	print("[FRAME 80] Validating Stage 2: Mobile Loading Screen & Sunburst...")
	var stage2 = splash_node.get_node_or_null("Stage2_Diner")
	assert(stage2 != null, "Stage2_Diner node must exist")

	var sunburst = stage2.get_node_or_null("SunburstBackground")
	assert(sunburst != null and sunburst.texture != null, "Sunburst background must be loaded")

	var title = stage2.get_node_or_null("TitleContainer/TitleLogo")
	assert(title != null and title.texture != null, "TitleLogo must be loaded")

	var bar_container = stage2.get_node_or_null("BottomControls/LoadingBarContainer")
	assert(bar_container != null, "LoadingBarContainer must exist")

	var label = stage2.get_node_or_null("BottomControls/LoadingBarContainer/LoadingLabel")
	assert(label != null, "LoadingLabel must exist")
	print("  Current Loading Status: ", label.text)

	var watermark = stage2.get_node_or_null("WatermarkLabel")
	assert(watermark != null, "WatermarkLabel must exist")
	assert("DR RANK" in watermark.text, "Watermark must mention DR RANK")

	var img = root.get_viewport().get_texture().get_image()
	img.save_png("c:/Users/Ian/Documents/Apps/Idle-1/boot_splash_stage2.png")
	print("[PASS] Stage 2 loading assertions passed. Saved boot_splash_stage2.png.")

func _trigger_loading_complete() -> void:
	print("[FRAME 90] Triggering loading complete transition...")
	if splash_node.has_method("_on_loading_complete"):
		splash_node._on_loading_complete()

func _validate_stage2_tap_button_and_capture() -> void:
	print("[FRAME 115] Validating Stage 2: 100% Completion & TAP TO START Button...")
	var tap_btn = splash_node.get_node_or_null("Stage2_Diner/BottomControls/TapToPlayButton")
	assert(tap_btn != null, "TapToPlayButton must exist")
	assert(tap_btn.visible, "TapToPlayButton must be visible when loading finishes")
	assert(tap_btn.modulate.a > 0.8, "TapToPlayButton must be fully faded in")
	assert("TAP TO START" in tap_btn.text, "Button text must contain TAP TO START")

	var bar_container = splash_node.get_node_or_null("Stage2_Diner/BottomControls/LoadingBarContainer")
	assert(bar_container != null and not bar_container.visible, "Loading bar container must be hidden once TAP button appears")

	var img = root.get_viewport().get_texture().get_image()
	img.save_png("c:/Users/Ian/Documents/Apps/Idle-1/boot_splash_tap_to_start.png")
	print("[PASS] TAP TO START button assertions passed. Saved boot_splash_tap_to_start.png.")

func _finish_test() -> void:
	print("\n==================================================================")
	print(">>> [SUCCESS] All BootSplash startup sequence tests passed! <<<")
	print("==================================================================")
	quit(0)
