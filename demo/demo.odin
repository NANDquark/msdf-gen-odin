package main

import msdf ".."
import "core:c"
import "core:fmt"
import "core:strings"

main :: proc() {
	font_path := "demo/noto-sans-latin-400-normal.ttf"

	ft := msdf.freetype_initialize()
	if ft == nil {
		fmt.eprintln("Failed to initialize FreeType")
		return
	}
	defer msdf.freetype_deinitialize(ft)

	font_path_c, _ := strings.clone_to_cstring(font_path, context.temp_allocator)
	font := msdf.font_load(ft, font_path_c)
	if font == nil {
		fmt.eprintf("Failed to load font: %s\n", font_path)
		return
	}
	defer msdf.font_destroy(font)

	shape := msdf.Shape_create()
	defer msdf.Shape_destroy(shape)

	advance: f64
	if !msdf.font_load_glyph(shape, font, 'A', .FONT_SCALING_EM_NORMALIZED, &advance) {
		fmt.eprintln("Failed to load glyph 'A'")
		return
	}

	msdf.Shape_normalize(shape)
	msdf.Shape_orientContours(shape)
	if !msdf.Shape_validate(shape) {
		fmt.eprintln("Loaded glyph shape is invalid")
		return
	}

	msdf.edgeColoringSimple(shape, 3.0, 0)

	width: c.int = 64
	height: c.int = 64
	pixels := make([]f32, int(width * height * 3))
	defer delete(pixels)
	bitmap := msdf.make_bitmap_section_f32_3(raw_data(pixels), width, height, .BOTTOM_UP)

	bounds := msdf.shape_get_bounds(shape)
	shape_width := bounds.r - bounds.l
	shape_height := bounds.t - bounds.b
	padding := 8.0
	scale := (f64(width) - 2 * padding) / max(shape_width, shape_height)
	px_range := 4.0
	unit_range := px_range / scale
	transform := msdf.make_sdf_transformation(
		scale = msdf.Vector2{scale, scale},
		translate = msdf.Vector2{-bounds.l + padding / scale, -bounds.b + padding / scale},
		range = msdf.Range{lower = -0.5 * unit_range, upper = 0.5 * unit_range},
	)
	config := msdf.make_msdf_generator_config(
		overlap_support = true,
		error_correction_mode = .EDGE_PRIORITY,
	)
	msdf.generateMSDF(&bitmap, shape, &transform, &config)

	output_path := "demo-msdf-A.png"
	output_path_c, _ := strings.clone_to_cstring(output_path, context.temp_allocator)
	if !msdf.save_png_f32_3(&bitmap, output_path_c) {
		fmt.eprintln("Failed to save PNG output")
		return
	}

	fmt.printfln("Font: %s", font_path)
	fmt.printfln("Glyph: 'A' (advance %.4f)", advance)
	fmt.printfln("MSDF saved to: %s", output_path)
}
