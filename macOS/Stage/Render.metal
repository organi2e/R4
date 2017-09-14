//
//  Render.metal
//  macOS
//
//  Created by Kota Nakano on 2017/09/08.
//
//

#include <metal_stdlib>
using namespace metal;
struct Attribute {
	float4 position [[ position ]];
	float2 texcoord [[ user(tx) ]];
	inline Attribute(thread float2 const arg) {
		position = float4(fma(2, arg, -1), 0, 1);
		texcoord = arg;
	};
};
vertex Attribute vertex_main(constant float2 * const vertices [[ buffer(0) ]],
														 uint const idx [[ vertex_id ]]) {
	return Attribute(vertices[idx]);
}
fragment float4 fragment_main(Attribute const attribute [[ stage_in ]],
															texture2d<float, access::sample> texture [[ texture(0) ]],
															sampler const sampler [[ sampler(0) ]]) {
	return texture.sample(sampler, attribute.texcoord);
}
