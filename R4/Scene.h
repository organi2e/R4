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
		float4 attributes[3];
		float4x4 options[3];
	};
	template<typename T1, typename T2> struct Pair {
		T1 first;
		T2 second;
	};
};
#endif /* Scene_h */
