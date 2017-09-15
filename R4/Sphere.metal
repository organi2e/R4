//
//  Sphere.metal
//  macOS
//
//  Created by Kota Nakano on 2017/09/12.
//
//

#include<metal_stdlib>
#include"Sphere.h"
using namespace metal;
using namespace R4;
Sphere::Sphere(Object const object):
	center(object.attributes[0].xyz),
	radius(object.attributes[0].w),
	colour(object.attributes[1]) {	
}
float Sphere::getDistance(float3 const direction, float3 const origin) const {
	float result = INFINITY;
	float3 const d = origin - center;
	float const c = fma(radius, -radius, length_squared(d));
	if ( 0 < c ) {
		float const b = dot(d, direction);
		float const e = fma(b, b, -c);
		result = select(result, -b-sqrt(e), 0 < e);
	}
	return result;
}
float3 Sphere::getNormal(float3 const p) const {
	return normalize( p - center );
}
