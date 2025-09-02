import RealityKit
import ARKit
import SwiftUI

class CameraPerspectiveManager: ObservableObject {
    private let arView: ARView
    private var cameraEntity: Entity?
    private var currentPerspective: CameraPerspective = .free
    private var animationTimer: Timer?
    
    init(arView: ARView) {
        self.arView = arView
        setupCameraEntity()
    }
    
    private func setupCameraEntity() {
        cameraEntity = Entity()
        if let anchor = arView.scene.anchors.first {
            anchor.addChild(cameraEntity!)
        }
    }
    
    func switchToPerspective(_ perspective: CameraPerspective, animated: Bool = true) {
        currentPerspective = perspective
        
        switch perspective {
        case .ground:
            animateToGroundView(animated: animated)
        case .aerial:
            animateToAerialView(animated: animated)
        case .grandstand:
            animateToGrandstandView(animated: animated)
        case .free:
            animateToFreeView(animated: animated)
        }
    }
    
    private func animateToGroundView(animated: Bool) {
        let targetPosition = SIMD3<Float>(0, 0.1, 8)
        let targetOrientation = simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0))
        
        if animated {
            animateCamera(to: targetPosition, orientation: targetOrientation)
        } else {
            setCameraTransform(position: targetPosition, orientation: targetOrientation)
        }
    }
    
    private func animateToAerialView(animated: Bool) {
        let targetPosition = SIMD3<Float>(0, 8, 5)
        let targetOrientation = simd_quatf(angle: -.pi/4, axis: SIMD3<Float>(1, 0, 0))
        
        if animated {
            animateCamera(to: targetPosition, orientation: targetOrientation)
        } else {
            setCameraTransform(position: targetPosition, orientation: targetOrientation)
        }
    }
    
    private func animateToGrandstandView(animated: Bool) {
        let targetPosition = SIMD3<Float>(-6, 2, 0)
        let targetOrientation = simd_quatf(angle: .pi/6, axis: SIMD3<Float>(0, 1, 0))
        
        if animated {
            animateCamera(to: targetPosition, orientation: targetOrientation)
        } else {
            setCameraTransform(position: targetPosition, orientation: targetOrientation)
        }
    }
    
    private func animateToFreeView(animated: Bool) {
        resetCameraToDefault()
    }
    
    private func animateCamera(to position: SIMD3<Float>, orientation: simd_quatf) {
        guard let camera = cameraEntity else { return }
        
        let startPosition = camera.transform.translation
        let startOrientation = camera.transform.rotation
        
        var progress: Float = 0.0
        let duration: Float = 1.5
        let steps: Float = 60.0
        let stepInterval = TimeInterval(duration / steps)
        
        animationTimer?.invalidate()
        animationTimer = Timer.scheduledTimer(withTimeInterval: stepInterval, repeats: true) { timer in
            progress += 1.0 / steps
            
            if progress >= 1.0 {
                progress = 1.0
                timer.invalidate()
            }
            
            let smoothProgress = self.easeInOut(progress)
            
            let currentPosition = mix(startPosition, position, t: smoothProgress)
            let currentOrientation = simd_slerp(startOrientation, orientation, smoothProgress)
            
            DispatchQueue.main.async {
                self.setCameraTransform(position: currentPosition, orientation: currentOrientation)
            }
        }
    }
    
    private func setCameraTransform(position: SIMD3<Float>, orientation: simd_quatf) {
        cameraEntity?.transform.translation = position
        cameraEntity?.transform.rotation = orientation
    }
    
    private func resetCameraToDefault() {
        cameraEntity?.transform = Transform.identity
    }
    
    private func easeInOut(_ t: Float) -> Float {
        return t * t * (3.0 - 2.0 * t)
    }
    
    private func mix(_ a: SIMD3<Float>, _ b: SIMD3<Float>, t: Float) -> SIMD3<Float> {
        return a + (b - a) * t
    }
}

class TimelineModeManager: ObservableObject {
    private let arView: ARView
    @Published var currentYear: Int = 2025
    @Published var isTimelineModeActive = false
    
    private var historicalScenes: [Int: Entity] = [:]
    private let availableYears = [1949, 1984, 1999, 2009, 2015, 2019, 2025]
    
