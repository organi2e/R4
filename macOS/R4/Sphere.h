//
//  Sphere.h
//  macOS
//
//  Created by Kota Nakano on 2017/09/12.
//
//

#ifndef Sphere_h
#define Sphere_h
#include<metal_stdlib>
#include"Scene.h"
namespace R4 {
	using namespace metal;
	struct Sphere {
		float4 colour;
		float3 center;
		float const radius;
	public:
		Sphere(Object const);
		float getDistance(float3 const, float3 const) const;
		float3 getNormal(float3 const) const;
	};
};
#endif /* Sphere_h */
