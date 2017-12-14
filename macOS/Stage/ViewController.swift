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
	var sampler: MTLSamplerState?
	var pipeline: MTLRenderPipelineState?
	var commandQueue: MTLCommandQueue?
	var scene: Scene?
	var context: CIContext?
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		guard
			let device: MTLDevice = MTLCreateSystemDefaultDevice(),
			let view: MTKView = view as? MTKView else {
				return
		}
		context = CIContext(mtlDevice: device)
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
			let texture: MTLTexture = scene?.draw(commandBuffer: commandBuffer)//,
//			let image: CIImage = CIImage(mtlTexture: texture, options: nil)
			else {
				return
		}
//		context?.render(image.applyingGaussianBlur(withSigma: 0.1), to: texture, commandBuffer: commandBuffer, bounds: CGRect(x: 0, y: 0, width: texture.width, height: texture.height), colorSpace: CGColorSpaceCreateDeviceRGB())
		
		guard let encoder: MTLRenderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else { return }
		encoder.setRenderPipelineState(pipeline)
		encoder.setVertexBuffer(vertices, offset: 0, index: 0)
		encoder.setFragmentTexture(texture, index: 0)
		encoder.setFragmentSamplerState(sampler, index: 0)
		encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
		encoder.endEncoding()
		commandBuffer.present(drawable)
		commandBuffer.commit()
	}
}