    init(arView: ARView) {
        self.arView = arView
        loadHistoricalScenes()
    }
    
    private func loadHistoricalScenes() {
        for year in availableYears {
            let scene = createHistoricalScene(for: year)
            historicalScenes[year] = scene
        }
    }
    
    private func createHistoricalScene(for year: Int) -> Entity {
        let sceneEntity = Entity()
        sceneEntity.name = "HistoricalScene\(year)"
        
        switch year {
        case 1949:
            return create1949Scene()
        case 1984:
            return create1984Scene()
        case 1999:
            return create1999Scene()
        case 2009:
            return create2009Scene()
        case 2015:
            return create2015Scene()
        case 2019:
            return create2019Scene()
        case 2025:
            return create2025Scene()
        default:
            return sceneEntity
        }
    }
    
    private func create1949Scene() -> Entity {
        let scene = Entity()
        scene.name = "1949年开国大典"
        
        let parade = createSimpleInfantryFormation(count: 50)
        parade.scale = SIMD3<Float>(0.8, 0.8, 0.8)
        scene.addChild(parade)
        
        let infoPanel = createYearInfoPanel(
            year: "1949年",
            title: "开国大典",
            description: "中华人民共和国成立，首次阅兵式"
        )
        infoPanel.transform.translation = SIMD3<Float>(0, 1, -3)
        scene.addChild(infoPanel)
        
        return scene
    }
    
    private func create1984Scene() -> Entity {
        let scene = Entity()
        scene.name = "1984年国庆阅兵"
        
        let infantry = createSimpleInfantryFormation(count: 80)
        let vehicles = createVehicleFormation(count: 20)
        vehicles.transform.translation = SIMD3<Float>(2, 0, 0)
        
        scene.addChild(infantry)
        scene.addChild(vehicles)
        
        let infoPanel = createYearInfoPanel(
            year: "1984年",
            title: "改革开放初期阅兵",
            description: "展示改革开放成果，装备现代化起步"
        )
        infoPanel.transform.translation = SIMD3<Float>(0, 1, -3)
        scene.addChild(infoPanel)
        
        return scene
    }
    
    private func create1999Scene() -> Entity {
        let scene = Entity()
        scene.name = "1999年国庆阅兵"
        
        let infantry = createSimpleInfantryFormation(count: 100)
        let vehicles = createVehicleFormation(count: 30)
        let aircraft = createSimpleAircraftFormation(count: 10)
        
        vehicles.transform.translation = SIMD3<Float>(2, 0, 0)
        aircraft.transform.translation = SIMD3<Float>(0, 3, -2)
        
        scene.addChild(infantry)
        scene.addChild(vehicles)
        scene.addChild(aircraft)
        
        let infoPanel = createYearInfoPanel(
            year: "1999年",
            title: "新世纪前夜",
            description: "跨世纪阅兵，展示军队现代化建设成就"
        )
        infoPanel.transform.translation = SIMD3<Float>(0, 1, -3)
        scene.addChild(infoPanel)
        
        return scene
    }
    
    private func create2009Scene() -> Entity {
        let scene = Entity()
        scene.name = "2009年国庆阅兵"
        
        let infantry = createSimpleInfantryFormation(count: 120)
        let vehicles = createAdvancedVehicleFormation(count: 40)
        let aircraft = createSimpleAircraftFormation(count: 15)
        
        vehicles.transform.translation = SIMD3<Float>(2, 0, 0)
        aircraft.transform.translation = SIMD3<Float>(0, 3, -2)
        
        scene.addChild(infantry)
        scene.addChild(vehicles)
        scene.addChild(aircraft)
        
        let infoPanel = createYearInfoPanel(
            year: "2009年",
            title: "建国60周年",
            description: "新装备大量亮相，军事现代化加速"
        )
        infoPanel.transform.translation = SIMD3<Float>(0, 1, -3)
        scene.addChild(infoPanel)
        
        return scene
    }
    
