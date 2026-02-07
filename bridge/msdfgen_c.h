#pragma once

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

// Opaque types
typedef struct msdfgen_Shape msdfgen_Shape;
typedef struct msdfgen_Contour msdfgen_Contour;

// Basic types
typedef struct {
    double x, y;
} msdfgen_Vector2;

typedef struct {
    double lower, upper;
} msdfgen_Range;

typedef struct {
    msdfgen_Vector2 scale;
    msdfgen_Vector2 translate;
} msdfgen_Projection;

typedef struct {
    msdfgen_Projection projection;
    msdfgen_Range range;
} msdfgen_SDFTransformation;

typedef enum {
    MSDFGEN_Y_AXIS_BOTTOM_UP = 0,
    MSDFGEN_Y_AXIS_TOP_DOWN = 1
} msdfgen_YAxisOrientation;

typedef struct {
    float* pixels;
    int width, height;
    int rowStride;
    msdfgen_YAxisOrientation yOrientation;
} msdfgen_BitmapSection_F32_1;

typedef struct {
    float* pixels;
    int width, height;
    int rowStride;
    msdfgen_YAxisOrientation yOrientation;
} msdfgen_BitmapSection_F32_3;

typedef struct {
    float* pixels;
    int width, height;
    int rowStride;
    msdfgen_YAxisOrientation yOrientation;
} msdfgen_BitmapSection_F32_4;

typedef struct {
    bool overlapSupport;
} msdfgen_GeneratorConfig;

typedef enum {
    MSDFGEN_EC_DISABLED,
    MSDFGEN_EC_INDISCRIMINATE,
    MSDFGEN_EC_EDGE_PRIORITY,
    MSDFGEN_EC_EDGE_ONLY
} msdfgen_ErrorCorrectionMode;

typedef enum {
    MSDFGEN_DC_DO_NOT_CHECK_DISTANCE,
    MSDFGEN_DC_CHECK_DISTANCE_AT_EDGE,
    MSDFGEN_DC_ALWAYS_CHECK_DISTANCE
} msdfgen_DistanceCheckMode;

typedef struct {
    msdfgen_ErrorCorrectionMode mode;
    msdfgen_DistanceCheckMode distanceCheckMode;
    double minDeviationRatio;
    double minImproveRatio;
    unsigned char* buffer;
} msdfgen_ErrorCorrectionConfig;

typedef struct {
    msdfgen_GeneratorConfig base;
    msdfgen_ErrorCorrectionConfig errorCorrection;
} msdfgen_MSDFGeneratorConfig;

typedef enum {
    MSDFGEN_EDGE_COLOR_BLACK = 0,
    MSDFGEN_EDGE_COLOR_RED = 1,
    MSDFGEN_EDGE_COLOR_GREEN = 2,
    MSDFGEN_EDGE_COLOR_YELLOW = 3,
    MSDFGEN_EDGE_COLOR_BLUE = 4,
    MSDFGEN_EDGE_COLOR_MAGENTA = 5,
    MSDFGEN_EDGE_COLOR_CYAN = 6,
    MSDFGEN_EDGE_COLOR_WHITE = 7
} msdfgen_EdgeColor;

// Shape API
msdfgen_Shape* msdfgen_Shape_create();
void msdfgen_Shape_destroy(msdfgen_Shape* shape);
void msdfgen_Shape_addContour(msdfgen_Shape* shape, const msdfgen_Contour* contour);
void msdfgen_Shape_normalize(msdfgen_Shape* shape);
bool msdfgen_Shape_validate(const msdfgen_Shape* shape);
void msdfgen_Shape_getBounds(const msdfgen_Shape* shape, double* l, double* b, double* r, double* t);
void msdfgen_Shape_orientContours(msdfgen_Shape* shape);

// Contour API
msdfgen_Contour* msdfgen_Contour_create();
void msdfgen_Contour_destroy(msdfgen_Contour* contour);
void msdfgen_Contour_addEdgeLinear(msdfgen_Contour* contour, msdfgen_Vector2 p0, msdfgen_Vector2 p1, msdfgen_EdgeColor color);
void msdfgen_Contour_addEdgeQuadratic(msdfgen_Contour* contour, msdfgen_Vector2 p0, msdfgen_Vector2 p1, msdfgen_Vector2 p2, msdfgen_EdgeColor color);
void msdfgen_Contour_addEdgeCubic(msdfgen_Contour* contour, msdfgen_Vector2 p0, msdfgen_Vector2 p1, msdfgen_Vector2 p2, msdfgen_Vector2 p3, msdfgen_EdgeColor color);

// Generation API
void msdfgen_generateSDF(const msdfgen_BitmapSection_F32_1* output, const msdfgen_Shape* shape, const msdfgen_SDFTransformation* transformation, const msdfgen_GeneratorConfig* config);
void msdfgen_generatePSDF(const msdfgen_BitmapSection_F32_1* output, const msdfgen_Shape* shape, const msdfgen_SDFTransformation* transformation, const msdfgen_GeneratorConfig* config);
void msdfgen_generateMSDF(const msdfgen_BitmapSection_F32_3* output, const msdfgen_Shape* shape, const msdfgen_SDFTransformation* transformation, const msdfgen_MSDFGeneratorConfig* config);
void msdfgen_generateMTSDF(const msdfgen_BitmapSection_F32_4* output, const msdfgen_Shape* shape, const msdfgen_SDFTransformation* transformation, const msdfgen_MSDFGeneratorConfig* config);

// Edge coloring
void msdfgen_edgeColoringSimple(msdfgen_Shape* shape, double angleThreshold, unsigned long long seed);

#ifdef __cplusplus
}
#endif
