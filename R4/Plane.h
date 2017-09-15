//
//  Plane.h
//  macOS
//
//  Created by Kota Nakano on 2017/09/12.
//
//

#ifndef Plane_h
#define Plane_h
#include<metal_stdlib>
#include"Scene.h"
namespace R4 {
	using namespace metal;
	struct Plane {
		float3 position;
		float3 normal;
	public:
		Plane(Object const);
		float getDistance(float3 const, float3 const) const;
		float3 getNormal(float3 const) const;
	};
};
#endif /* Plane_h */
