//
//  Triangle.h
//  macOS
//
//  Created by Kota Nakano on 2017/09/15.
//
//

#ifndef Triangle_h
#define Triangle_h
#include<metal_stdlib>
#include"Scene.h"
namespace R4 {
	using namespace metal;
	struct Triangle {
		float3 a, b, c;
		
		Triangle(Object const);
		float getDistance(float3 const, float3 const) const;
		float3 getNormal(float3 const) const;
	};
};
#endif /* Triangle_h */
