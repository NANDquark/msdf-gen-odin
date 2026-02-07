package msdfgen

import "core:c"
import "core:math"
import "core:os"
import "core:strings"
import "core:testing"

@(test)
abi_layout_matches_c_api :: proc(t: ^testing.T) {
	_ = t
	assert(size_of(Vector2) == 16)
	assert(size_of(Range) == 16)
	assert(size_of(Projection) == 32)
	assert(size_of(SDFTransformation) == 48)

	assert(size_of(BitmapSection_F32_1) == 24)
	assert(size_of(BitmapSection_F32_3) == 24)
	assert(size_of(BitmapSection_F32_4) == 24)

	assert(size_of(GeneratorConfig) == 1)
	assert(size_of(ErrorCorrectionConfig) == 32)
	assert(size_of(MSDFGeneratorConfig) == 40)

	assert(offset_of(Projection, scale) == 0)
	assert(offset_of(Projection, translate) == 16)
	assert(offset_of(SDFTransformation, projection) == 0)
	assert(offset_of(SDFTransformation, range) == 32)
	assert(offset_of(MSDFGeneratorConfig, base) == 0)
	assert(offset_of(MSDFGeneratorConfig, errorCorrection) == 8)
}

@(test)
helpers_return_expected_defaults :: proc(t: ^testing.T) {
	_ = t
	gen_cfg := make_generator_config()
	assert(gen_cfg.overlapSupport == false)

	msdf_cfg := make_msdf_generator_config(
		overlap_support = true,
		error_correction_mode = .EDGE_PRIORITY,
	)
	assert(msdf_cfg.base.overlapSupport == true)
	assert(msdf_cfg.errorCorrection.mode == .EDGE_PRIORITY)
	assert(msdf_cfg.errorCorrection.distanceCheckMode == .DO_NOT_CHECK_DISTANCE)
	assert(msdf_cfg.errorCorrection.minDeviationRatio == 1.11)
	assert(msdf_cfg.errorCorrection.minImproveRatio == 1.1)
	assert(msdf_cfg.errorCorrection.buffer == nil)

	transform := make_sdf_transformation(
		scale = Vector2{2.0, 3.0},
		translate = Vector2{4.0, 5.0},
		range = Range{lower = -4.0, upper = 4.0},
	)
	assert(transform.projection.scale.x == 2.0)
	assert(transform.projection.scale.y == 3.0)
	assert(transform.projection.translate.x == 4.0)
	assert(transform.projection.translate.y == 5.0)
	assert(transform.range.lower == -4.0)
	assert(transform.range.upper == 4.0)
}

@(test)
generate_msdf_from_triangle :: proc(t: ^testing.T) {
	_ = t
	shape := Shape_create()
	assert(shape != nil)
	defer Shape_destroy(shape)

	contour := Contour_create()
	assert(contour != nil)
	defer Contour_destroy(contour)

	Contour_addEdgeLinear(contour, Vector2{0, 0}, Vector2{1, 0}, .WHITE)
	Contour_addEdgeLinear(contour, Vector2{1, 0}, Vector2{0.5, 1}, .WHITE)
	Contour_addEdgeLinear(contour, Vector2{0.5, 1}, Vector2{0, 0}, .WHITE)

	Shape_addContour(shape, contour)
	Shape_normalize(shape)
	assert(Shape_validate(shape))

	edgeColoringSimple(shape, 3.0, 0)

	bounds := shape_get_bounds(shape)
	assert(bounds.r > bounds.l)
	assert(bounds.t > bounds.b)

	width: c.int = 16
	height: c.int = 16
	pixels := make([]f32, int(width*height*3))
	defer delete(pixels)

	bitmap := make_bitmap_section_f32_3(raw_data(pixels), width, height, .BOTTOM_UP)
	transform := make_sdf_transformation(
		scale = Vector2{12.0, 12.0},
		translate = Vector2{2.0, 2.0},
		range = Range{lower = -4.0, upper = 4.0},
	)
	config := make_msdf_generator_config(
		overlap_support = true,
		error_correction_mode = .EDGE_PRIORITY,
	)
	generateMSDF(&bitmap, shape, &transform, &config)

	non_zero_count := 0
	for value in pixels {
		assert(!math.is_nan(f64(value)))
		assert(!math.is_inf(f64(value)))
		if value != 0 {
			non_zero_count += 1
		}
	}
	assert(non_zero_count > 0)
}

find_system_font_path :: proc() -> string {
	candidates := [?]string{
		"/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
		"/usr/share/fonts/dejavu/DejaVuSans.ttf",
		"/usr/share/fonts/TTF/DejaVuSans.ttf",
		"/usr/share/fonts/liberation/LiberationSans-Regular.ttf",
	}
	for path in candidates {
		if os.exists(path) {
			return path
		}
	}
	return ""
}

@(test)
ext_font_to_msdf_png :: proc(t: ^testing.T) {
	when ODIN_OS != .Linux {
		return
	}

	font_path := find_system_font_path()
	// Skip if no system font is available on this machine.
	if font_path == "" {
		return
	}
	ok := true

	ft := freetype_initialize()
	ok = testing.expectf(t, ft != nil, "Failed to initialize FreeType")
	if !ok {
		return
	}
	defer freetype_deinitialize(ft)

	font_path_c, _ := strings.clone_to_cstring(font_path, context.temp_allocator)
	font := font_load(ft, font_path_c)
	ok = testing.expectf(t, font != nil, "Failed to load font: %s", font_path)
	if !ok {
		return
	}
	defer font_destroy(font)

	shape := Shape_create()
	assert(shape != nil)
	defer Shape_destroy(shape)

	advance: f64
	ok = font_load_glyph(shape, font, u32('A'), .FONT_SCALING_EM_NORMALIZED, &advance)
	ok = testing.expectf(t, ok, "Failed to load glyph 'A' from font")
	if !ok {
		return
	}

	Shape_normalize(shape)
	assert(Shape_validate(shape))
	Shape_orientContours(shape)
	edgeColoringSimple(shape, 3.0, 0)

	width: c.int = 48
	height: c.int = 48
	pixels := make([]f32, int(width*height*3))
	defer delete(pixels)
	bitmap := make_bitmap_section_f32_3(raw_data(pixels), width, height, .BOTTOM_UP)

	bounds := shape_get_bounds(shape)
	shape_width := bounds.r - bounds.l
	shape_height := bounds.t - bounds.b
	scale := 36.0 / max(shape_width, shape_height)
	transform := make_sdf_transformation(
		scale = Vector2{scale, scale},
		translate = Vector2{
			-bounds.l*scale + 6.0,
			-bounds.b*scale + 6.0,
		},
		range = Range{lower = -4.0, upper = 4.0},
	)
	config := make_msdf_generator_config(
		overlap_support = true,
		error_correction_mode = .EDGE_PRIORITY,
	)
	generateMSDF(&bitmap, shape, &transform, &config)

	output_path := "/tmp/msdfgen_ext_test_A.png"
	_ = os.remove(output_path)
	output_path_c, _ := strings.clone_to_cstring(output_path, context.temp_allocator)
	ok = save_png_f32_3(&bitmap, output_path_c)
	ok = testing.expectf(t, ok, "Failed to save PNG output")
	if !ok {
		return
	}
	assert(os.exists(output_path))
}
