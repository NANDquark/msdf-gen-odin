#include "msdfgen_ext_c.h"

#include "../lib/msdfgen/msdfgen-ext.h"

using namespace msdfgen;

extern "C" {

msdfgen_FreetypeHandle *msdfgen_ext_initializeFreetype(void) {
	return (msdfgen_FreetypeHandle *) initializeFreetype();
}

void msdfgen_ext_deinitializeFreetype(msdfgen_FreetypeHandle *library) {
	deinitializeFreetype((FreetypeHandle *) library);
}

msdfgen_FontHandle *msdfgen_ext_loadFont(msdfgen_FreetypeHandle *library, const char *filename) {
	if (!library || !filename)
		return NULL;
	return (msdfgen_FontHandle *) loadFont((FreetypeHandle *) library, filename);
}

void msdfgen_ext_destroyFont(msdfgen_FontHandle *font) {
	destroyFont((FontHandle *) font);
}

bool msdfgen_ext_loadGlyph(msdfgen_Shape *output, msdfgen_FontHandle *font, uint32_t unicode, msdfgen_FontCoordinateScaling coordinateScaling, double *outAdvance) {
	if (!output || !font)
		return false;
	return loadGlyph(
		*(Shape *) output,
		(FontHandle *) font,
		(unicode_t) unicode,
		(FontCoordinateScaling) coordinateScaling,
		outAdvance
	);
}

bool msdfgen_ext_loadGlyphByIndex(msdfgen_Shape *output, msdfgen_FontHandle *font, uint32_t glyphIndex, msdfgen_FontCoordinateScaling coordinateScaling, double *outAdvance) {
	if (!output || !font)
		return false;
	return loadGlyph(
		*(Shape *) output,
		(FontHandle *) font,
		GlyphIndex((unsigned) glyphIndex),
		(FontCoordinateScaling) coordinateScaling,
		outAdvance
	);
}

bool msdfgen_ext_getGlyphIndex(msdfgen_FontHandle *font, uint32_t unicode, uint32_t *outGlyphIndex) {
	if (!font || !outGlyphIndex)
		return false;
	GlyphIndex glyphIndex;
	if (!getGlyphIndex(glyphIndex, (FontHandle *) font, (unicode_t) unicode))
		return false;
	*outGlyphIndex = (uint32_t) glyphIndex.getIndex();
	return true;
}

bool msdfgen_ext_savePngF32_3(const msdfgen_BitmapSection_F32_3 *bitmap, const char *filename) {
#ifndef MSDFGEN_DISABLE_PNG
	if (!bitmap || !bitmap->pixels || !filename)
		return false;
	BitmapConstSection<float, 3> section(
		bitmap->pixels,
		bitmap->width,
		bitmap->height,
		bitmap->rowStride,
		(YAxisOrientation) bitmap->yOrientation
	);
	return savePng(section, filename);
#else
	(void) bitmap;
	(void) filename;
	return false;
#endif
}

}
