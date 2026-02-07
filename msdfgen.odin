package msdfgen

import "core:c"

// Opaque types
Shape :: struct {}
Contour :: struct {}
FreetypeHandle :: struct {}
FontHandle :: struct {}

// Basic types
Vector2 :: struct {
	x, y: f64,
}

Range :: struct {
	lower, upper: f64,
}

Projection :: struct {
	scale:     Vector2,
	translate: Vector2,
}

SDFTransformation :: struct {
	projection: Projection,
	range:      Range,
}

YAxisOrientation :: enum c.int {
	BOTTOM_UP = 0,
	TOP_DOWN  = 1,
}

Bounds :: struct {
	l, b, r, t: f64,
}

BitmapSection_F32_1 :: struct {
	pixels:       [^]f32,
	width:        c.int,
	height:       c.int,
	rowStride:    c.int,
	yOrientation: YAxisOrientation,
}

BitmapSection_F32_3 :: struct {
	pixels:       [^]f32,
	width:        c.int,
	height:       c.int,
	rowStride:    c.int,
	yOrientation: YAxisOrientation,
}

BitmapSection_F32_4 :: struct {
	pixels:       [^]f32,
	width:        c.int,
	height:       c.int,
	rowStride:    c.int,
	yOrientation: YAxisOrientation,
}

GeneratorConfig :: struct {
	overlapSupport: bool,
}

ErrorCorrectionMode :: enum c.int {
	DISABLED,
	INDISCRIMINATE,
	EDGE_PRIORITY,
	EDGE_ONLY,
}

DistanceCheckMode :: enum c.int {
	DO_NOT_CHECK_DISTANCE,
	CHECK_DISTANCE_AT_EDGE,
	ALWAYS_CHECK_DISTANCE,
}

ErrorCorrectionConfig :: struct {
	mode:              ErrorCorrectionMode,
	distanceCheckMode: DistanceCheckMode,
	minDeviationRatio: f64,
	minImproveRatio:   f64,
	buffer:            [^]u8,
}

MSDFGeneratorConfig :: struct {
	base:            GeneratorConfig,
	errorCorrection: ErrorCorrectionConfig,
}

EdgeColor :: enum c.int {
	BLACK   = 0,
	RED     = 1,
	GREEN   = 2,
	YELLOW  = 3,
	BLUE    = 4,
	MAGENTA = 5,
	CYAN    = 6,
	WHITE   = 7,
}

// Foreign block
when ODIN_OS == .Windows {
	foreign import msdfgen_lib "build/Release/msdfgen-c.lib"
} else {
	foreign import msdfgen_lib {"build/libmsdfgen-c.a", "build/lib/msdfgen/libmsdfgen-core.a", "system:stdc++"}

	foreign import msdfgen_ext_lib {"build/libmsdfgen-ext-c.a", "build/lib/msdfgen/libmsdfgen-ext.a", "build/libmsdfgen-c.a", "build/lib/msdfgen/libmsdfgen-core.a", "system:freetype", "system:png16", "system:stdc++"}
}

