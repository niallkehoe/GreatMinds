#pragma body

float u = _surface.diffuseTexcoord.x;
float v = _surface.diffuseTexcoord.y;

float2 thickness = float2(0.005);
if (u > thickness[0] && u < (1.0 - thickness[0]) && v > thickness[1] && v < (1.0 - thickness[1])) {
    discard_fragment();
}
