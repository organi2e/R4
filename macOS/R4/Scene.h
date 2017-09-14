//
//  Scene.h
//  macOS
//
//  Created by Kota Nakano on 2017/09/12.
//
//

#ifndef Scene_h
#define Scene_h
#include<metal_stdlib>
namespace R4 {
	using namespace metal;
	struct Object {
		uint4 flags;
		float3x4 attributes;
	};
};
#endif /* Scene_h */