@(default_calling_convention = "c")
foreign msdfgen_lib {
	// Shape API
	@(link_name = "msdfgen_Shape_create")
	Shape_create :: proc() -> ^Shape ---

	@(link_name = "msdfgen_Shape_destroy")
	Shape_destroy :: proc(shape: ^Shape) ---

	@(link_name = "msdfgen_Shape_addContour")
	Shape_addContour :: proc(shape: ^Shape, contour: ^Contour) ---

	@(link_name = "msdfgen_Shape_normalize")
	Shape_normalize :: proc(shape: ^Shape) ---

	@(link_name = "msdfgen_Shape_validate")
	Shape_validate :: proc(shape: ^Shape) -> bool ---

	@(link_name = "msdfgen_Shape_getBounds")
	Shape_getBounds :: proc(shape: ^Shape, l, b, r, t: ^f64) ---

	@(link_name = "msdfgen_Shape_orientContours")
	Shape_orientContours :: proc(shape: ^Shape) ---

	// Contour API
	@(link_name = "msdfgen_Contour_create")
	Contour_create :: proc() -> ^Contour ---

	@(link_name = "msdfgen_Contour_destroy")
	Contour_destroy :: proc(contour: ^Contour) ---

	@(link_name = "msdfgen_Contour_addEdgeLinear")
	Contour_addEdgeLinear :: proc(contour: ^Contour, p0, p1: Vector2, color: EdgeColor) ---

	@(link_name = "msdfgen_Contour_addEdgeQuadratic")
	Contour_addEdgeQuadratic :: proc(contour: ^Contour, p0, p1, p2: Vector2, color: EdgeColor) ---

	@(link_name = "msdfgen_Contour_addEdgeCubic")
	Contour_addEdgeCubic :: proc(contour: ^Contour, p0, p1, p2, p3: Vector2, color: EdgeColor) ---

	// Generation API
	@(link_name = "msdfgen_generateSDF")
	generateSDF :: proc(output: ^BitmapSection_F32_1, shape: ^Shape, transformation: ^SDFTransformation, config: ^GeneratorConfig) ---

	@(link_name = "msdfgen_generatePSDF")
	generatePSDF :: proc(output: ^BitmapSection_F32_1, shape: ^Shape, transformation: ^SDFTransformation, config: ^GeneratorConfig) ---

	@(link_name = "msdfgen_generateMSDF")
	generateMSDF :: proc(output: ^BitmapSection_F32_3, shape: ^Shape, transformation: ^SDFTransformation, config: ^MSDFGeneratorConfig) ---

	@(link_name = "msdfgen_generateMTSDF")
	generateMTSDF :: proc(output: ^BitmapSection_F32_4, shape: ^Shape, transformation: ^SDFTransformation, config: ^MSDFGeneratorConfig) ---

	// Edge coloring
	@(link_name = "msdfgen_edgeColoringSimple")
	edgeColoringSimple :: proc(shape: ^Shape, angleThreshold: f64, seed: u64) ---
}

FontCoordinateScaling :: enum c.int {
	FONT_SCALING_NONE          = 0,
	FONT_SCALING_EM_NORMALIZED = 1,
	FONT_SCALING_LEGACY        = 2,
}

@(default_calling_convention = "c")
foreign msdfgen_ext_lib {
	@(link_name = "msdfgen_ext_initializeFreetype")
	ext_initializeFreetype :: proc() -> ^FreetypeHandle ---

	@(link_name = "msdfgen_ext_deinitializeFreetype")
	ext_deinitializeFreetype :: proc(library: ^FreetypeHandle) ---

	@(link_name = "msdfgen_ext_loadFont")
	ext_loadFont :: proc(library: ^FreetypeHandle, filename: cstring) -> ^FontHandle ---

	@(link_name = "msdfgen_ext_destroyFont")
	ext_destroyFont :: proc(font: ^FontHandle) ---

	@(link_name = "msdfgen_ext_loadGlyph")
	ext_loadGlyph :: proc(output: ^Shape, font: ^FontHandle, unicode: u32, coordinate_scaling: FontCoordinateScaling, out_advance: ^f64) -> bool ---

	@(link_name = "msdfgen_ext_loadGlyphByIndex")
	ext_loadGlyphByIndex :: proc(output: ^Shape, font: ^FontHandle, glyph_index: u32, coordinate_scaling: FontCoordinateScaling, out_advance: ^f64) -> bool ---

	@(link_name = "msdfgen_ext_getGlyphIndex")
	ext_getGlyphIndex :: proc(font: ^FontHandle, unicode: u32, out_glyph_index: ^u32) -> bool ---

	@(link_name = "msdfgen_ext_savePngF32_3")
	ext_savePngF32_3 :: proc(bitmap: ^BitmapSection_F32_3, filename: cstring) -> bool ---
}

// Odin-friendly helper functions

// Get shape bounds as a struct instead of using out parameters
shape_get_bounds :: proc(shape: ^Shape) -> Bounds {
	bounds: Bounds
	Shape_getBounds(shape, &bounds.l, &bounds.b, &bounds.r, &bounds.t)
	return bounds
}

