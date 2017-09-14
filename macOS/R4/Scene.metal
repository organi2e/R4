//
//  Tracer.metal
//  macOS
//
//  Created by Kota Nakano on 2017/09/11.
//
//

#include<metal_stdlib>
#include"Scene.h"
#include"Sphere.h"
#include"Plane.h"
using namespace metal;
using namespace R4;
constant float3 light = float3(0, 100, 1);
inline float2 intersect(float3 const direction, float3 const origin, uint const count, constant Object const * const objects, int const self) {
	float2 result = float2(-1, INFINITY);
	for ( int k = 0, K = count ; k < K ; ++ k ) if ( k != self ) {
		float distant = INFINITY;
		switch ( objects[k].flags.x ) {
			case 0: distant = Sphere(objects[k]).getDistance(direction, origin); break;
			case 1: distant = Plane(objects[k]).getDistance(direction, origin); break;
		}
		if ( distant < result.y ) result = float2(k, distant);
	}
	return result;
}
template<uint depth>float4 trace(float3 const direction, float3 const origin, uint const count, constant Object const * const objects, int const self) {
	float2 const hit = intersect(direction, origin, count, objects, self);
	int const found = int(hit.x);
	float const distant = hit.y;
	float4 colour = 0;
	float4 mask = 1;
	if ( -1 < found ) {
		float3 const object_p = fma(distant, direction, origin);
		float3 object_n = 0;
		switch ( objects[found].flags.x ) {
			case 0: {
				object_n = Sphere(objects[found]).getNormal(object_p);
			} break;
			case 1: {
				object_n = Plane(objects[found]).getNormal(object_p);
				bool2 const flag = fmod(fmod(object_p.xz, 2)+2, 2) < 1;
				if (flag.x ^ flag.y) mask = 0;
			} break;
		}
		float3 const light_v = normalize(light - object_p);
		if ( intersect(light_v, object_p, count, objects, found).x < 0 )
			colour += max(0.0, dot(direction, reflect(light_v, object_n)));
		
		float3 const trace_r = reflect(direction, object_n);
		colour += 0.5 * trace<depth-1>(trace_r, object_p, count, objects, found);
	}
	return colour * mask;
}
template<>float4 trace<0>(float3 const direction, float3 const origin, uint const count, constant Object const * const objects, int const self) {
	return 0;
}
kernel void trace(texture2d<float, access::write> texture [[ texture(0) ]],
									constant uint const & count [[ buffer(0) ]],
									constant Object const * const objects [[ buffer(1) ]],
									uint2 const k [[ thread_position_in_grid ]],
									uint2 const K [[ threads_per_grid ]]) {
	float3 const origin = float3(0, 0, -3);
	float3 const direction = normalize(float3(2*float2(k)/float2(K)-1, 1));
	texture.write(saturate(trace<8>(direction, origin, count, objects, -1)), k);
};
