import RealityKit
import ARKit
import SwiftUI

class MilitaryParadeScene: ObservableObject {
    private let arView: ARView
    private var paradeAnchor: AnchorEntity?
    private var tiananmenScene: Entity?
    private var militaryFormations: [MilitaryFormation] = []
    private var aircraftFormations: [AircraftFormation] = []
    private var isParadeActive = false
    private var paradeTimer: Timer?
    private var currentTimelineYear: Int = 2025
    
    @Published var selectedEntity: Entity?
    @Published var currentParadePhase: ParadePhase = .preparation
    
    enum ParadePhase {
        case preparation
        case marchingBegins
        case infantryParade
        case equipmentParade
        case aircraftFlyover
        case completed
    }
    
    init(arView: ARView) {
        self.arView = arView
        loadAssets()
    }
    
    private func loadAssets() {
        Task {
            await loadTiananmenSquareScene()
            await loadMilitaryAssets()
        }
    }
    
    func placeParadeSceneAt(location: CGPoint, in arView: ARView) {
        guard let raycastResult = arView.raycast(from: location, allowing: .existingPlaneGeometry, alignment: .horizontal).first else {
            return
        }
        
        if paradeAnchor != nil {
            arView.scene.removeAnchor(paradeAnchor!)
        }
        
        paradeAnchor = AnchorEntity(world: raycastResult.worldTransform)
        arView.scene.addAnchor(paradeAnchor!)
        
        setupTiananmenSquare()
        setupMilitaryFormations()
        
        DispatchQueue.main.async {
            self.currentParadePhase = .preparation
        }
    }
    
    private func setupTiananmenSquare() {
        guard let anchor = paradeAnchor else { return }
        
        let tiananmenSquare = Entity()
        
        let groundPlane = createGroundPlane()
        tiananmenSquare.addChild(groundPlane)
        
        let tiananmenGate = createTiananmenGate()
        tiananmenGate.transform.translation = SIMD3<Float>(0, 0, -5)
        tiananmenSquare.addChild(tiananmenGate)
        
        let monumentOfHeroes = createMonumentOfHeroes()
        monumentOfHeroes.transform.translation = SIMD3<Float>(0, 0, 2)
        tiananmenSquare.addChild(monumentOfHeroes)
        
        let greatHallOfPeople = createGreatHallOfPeople()
        greatHallOfPeople.transform.translation = SIMD3<Float>(-4, 0, 0)
        tiananmenSquare.addChild(greatHallOfPeople)
        
        let nationalMuseum = createNationalMuseum()
        nationalMuseum.transform.translation = SIMD3<Float>(4, 0, 0)
        tiananmenSquare.addChild(nationalMuseum)
        
        tiananmenSquare.scale = SIMD3<Float>(0.1, 0.1, 0.1)
        
        self.tiananmenScene = tiananmenSquare
        anchor.addChild(tiananmenSquare)
    }
    
    private func createGroundPlane() -> Entity {
        let mesh = MeshResource.generatePlane(width: 100, depth: 80)
        let material = SimpleMaterial(color: .gray, roughness: 0.7, isMetallic: false)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.name = "TiananmenSquareGround"
        return entity
    }
    
    private func createTiananmenGate() -> Entity {
        let gateBase = MeshResource.generateBox(width: 20, height: 4, depth: 2)
        let gateMaterial = SimpleMaterial(color: .red, roughness: 0.3, isMetallic: false)
        let gateEntity = ModelEntity(mesh: gateBase, materials: [gateMaterial])
        
        let roof = MeshResource.generateBox(width: 22, height: 0.5, depth: 3)
        let roofMaterial = SimpleMaterial(color: .yellow, roughness: 0.2, isMetallic: false)
        let roofEntity = ModelEntity(mesh: roof, materials: [roofMaterial])
        roofEntity.transform.translation = SIMD3<Float>(0, 2.5, 0)
        
        gateEntity.addChild(roofEntity)
        gateEntity.name = "TiananmenGate"
        
        return gateEntity
    }
    
    private func createMonumentOfHeroes() -> Entity {
        let monumentMesh = MeshResource.generateBox(width: 2, height: 8, depth: 2)
        let monumentMaterial = SimpleMaterial(color: .white, roughness: 0.1, isMetallic: false)
        let monument = ModelEntity(mesh: monumentMesh, materials: [monumentMaterial])
        monument.name = "MonumentOfHeroes"
        return monument
    }
    
    private func createGreatHallOfPeople() -> Entity {
        let hallMesh = MeshResource.generateBox(width: 15, height: 6, depth: 10)
        let hallMaterial = SimpleMaterial(color: .brown, roughness: 0.4, isMetallic: false)
        let hall = ModelEntity(mesh: hallMesh, materials: [hallMaterial])
        hall.name = "GreatHallOfPeople"
        return hall
    }
    
    private func createNationalMuseum() -> Entity {
        let museumMesh = MeshResource.generateBox(width: 15, height: 6, depth: 10)
        let museumMaterial = SimpleMaterial(color: .brown, roughness: 0.4, isMetallic: false)
        let museum = ModelEntity(mesh: museumMesh, materials: [museumMaterial])
        museum.name = "NationalMuseum"
        return museum
    }
    
    @MainActor
    private func loadTiananmenSquareScene() async {
        
    }
    
    @MainActor
    private func loadMilitaryAssets() async {
        
    }
    
    private func setupMilitaryFormations() {
        guard paradeAnchor != nil else { return }
        
        createInfantryFormations()
        createEquipmentFormations()
        createAircraftFormations()
    }
    