// Create a default generator config
make_generator_config :: proc(overlap_support := false) -> GeneratorConfig {
	return GeneratorConfig{overlapSupport = overlap_support}
}

// Create a default MSDF generator config
make_msdf_generator_config :: proc(
	overlap_support := false,
	error_correction_mode := ErrorCorrectionMode.DISABLED,
) -> MSDFGeneratorConfig {
	config: MSDFGeneratorConfig
	config.base.overlapSupport = overlap_support
	config.errorCorrection.mode = error_correction_mode
	config.errorCorrection.distanceCheckMode = .DO_NOT_CHECK_DISTANCE
	config.errorCorrection.minDeviationRatio = 1.11
	config.errorCorrection.minImproveRatio = 1.1
	config.errorCorrection.buffer = nil
	return config
}

// Create an SDF transformation
make_sdf_transformation :: proc(
	scale: Vector2,
	translate: Vector2,
	range: Range,
) -> SDFTransformation {
	return SDFTransformation {
		projection = Projection{scale = scale, translate = translate},
		range = range,
	}
}

// Create a bitmap section for single-channel output
make_bitmap_section_f32_1 :: proc(
	pixels: [^]f32,
	width, height: c.int,
	y_orientation := YAxisOrientation.BOTTOM_UP,
) -> BitmapSection_F32_1 {
	return BitmapSection_F32_1 {
		pixels = pixels,
		width = width,
		height = height,
		rowStride = width,
		yOrientation = y_orientation,
	}
}

// Create a bitmap section for 3-channel (RGB/MSDF) output
make_bitmap_section_f32_3 :: proc(
	pixels: [^]f32,
	width, height: c.int,
	y_orientation := YAxisOrientation.BOTTOM_UP,
) -> BitmapSection_F32_3 {
	return BitmapSection_F32_3 {
		pixels = pixels,
		width = width,
		height = height,
		rowStride = width * 3,
		yOrientation = y_orientation,
	}
}

// Create a bitmap section for 4-channel (RGBA/MTSDF) output
make_bitmap_section_f32_4 :: proc(
	pixels: [^]f32,
	width, height: c.int,
	y_orientation := YAxisOrientation.BOTTOM_UP,
) -> BitmapSection_F32_4 {
	return BitmapSection_F32_4 {
		pixels = pixels,
		width = width,
		height = height,
		rowStride = width * 4,
		yOrientation = y_orientation,
	}
}

freetype_initialize :: proc() -> ^FreetypeHandle {
	return ext_initializeFreetype()
}

freetype_deinitialize :: proc(library: ^FreetypeHandle) {
	ext_deinitializeFreetype(library)
}

font_load :: proc(library: ^FreetypeHandle, filename: cstring) -> ^FontHandle {
	return ext_loadFont(library, filename)
}

font_destroy :: proc(font: ^FontHandle) {
	ext_destroyFont(font)
}

font_load_glyph :: proc(
	output: ^Shape,
	font: ^FontHandle,
	unicode: rune,
	coordinate_scaling := FontCoordinateScaling.FONT_SCALING_EM_NORMALIZED,
	out_advance: ^f64 = nil,
) -> bool {
	out_advanced: f64
	return ext_loadGlyph(output, font, u32(unicode), coordinate_scaling, out_advance)
}

font_load_glyph_by_index :: proc(
	output: ^Shape,
	font: ^FontHandle,
	glyph_index: u32,
	coordinate_scaling := FontCoordinateScaling.FONT_SCALING_EM_NORMALIZED,
	out_advance: ^f64 = nil,
) -> bool {
	return ext_loadGlyphByIndex(output, font, glyph_index, coordinate_scaling, out_advance)
}

font_get_glyph_index :: proc(
	font: ^FontHandle,
	unicode: rune,
	out_glyph_index: ^u32 = nil,
) -> bool {
	glyph_index: u32
	dst := out_glyph_index
	if dst == nil {
		dst = &glyph_index
	}
	return ext_getGlyphIndex(font, u32(unicode), dst)
}

save_png_f32_3 :: proc(bitmap: ^BitmapSection_F32_3, filename: cstring) -> bool {
	return ext_savePngF32_3(bitmap, filename)
}
