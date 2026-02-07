#include "msdfgen_c.h"

#include "../lib/msdfgen/msdfgen.h"

using namespace msdfgen;

extern "C" {

msdfgen_Shape *msdfgen_Shape_create(void) {
	return (msdfgen_Shape *) new Shape();
}

void msdfgen_Shape_destroy(msdfgen_Shape *shape) {
	delete (Shape *) shape;
}

void msdfgen_Shape_addContour(msdfgen_Shape *shape, const msdfgen_Contour *contour) {
	((Shape *) shape)->addContour(*(const Contour *) contour);
}

void msdfgen_Shape_normalize(msdfgen_Shape *shape) {
	((Shape *) shape)->normalize();
}

bool msdfgen_Shape_validate(const msdfgen_Shape *shape) {
	return ((const Shape *) shape)->validate();
}

void msdfgen_Shape_getBounds(const msdfgen_Shape *shape, double *l, double *b, double *r, double *t) {
	Shape::Bounds bounds = ((const Shape *) shape)->getBounds();
	*l = bounds.l;
	*b = bounds.b;
	*r = bounds.r;
	*t = bounds.t;
}

void msdfgen_Shape_orientContours(msdfgen_Shape *shape) {
	((Shape *) shape)->orientContours();
}

msdfgen_Contour *msdfgen_Contour_create(void) {
	return (msdfgen_Contour *) new Contour();
}

void msdfgen_Contour_destroy(msdfgen_Contour *contour) {
	delete (Contour *) contour;
}

void msdfgen_Contour_addEdgeLinear(msdfgen_Contour *contour, msdfgen_Vector2 p0, msdfgen_Vector2 p1, msdfgen_EdgeColor color) {
	((Contour *) contour)->addEdge(EdgeHolder(Point2(p0.x, p0.y), Point2(p1.x, p1.y), (EdgeColor) color));
}

void msdfgen_Contour_addEdgeQuadratic(msdfgen_Contour *contour, msdfgen_Vector2 p0, msdfgen_Vector2 p1, msdfgen_Vector2 p2, msdfgen_EdgeColor color) {
	((Contour *) contour)->addEdge(EdgeHolder(Point2(p0.x, p0.y), Point2(p1.x, p1.y), Point2(p2.x, p2.y), (EdgeColor) color));
}

void msdfgen_Contour_addEdgeCubic(msdfgen_Contour *contour, msdfgen_Vector2 p0, msdfgen_Vector2 p1, msdfgen_Vector2 p2, msdfgen_Vector2 p3, msdfgen_EdgeColor color) {
	((Contour *) contour)->addEdge(EdgeHolder(Point2(p0.x, p0.y), Point2(p1.x, p1.y), Point2(p2.x, p2.y), Point2(p3.x, p3.y), (EdgeColor) color));
}

static SDFTransformation convertTransformation(const msdfgen_SDFTransformation *t) {
	return SDFTransformation(
		Projection(Vector2(t->projection.scale.x, t->projection.scale.y), Vector2(t->projection.translate.x, t->projection.translate.y)),
		DistanceMapping(Range(t->range.lower, t->range.upper))
	);
}

static GeneratorConfig convertConfig(const msdfgen_GeneratorConfig *c) {
	return GeneratorConfig(c->overlapSupport);
}

static MSDFGeneratorConfig convertMSDFConfig(const msdfgen_MSDFGeneratorConfig *c) {
	MSDFGeneratorConfig config;
	config.overlapSupport = c->base.overlapSupport;
	config.errorCorrection.mode = (ErrorCorrectionConfig::Mode) c->errorCorrection.mode;
	config.errorCorrection.distanceCheckMode = (ErrorCorrectionConfig::DistanceCheckMode) c->errorCorrection.distanceCheckMode;
	config.errorCorrection.minDeviationRatio = c->errorCorrection.minDeviationRatio;
	config.errorCorrection.minImproveRatio = c->errorCorrection.minImproveRatio;
	config.errorCorrection.buffer = c->errorCorrection.buffer;
	return config;
}

void msdfgen_generateSDF(const msdfgen_BitmapSection_F32_1 *output, const msdfgen_Shape *shape, const msdfgen_SDFTransformation *transformation, const msdfgen_GeneratorConfig *config) {
	BitmapSection<float, 1> section(output->pixels, output->width, output->height, output->rowStride, (YAxisOrientation) output->yOrientation);
	generateSDF(section, *(const Shape *) shape, convertTransformation(transformation), convertConfig(config));
}

void msdfgen_generatePSDF(const msdfgen_BitmapSection_F32_1 *output, const msdfgen_Shape *shape, const msdfgen_SDFTransformation *transformation, const msdfgen_GeneratorConfig *config) {
	BitmapSection<float, 1> section(output->pixels, output->width, output->height, output->rowStride, (YAxisOrientation) output->yOrientation);
	generatePSDF(section, *(const Shape *) shape, convertTransformation(transformation), convertConfig(config));
}

void msdfgen_generateMSDF(const msdfgen_BitmapSection_F32_3 *output, const msdfgen_Shape *shape, const msdfgen_SDFTransformation *transformation, const msdfgen_MSDFGeneratorConfig *config) {
	BitmapSection<float, 3> section(output->pixels, output->width, output->height, output->rowStride, (YAxisOrientation) output->yOrientation);
	generateMSDF(section, *(const Shape *) shape, convertTransformation(transformation), convertMSDFConfig(config));
}

void msdfgen_generateMTSDF(const msdfgen_BitmapSection_F32_4 *output, const msdfgen_Shape *shape, const msdfgen_SDFTransformation *transformation, const msdfgen_MSDFGeneratorConfig *config) {
	BitmapSection<float, 4> section(output->pixels, output->width, output->height, output->rowStride, (YAxisOrientation) output->yOrientation);
	generateMTSDF(section, *(const Shape *) shape, convertTransformation(transformation), convertMSDFConfig(config));
}

void msdfgen_edgeColoringSimple(msdfgen_Shape *shape, double angleThreshold, unsigned long long seed) {
	edgeColoringSimple(*(Shape *) shape, angleThreshold, seed);
}

}