    private func createInfantryFormations() {
        guard let anchor = paradeAnchor else { return }
        
        let formations = [
            ("仪仗队", SIMD3<Float>(-3, 0, 8), UIColor.blue),
            ("陆军方队", SIMD3<Float>(-1, 0, 8), UIColor.green),
            ("海军方队", SIMD3<Float>(1, 0, 8), UIColor.blue),
            ("空军方队", SIMD3<Float>(3, 0, 8), UIColor.cyan),
            ("火箭军方队", SIMD3<Float>(5, 0, 8), UIColor.orange)
        ]
        
        for (name, position, color) in formations {
            let formation = createInfantryFormation(name: name, color: color)
            formation.transform.translation = position
            anchor.addChild(formation)
        }
    }
    
    private func createInfantryFormation(name: String, color: UIColor) -> Entity {
        let formationEntity = Entity()
        formationEntity.name = name
        
        for row in 0..<8 {
            for col in 0..<10 {
                let soldier = createSoldier(color: color)
                soldier.transform.translation = SIMD3<Float>(
                    Float(col) * 0.15 - 0.75,
                    0,
                    Float(row) * 0.2
                )
                formationEntity.addChild(soldier)
            }
        }
        
        return formationEntity
    }
    
    private func createSoldier(color: UIColor) -> Entity {
        let mesh = MeshResource.generateBox(width: 0.08, height: 0.3, depth: 0.04)
        let material = SimpleMaterial(color: color, roughness: 0.5, isMetallic: false)
        let soldier = ModelEntity(mesh: mesh, materials: [material])
        return soldier
    }
    
    private func createEquipmentFormations() {
        guard let anchor = paradeAnchor else { return }
        
        let equipmentData = [
            ("主战坦克", SIMD3<Float>(-2, 0, 12), UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)),
            ("装甲车", SIMD3<Float>(0, 0, 12), UIColor.brown),
            ("导弹发射车", SIMD3<Float>(2, 0, 12), UIColor.gray),
            ("火炮", SIMD3<Float>(4, 0, 12), UIColor.darkGray)
        ]
        
        for (name, position, color) in equipmentData {
            let equipment = createMilitaryVehicle(name: name, color: color)
            equipment.transform.translation = position
            anchor.addChild(equipment)
        }
    }
    
    private func createMilitaryVehicle(name: String, color: UIColor) -> Entity {
        let vehicleMesh = MeshResource.generateBox(width: 0.4, height: 0.15, depth: 0.8)
        let vehicleMaterial = SimpleMaterial(color: color, roughness: 0.6, isMetallic: true)
        let vehicle = ModelEntity(mesh: vehicleMesh, materials: [vehicleMaterial])
        vehicle.name = name
        return vehicle
    }
    
    private func createAircraftFormations() {
        
    }
    
    func handleEntitySelection(_ entity: Entity) {
        selectedEntity = entity
        
        if let infoPanel = createInfoPanel(for: entity) {
            entity.addChild(infoPanel)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                infoPanel.removeFromParent()
            }
        }
    }
    
    private func createInfoPanel(for entity: Entity) -> Entity? {
        guard entity.name != nil else { return nil }
        
        let panelEntity = Entity()
        
        let backgroundMesh = MeshResource.generatePlane(width: 1, height: 0.3)
        let backgroundMaterial = SimpleMaterial(color: UIColor.black.withAlphaComponent(0.8), isMetallic: false)
        let background = ModelEntity(mesh: backgroundMesh, materials: [backgroundMaterial])
        
        background.transform.translation = SIMD3<Float>(0, 0.5, 0)
        panelEntity.addChild(background)
        
        return panelEntity
    }
    
    func handleScaleGesture(scale: Float) {
        guard let tiananmen = tiananmenScene else { return }
        let clampedScale = max(0.05, min(0.3, scale * 0.1))
        tiananmen.scale = SIMD3<Float>(clampedScale, clampedScale, clampedScale)
    }
    
    func handleRotationGesture(rotation: Float) {
        guard let tiananmen = tiananmenScene else { return }
        tiananmen.transform.rotation = simd_quatf(angle: rotation, axis: SIMD3<Float>(0, 1, 0))
    }
    
    func switchToPerspective(_ perspective: CameraPerspective) {
        
    }
    
    func setTimelineMode(_ enabled: Bool) {
        
    }
    
    func startParade() {
        guard !isParadeActive else { return }
        isParadeActive = true
        
        DispatchQueue.main.async {
            self.currentParadePhase = .marchingBegins
        }
        
        startParadeSequence()
    }
    
    func pauseParade() {
        isParadeActive = false
        paradeTimer?.invalidate()
        paradeTimer = nil
    }
    
    private func startParadeSequence() {
        paradeTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            self.advanceParadePhase()
        }
    }
    
    private func advanceParadePhase() {
        DispatchQueue.main.async {
            switch self.currentParadePhase {
            case .preparation:
                self.currentParadePhase = .marchingBegins
            case .marchingBegins:
                self.currentParadePhase = .infantryParade
            case .infantryParade:
                self.currentParadePhase = .equipmentParade
            case .equipmentParade:
                self.currentParadePhase = .aircraftFlyover
            case .aircraftFlyover:
                self.currentParadePhase = .completed
            case .completed:
                self.pauseParade()
            }
        }
    }
}

struct MilitaryFormation {
    let name: String
    let entity: Entity
    let formationType: FormationType
    
    enum FormationType {
        case infantry
        case vehicle
        case aircraft
    }
}

struct AircraftFormation {
    let name: String
    let aircraft: [Entity]
    let flightPath: [SIMD3<Float>]
}