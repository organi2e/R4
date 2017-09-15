//
//  Triangle.metal
//  macOS
//
//  Created by Kota Nakano on 2017/09/15.
//
//

#include<metal_stdlib>
#include"Scene.h"
#include"Triangle.h"
using namespace metal;
using namespace R4;

Triangle::Triangle(Object const object):
	a(object.attributes[0].xyz),
	b(object.attributes[1].xyz),
	c(object.attributes[2].xyz) {
}
float Triangle::getDistance(float3 const direction, float3 const origin) const {
	float result = INFINITY;
	float3 const n = normalize(cross(b-a, c-a));
	float const z = dot(n, direction);
	if ( isnormal(z) ) {
		float const distant = - dot(n, origin - a) / z;
		if ( 0 < distant ) {
			float3 const p = fma(distant, direction, origin);
			if ( 0 < dot(n, cross(c-p, a-p)) && 0 < dot(n, cross(a-p, b-p)) && 0 < dot(n, cross(b-p, c-p))) result = distant;
		}
	}
	return result;
}
float3 Triangle::getNormal(float3 const) const {
	return normalize(cross(b-a, c-a));
}


