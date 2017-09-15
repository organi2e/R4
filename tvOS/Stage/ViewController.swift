//
//  ViewController.swift
//  Stage
//
//  Created by Kota Nakano on 2017/09/15.
//
//

import UIKit
import MetalKit
import R4
class ViewController: UIViewController {
	var commandQueue: MTLCommandQueue?
	var vertices: MTLBuffer?
	var sampler: MTLSamplerState?
	var pipeline: MTLRenderPipelineState?
	var scene: Scene?
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		guard
			let device: MTLDevice = MTLCreateSystemDefaultDevice(),
			let view: MTKView = view as? MTKView else {
			fatalError()
		}
		do {
			let descriptor: MTLRenderPipelineDescriptor = MTLRenderPipelineDescriptor()
			let library: MTLLibrary = try device.makeDefaultLibrary(bundle: .main)
			descriptor.vertexFunction = library.makeFunction(name: "vertex_main")
			descriptor.fragmentFunction = library.makeFunction(name: "fragment_main")
			descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
			pipeline = try device.makeRenderPipelineState(descriptor: descriptor)
			scene = try Scene(device: device, width: 512, height: 512)
		} catch {
			fatalError(String(describing: error))
		}
		let descriptor: MTLSamplerDescriptor = MTLSamplerDescriptor()
		descriptor.magFilter = .linear
		descriptor.minFilter = .linear
		descriptor.sAddressMode = .repeat
		descriptor.tAddressMode = .repeat
		commandQueue = device.makeCommandQueue()
		sampler = device.makeSamplerState(descriptor: descriptor)
		vertices = device.makeBuffer(bytes: [float2(0, 0), float2(1, 0), float2(0, 1), float2(1, 1)],
		                             length: 4 * MemoryLayout<float2>.stride,
		                             options: [])
		view.device = device
		view.delegate = self
		view.preferredFramesPerSecond = 24
		view.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
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
			let texture: MTLTexture = scene?.draw(commandBuffer: commandBuffer)
			else {
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
