import SwiftUI
import RealityKit
import ARKit

struct TreasureARView: UIViewRepresentable {
    let onCollected: () -> Void

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        context.coordinator.arView = arView

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        arView.session.run(configuration)

        let anchor = AnchorEntity(world: SIMD3<Float>(0, -0.25, -2.2))
        let chest = makeChest()
        chest.name = "roomloot_treasure"
        anchor.addChild(chest)
        arView.scene.addAnchor(anchor)

        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tap)
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onCollected: onCollected)
    }

    private func makeChest() -> Entity {
        let root = Entity()

        let wood = SimpleMaterial(color: UIColor(red: 0.32, green: 0.18, blue: 0.08, alpha: 1), roughness: 0.55, isMetallic: false)
        let brass = SimpleMaterial(color: UIColor(red: 0.72, green: 0.52, blue: 0.22, alpha: 1), roughness: 0.35, isMetallic: true)

        let base = ModelEntity(mesh: .generateBox(size: SIMD3<Float>(0.7, 0.32, 0.42)), materials: [wood])
        base.position = SIMD3<Float>(0, 0, 0)
        root.addChild(base)

        let lid = ModelEntity(mesh: .generateBox(size: SIMD3<Float>(0.72, 0.18, 0.44)), materials: [wood])
        lid.position = SIMD3<Float>(0, 0.25, 0)
        root.addChild(lid)

        for x in [-0.28 as Float, 0.28 as Float] {
            let band = ModelEntity(mesh: .generateBox(size: SIMD3<Float>(0.05, 0.56, 0.46)), materials: [brass])
            band.position = SIMD3<Float>(x, 0.08, 0)
            root.addChild(band)
        }

        let latch = ModelEntity(mesh: .generateBox(size: SIMD3<Float>(0.16, 0.14, 0.04)), materials: [brass])
        latch.position = SIMD3<Float>(0, 0.12, 0.24)
        root.addChild(latch)

        let relic = ModelEntity(mesh: .generateSphere(radius: 0.08), materials: [brass])
        relic.position = SIMD3<Float>(0, 0.48, 0)
        root.addChild(relic)

        root.generateCollisionShapes(recursive: true)
        return root
    }

    final class Coordinator: NSObject {
        weak var arView: ARView?
        let onCollected: () -> Void

        init(onCollected: @escaping () -> Void) {
            self.onCollected = onCollected
        }

        @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
            guard let arView else { return }
            let location = recognizer.location(in: arView)
            if arView.entity(at: location) != nil {
                onCollected()
            }
        }
    }
}

