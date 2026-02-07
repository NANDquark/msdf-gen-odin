#pragma once

#include <stdbool.h>
#include <stdint.h>

#include "msdfgen_c.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct msdfgen_FreetypeHandle msdfgen_FreetypeHandle;
typedef struct msdfgen_FontHandle msdfgen_FontHandle;

typedef enum {
	MSDFGEN_FONT_SCALING_NONE = 0,
	MSDFGEN_FONT_SCALING_EM_NORMALIZED = 1,
	MSDFGEN_FONT_SCALING_LEGACY = 2,
} msdfgen_FontCoordinateScaling;

msdfgen_FreetypeHandle *msdfgen_ext_initializeFreetype(void);
void msdfgen_ext_deinitializeFreetype(msdfgen_FreetypeHandle *library);

msdfgen_FontHandle *msdfgen_ext_loadFont(msdfgen_FreetypeHandle *library, const char *filename);
void msdfgen_ext_destroyFont(msdfgen_FontHandle *font);

bool msdfgen_ext_loadGlyph(msdfgen_Shape *output, msdfgen_FontHandle *font, uint32_t unicode, msdfgen_FontCoordinateScaling coordinateScaling, double *outAdvance);
bool msdfgen_ext_loadGlyphByIndex(msdfgen_Shape *output, msdfgen_FontHandle *font, uint32_t glyphIndex, msdfgen_FontCoordinateScaling coordinateScaling, double *outAdvance);
bool msdfgen_ext_getGlyphIndex(msdfgen_FontHandle *font, uint32_t unicode, uint32_t *outGlyphIndex);

bool msdfgen_ext_savePngF32_3(const msdfgen_BitmapSection_F32_3 *bitmap, const char *filename);

#ifdef __cplusplus
}
#endif