    private func create2015Scene() -> Entity {
        let scene = Entity()
        scene.name = "2015年抗战胜利阅兵"
        
        let infantry = createSimpleInfantryFormation(count: 140)
        let vehicles = createAdvancedVehicleFormation(count: 50)
        let aircraft = createAdvancedAircraftFormation(count: 20)
        
        vehicles.transform.translation = SIMD3<Float>(2, 0, 0)
        aircraft.transform.translation = SIMD3<Float>(0, 3, -2)
        
        scene.addChild(infantry)
        scene.addChild(vehicles)
        scene.addChild(aircraft)
        
        let infoPanel = createYearInfoPanel(
            year: "2015年",
            title: "抗战胜利70周年",
            description: "首次非国庆阅兵，国际军队参与"
        )
        infoPanel.transform.translation = SIMD3<Float>(0, 1, -3)
        scene.addChild(infoPanel)
        
        return scene
    }
    
    private func create2019Scene() -> Entity {
        let scene = Entity()
        scene.name = "2019年国庆阅兵"
        
        let infantry = createSimpleInfantryFormation(count: 160)
        let vehicles = createModernVehicleFormation(count: 60)
        let aircraft = createAdvancedAircraftFormation(count: 25)
        
        vehicles.transform.translation = SIMD3<Float>(2, 0, 0)
        aircraft.transform.translation = SIMD3<Float>(0, 3, -2)
        
        scene.addChild(infantry)
        scene.addChild(vehicles)
        scene.addChild(aircraft)
        
        let infoPanel = createYearInfoPanel(
            year: "2019年",
            title: "建国70周年",
            description: "东风-41首次亮相，军事实力全面展示"
        )
        infoPanel.transform.translation = SIMD3<Float>(0, 1, -3)
        scene.addChild(infoPanel)
        
        return scene
    }
    
    private func create2025Scene() -> Entity {
        let scene = Entity()
        scene.name = "2025年阅兵"
        
        let infantry = createSimpleInfantryFormation(count: 180)
        let vehicles = createFutureVehicleFormation(count: 70)
        let aircraft = createSixthGenFormation(count: 30)
        
        vehicles.transform.translation = SIMD3<Float>(2, 0, 0)
        aircraft.transform.translation = SIMD3<Float>(0, 3, -2)
        
        scene.addChild(infantry)
        scene.addChild(vehicles)
        scene.addChild(aircraft)
        
        let infoPanel = createYearInfoPanel(
            year: "2025年",
            title: "建国75周年",
            description: "六代机首次公开展示，军事科技达到世界先进水平"
        )
        infoPanel.transform.translation = SIMD3<Float>(0, 1, -3)
        scene.addChild(infoPanel)
        
        return scene
    }
    
    private func createSimpleInfantryFormation(count: Int) -> Entity {
        let formation = Entity()
        
        for i in 0..<count {
            let soldier = createSimpleSoldier()
            soldier.transform.translation = SIMD3<Float>(
                Float(i % 10) * 0.15 - 0.75,
                0,
                Float(i / 10) * 0.2
            )
            formation.addChild(soldier)
        }
        
        return formation
    }
    
    private func createSimpleSoldier() -> Entity {
        let mesh = MeshResource.generateBox(width: 0.08, height: 0.3, depth: 0.04)
        let material = SimpleMaterial(color: .green, roughness: 0.5, isMetallic: false)
        return ModelEntity(mesh: mesh, materials: [material])
    }
    
    private func createVehicleFormation(count: Int) -> Entity {
        let formation = Entity()
        
        for i in 0..<count {
            let vehicle = createSimpleVehicle(era: "early")
            vehicle.transform.translation = SIMD3<Float>(0, 0, Float(i) * 0.5)
            formation.addChild(vehicle)
        }
        
        return formation
    }
    
    private func createAdvancedVehicleFormation(count: Int) -> Entity {
        let formation = Entity()
        
        for i in 0..<count {
            let vehicle = createSimpleVehicle(era: "modern")
            vehicle.transform.translation = SIMD3<Float>(0, 0, Float(i) * 0.5)
            formation.addChild(vehicle)
        }
        
        return formation
    }
    
    private func createModernVehicleFormation(count: Int) -> Entity {
        let formation = Entity()
        
        for i in 0..<count {
            let vehicle = createSimpleVehicle(era: "advanced")
            vehicle.transform.translation = SIMD3<Float>(0, 0, Float(i) * 0.5)
            formation.addChild(vehicle)
        }
        
        return formation
    }
    
