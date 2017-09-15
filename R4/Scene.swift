//
//  Scene.swift
//  macOS
//
//  Created by Kota Nakano on 2017/09/11.
//
//

import Metal
import simd
struct Object {
	let flags: uint4
	let attributes: (float4, float4, float4)
	let options: (float4x4, float4x4, float4x4)
};
protocol ObjectInterface {
	var object: Object { get }
};
public class Scene {
	let texture: MTLTexture
	let pipeline: MTLComputePipelineState
	let threads: MTLSize
	let groups: MTLSize
	public init(device: MTLDevice, width: Int, height: Int) throws {
		let library: MTLLibrary = try device.makeDefaultLibrary(bundle: Bundle(for: type(of: self)))
		let constantValues: MTLFunctionConstantValues = MTLFunctionConstantValues()
		pipeline = try device.makeComputePipelineState(function: library.makeFunction(name: "trace",
		                                                                              constantValues: constantValues))
		threads = MTLSize(width: pipeline.threadExecutionWidth,
		                  height: 1,
		                  depth: 1)
		groups = MTLSize(width: (width-1)/threads.width+1,
		                 height: (height-1)/threads.height+1,
		                 depth: 1)
		let descriptor: MTLTextureDescriptor = .texture2DDescriptor(pixelFormat: .bgra8Unorm,
		                                                            width: groups.width * threads.width,
		                                                            height: groups.height * threads.height,
		                                                            mipmapped: false)
		descriptor.usage = [.shaderWrite, .shaderRead]
		texture = device.makeTexture(descriptor: descriptor)
	}
	public func draw(commandBuffer: MTLCommandBuffer) -> MTLTexture {
		assert( commandBuffer.device === texture.device )
		assert( commandBuffer.device === pipeline.device )
		let encoder: MTLComputeCommandEncoder = commandBuffer.makeComputeCommandEncoder()
		let objects: Array<ObjectInterface> = [Plane(center: float3(0, -1, 0), normal: float3(0, 1, 0)),
		                                       Triangle(a: float3(0, 1, 2.5), b: float3(-1.5, 0.1, 2), c: float3( 1.5, 0.1, 2)),
		                                       Sphere(center: float3(0, 3, 1), radius: 0.3),
		                                       Sphere(center: float3(-0.5, 0.5, 1), radius: 0.3),
		                                       Sphere(center: float3( 0.5, 1.0, 1.5), radius: 0.3),
		                                       ]
		encoder.setComputePipelineState(pipeline)
		encoder.setTexture(texture, at: 0)
		encoder.setBytes([uint(objects.count)], length: MemoryLayout<uint>.size, at: 0)
		encoder.setBytes(objects.map { $0.object }, length: MemoryLayout<Object>.stride * objects.count, at: 1)
		encoder.dispatchThreadgroups(groups, threadsPerThreadgroup: threads)
		encoder.endEncoding()
		return texture
	}
}
