//
//  ViewController.swift
//  Stage
//
//  Created by Kota Nakano on 2017/09/08.
//
//

import Cocoa
import Metal
import MetalKit
import R4
class ViewController: NSViewController {
	var vertices: MTLBuffer?
	var texture: MTLTexture?
	var sampler: MTLSamplerState?
	var pipeline: MTLRenderPipelineState?
	var commandQueue: MTLCommandQueue?
	var scene: Scene?
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		guard
			let device: MTLDevice = MTLCreateSystemDefaultDevice(),
			let view: MTKView = view as? MTKView else {
				return
		}
		do {
			scene = try Scene(device: device, width: 512, height: 512)
		} catch {
			fatalError(String(describing: error))
		}
		do {
			let descriptor: MTLRenderPipelineDescriptor = MTLRenderPipelineDescriptor()
			let library: MTLLibrary = try device.makeDefaultLibrary(bundle: .main)
			descriptor.vertexFunction = library.makeFunction(name: "vertex_main")
			descriptor.fragmentFunction = library.makeFunction(name: "fragment_main")
			descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
			pipeline = try device.makeRenderPipelineState(descriptor: descriptor)
		} catch {
			fatalError(String(describing: error))
		}
		do {
			let c: Int = 4
			let w: Int = 256
			let h: Int = 256
			let bytes: Array<UInt8> = Array<UInt8>(repeating: 0, count: c * w * h)
			let descriptor: MTLTextureDescriptor = .texture2DDescriptor(pixelFormat: .bgra8Unorm,
			                                                            width: w,
			                                                            height: h,
			                                                            mipmapped: false)
			descriptor.usage = [.shaderRead, .shaderWrite]
			arc4random_buf(UnsafeMutablePointer<UInt8>(mutating: bytes), bytes.count)
			texture = device.makeTexture(descriptor: descriptor)
			texture?.replace(region: MTLRegion(origin: MTLOrigin(x: 0, y: 0, z: 0),
			                                   size: MTLSize(width: w, height: h, depth: 1)),
			                 mipmapLevel: 0,
			                 withBytes: bytes,
			                 bytesPerRow: c * w)
			vertices = device.makeBuffer(bytes: [float2(0, 0), float2(1, 0), float2(0, 1), float2(1, 1)],
			                             length: 4 * MemoryLayout<float2>.stride,
			                             options: [])
		}
		do {
			let descriptor: MTLSamplerDescriptor = MTLSamplerDescriptor()
			descriptor.magFilter = .nearest
			descriptor.minFilter = .nearest
			descriptor.sAddressMode = .repeat
			descriptor.tAddressMode = .repeat
			sampler = device.makeSamplerState(descriptor: descriptor)
		}
		commandQueue = device.makeCommandQueue()
		view.device = device
		view.delegate = self
		view.preferredFramesPerSecond = 24
		view.clearColor = MTLClearColor(red: 0, green: 0.2, blue: 0.1, alpha: 1)
	}
	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}
}
extension ViewController: MTKViewDelegate {
	func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
		
	}
	func draw(in view: MTKView) {
		guard
			let vertices: MTLBuffer = vertices,
			let sampler: MTLSamplerState = sampler,
			let pipeline: MTLRenderPipelineState = pipeline,
			let drawable: MTLDrawable = view.currentDrawable,
			let descriptor: MTLRenderPassDescriptor = view.currentRenderPassDescriptor,
			let commandBuffer: MTLCommandBuffer = commandQueue?.makeCommandBuffer(),
			let texture: MTLTexture = scene?.draw(commandBuffer: commandBuffer) else {
				return
		}
		let encoder: MTLRenderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
		encoder.setRenderPipelineState(pipeline)
		encoder.setVertexBuffer(vertices, offset: 0, at: 0)
		encoder.setFragmentTexture(texture, at: 0)
		encoder.setFragmentSamplerState(sampler, at: 0)
		encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
		encoder.endEncoding()
		commandBuffer.present(drawable)
		commandBuffer.commit()
	}
}
