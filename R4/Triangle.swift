//
//  Triangle.swift
//  macOS
//
//  Created by Kota Nakano on 2017/09/15.
//
//

import simd
struct Triangle {
	let a: float3
	let b: float3
	let c: float3
}
extension Triangle: ObjectInterface {
	var object: Object {
		return Object(flags: uint4(2, 0, 0, 0),
		              attributes: (float4(a.x, a.y, a.z, 1),
		                           float4(b.x, b.y, b.z, 1),
		                           float4(c.x, c.y, c.z, 1)),
		              options: (float4x4(0),
		                        float4x4(0),
		                        float4x4(0)))
	}
}
