//
//  Plane.metal
//  macOS
//
//  Created by Kota Nakano on 2017/09/12.
//
//

#include<metal_stdlib>
#include"Scene.h"
#include"Plane.h"
using namespace metal;
using namespace R4;
Plane::Plane(Object const object):
	position(object.attributes[0].xyz),
	normal(normalize(object.attributes[1].xyz)) {
};
float Plane::getDistance(float3 const direction, float3 const origin) const {
	float result = INFINITY;
	float const a = dot(normal, direction);
	if ( isnormal(a) ) {
		float const distant = - dot(normal, origin - position) / a;
		result = select(result, distant, 0 < distant);
	}
	return result;
}
float3 Plane::getNormal(float3 const position) const {
	return normal;
}
