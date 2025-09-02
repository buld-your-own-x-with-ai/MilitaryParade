import SwiftUI
import ARKit
import RealityKit

struct ARViewContainer: UIViewRepresentable {
    @Binding var isARSessionActive: Bool
    @Binding var selectedPerspective: CameraPerspective
    @Binding var isTimelineModeEnabled: Bool
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
            config.frameSemantics.insert(.personSegmentationWithDepth)
        }
        
        arView.session.run(config)
        
        arView.addCoaching()
        
        context.coordinator.setupARView(arView)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.updatePerspective(selectedPerspective)
        context.coordinator.updateTimelineMode(isTimelineModeEnabled)
        
        if isARSessionActive {
            context.coordinator.startParadeSequence()
        } else {
            context.coordinator.pauseParadeSequence()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARViewContainer
        var arView: ARView?
        var militaryParadeScene: MilitaryParadeScene?
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        func setupARView(_ arView: ARView) {
            self.arView = arView
            arView.session.delegate = self
            
            setupTapGesture()
            setupPinchGesture()
            setupRotationGesture()
            
            militaryParadeScene = MilitaryParadeScene(arView: arView)
        }
        
        func setupTapGesture() {
            guard let arView = arView else { return }
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            arView.addGestureRecognizer(tapGesture)
        }
        
        func setupPinchGesture() {
            guard let arView = arView else { return }
            let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
            arView.addGestureRecognizer(pinchGesture)
        }
        
        func setupRotationGesture() {
            guard let arView = arView else { return }
            let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation))
            arView.addGestureRecognizer(rotationGesture)
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let arView = arView else { return }
            let location = gesture.location(in: arView)
            
            if let entity = arView.entity(at: location) {
                militaryParadeScene?.handleEntitySelection(entity)
            } else {
                militaryParadeScene?.placeParadeSceneAt(location: location, in: arView)
            }
        }
        
        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            militaryParadeScene?.handleScaleGesture(scale: Float(gesture.scale))
        }
        
        @objc func handleRotation(_ gesture: UIRotationGestureRecognizer) {
            militaryParadeScene?.handleRotationGesture(rotation: Float(gesture.rotation))
        }
        
        func updatePerspective(_ perspective: CameraPerspective) {
            militaryParadeScene?.switchToPerspective(perspective)
        }
        
        func updateTimelineMode(_ enabled: Bool) {
            militaryParadeScene?.setTimelineMode(enabled)
        }
        
        func startParadeSequence() {
            militaryParadeScene?.startParade()
        }
        
        func pauseParadeSequence() {
            militaryParadeScene?.pauseParade()
        }
    }
}

extension ARView {
    func addCoaching() {
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.session = self.session
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.activatesAutomatically = true
        coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(coachingOverlay)
        
        NSLayoutConstraint.activate([
            coachingOverlay.topAnchor.constraint(equalTo: self.topAnchor),
            coachingOverlay.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            coachingOverlay.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            coachingOverlay.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
}

enum CameraPerspective: CaseIterable, Codable {
    case ground
    case aerial
    case grandstand
    case free
    
    var displayName: String {
        switch self {
        case .ground:
            return "地面视角"
        case .aerial:
            return "空中俯瞰"
        case .grandstand:
            return "观礼台视角"
        case .free:
            return "自由视角"
        }
    }
}