    private func createFutureVehicleFormation(count: Int) -> Entity {
        let formation = Entity()
        
        for i in 0..<count {
            let vehicle = createSimpleVehicle(era: "future")
            vehicle.transform.translation = SIMD3<Float>(0, 0, Float(i) * 0.5)
            formation.addChild(vehicle)
        }
        
        return formation
    }
    
    private func createSimpleVehicle(era: String) -> Entity {
        let mesh = MeshResource.generateBox(width: 0.3, height: 0.15, depth: 0.6)
        var color: UIColor
        
        switch era {
        case "early":
            color = .brown
        case "modern":
            color = UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
        case "advanced":
            color = .gray
        case "future":
            color = .black
        default:
            color = .green
        }
        
        let material = SimpleMaterial(color: color, roughness: 0.6, isMetallic: true)
        return ModelEntity(mesh: mesh, materials: [material])
    }
    
    private func createSimpleAircraftFormation(count: Int) -> Entity {
        let formation = Entity()
        
        for i in 0..<count {
            let aircraft = createSimpleAircraft(generation: 3)
            aircraft.transform.translation = SIMD3<Float>(
                Float(i % 5) * 0.3 - 0.6,
                0,
                Float(i / 5) * 0.4
            )
            formation.addChild(aircraft)
        }
        
        return formation
    }
    
    private func createAdvancedAircraftFormation(count: Int) -> Entity {
        let formation = Entity()
        
        for i in 0..<count {
            let aircraft = createSimpleAircraft(generation: 4)
            aircraft.transform.translation = SIMD3<Float>(
                Float(i % 5) * 0.3 - 0.6,
                0,
                Float(i / 5) * 0.4
            )
            formation.addChild(aircraft)
        }
        
        return formation
    }
    
    private func createSixthGenFormation(count: Int) -> Entity {
        let formation = Entity()
        
        let sixthGenFighters = SixthGenFighterJet.createFlightFormation(count: count)
        for fighter in sixthGenFighters {
            formation.addChild(fighter)
        }
        
        return formation
    }
    
    private func createSimpleAircraft(generation: Int) -> Entity {
        let mesh = MeshResource.generateBox(width: 0.2, height: 0.03, depth: 0.4)
        var color: UIColor
        
        switch generation {
        case 3:
            color = .lightGray
        case 4:
            color = .gray
        case 5:
            color = UIColor.darkGray
        case 6:
            color = .black
        default:
            color = .gray
        }
        
        let material = SimpleMaterial(color: color, roughness: 0.3, isMetallic: true)
        return ModelEntity(mesh: mesh, materials: [material])
    }
    
    private func createYearInfoPanel(year: String, title: String, description: String) -> Entity {
        let panelEntity = Entity()
        
        let backgroundMesh = MeshResource.generatePlane(width: 2, height: 1)
        let backgroundMaterial = SimpleMaterial(color: UIColor.black.withAlphaComponent(0.8), isMetallic: false)
        let background = ModelEntity(mesh: backgroundMesh, materials: [backgroundMaterial])
        
        panelEntity.addChild(background)
        panelEntity.name = "\(year)InfoPanel"
        
        return panelEntity
    }
    
    func switchToYear(_ year: Int) {
        guard availableYears.contains(year) else { return }
        currentYear = year
        
        hideAllHistoricalScenes()
        showHistoricalScene(for: year)
    }
    
    private func hideAllHistoricalScenes() {
        for (_, scene) in historicalScenes {
            scene.isEnabled = false
        }
    }
    
    private func showHistoricalScene(for year: Int) {
        guard let scene = historicalScenes[year] else { return }
        scene.isEnabled = true
        
        if let anchor = arView.scene.anchors.first {
            if scene.parent == nil {
                anchor.addChild(scene)
            }
        }
    }
    
    func enableTimelineMode(_ enabled: Bool) {
        isTimelineModeActive = enabled
        
        if enabled {
            showHistoricalScene(for: currentYear)
        } else {
            hideAllHistoricalScenes()
        }
    }
}