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
#include"Triangle.h"
using namespace metal;
using namespace R4;
constant float3 light = float3(0, 100, 1);
inline Pair<int, float> intersect(float3 const direction, float3 const origin, uint const count, constant Object const * const objects, int const self) {
	Pair<int, float> result = {-1, INFINITY};
	for ( int k = 0, K = count ; k < K ; ++ k ) if ( k != self ) {
		float distant = INFINITY;
		switch ( objects[k].flags.x ) {
			case 0: distant = Sphere(objects[k]).getDistance(direction, origin); break;
			case 1: distant = Plane(objects[k]).getDistance(direction, origin); break;
			case 2: distant = Triangle(objects[k]).getDistance(direction, origin); break;
		}
		if ( distant < result.second ) result = {k, distant};
	}
	return result;
}
template<uint depth>float4 trace(float3 const direction, float3 const origin, uint const count, constant Object const * const objects, int const self) {
	auto const hit = intersect(direction, origin, count, objects, self);
	float4 colour = 0;
	float4 mask = 1;
	if ( -1 < hit.first ) {
		float3 const object_p = fma(hit.second, direction, origin);
		float3 object_n = 0;
		switch ( objects[hit.first].flags.x ) {
			case 0: {
				object_n = Sphere(objects[hit.first]).getNormal(object_p);
			} break;
			case 1: {
				object_n = Plane(objects[hit.first]).getNormal(object_p);
				bool2 const flag = fmod(fmod(object_p.xz, 2)+2, 2) < 1;
				if ( flag.x ^ flag.y ) mask = 0;
			} break;
			case 2: {
				object_n = Triangle(objects[hit.first]).getNormal(object_p);
			} break;
		}
		if ( 0 < length_squared(object_n) ) {
			float3 const light_v = normalize(light - object_p);
			if ( intersect(light_v, object_p, count, objects, hit.first).first < 0 )
				colour += max(0.0, dot(direction, reflect(light_v, object_n)));
		
			colour += float4(0.9, 0.8, 1.0, 1) * trace<depth-1>(reflect(direction, object_n),
																		 object_p, count, objects, hit.first);

//			colour += 0.5 * trace<depth-1>(refract(direction, object_n, 0.1),
//																		 object_p, count, objects, hit.first);
		}
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
	float3 const direction = normalize(float3(2*float2(k)/float2(K)-1, 2));
	texture.write(saturate(trace<4>(direction, origin, count, objects, -1)), k);
};
