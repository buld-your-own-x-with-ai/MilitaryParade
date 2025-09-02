import RealityKit
import ARKit
import SwiftUI

class SixthGenFighterJet {
    static func createModel() -> Entity {
        let fighterEntity = Entity()
        fighterEntity.name = "SixthGenFighter"
        
        let fuselage = createFuselage()
        let wings = createWings()
        let engines = createEngines()
        let cockpit = createCockpit()
        
        fighterEntity.addChild(fuselage)
        fighterEntity.addChild(wings)
        fighterEntity.addChild(engines)
        fighterEntity.addChild(cockpit)
        
        addSpecialEffects(to: fighterEntity)
        
        return fighterEntity
    }
    
    private static func createFuselage() -> Entity {
        let fuselageMesh = MeshResource.generateBox(width: 0.3, height: 0.08, depth: 1.2)
        let fuselageMaterial = SimpleMaterial(color: UIColor.darkGray, roughness: 0.2, isMetallic: true)
        let fuselage = ModelEntity(mesh: fuselageMesh, materials: [fuselageMaterial])
        fuselage.name = "Fuselage"
        return fuselage
    }
    
    private static func createWings() -> Entity {
        let wingsEntity = Entity()
        
        let leftWingMesh = MeshResource.generateBox(width: 0.8, height: 0.02, depth: 0.4)
        let rightWingMesh = MeshResource.generateBox(width: 0.8, height: 0.02, depth: 0.4)
        let wingMaterial = SimpleMaterial(color: .gray, roughness: 0.15, isMetallic: true)
        
        let leftWing = ModelEntity(mesh: leftWingMesh, materials: [wingMaterial])
        let rightWing = ModelEntity(mesh: rightWingMesh, materials: [wingMaterial])
        
        leftWing.transform.translation = SIMD3<Float>(-0.4, 0, 0)
        rightWing.transform.translation = SIMD3<Float>(0.4, 0, 0)
        
        let deltaWingMesh = MeshResource.generateBox(width: 0.6, height: 0.02, depth: 0.8)
        let deltaWing = ModelEntity(mesh: deltaWingMesh, materials: [wingMaterial])
        deltaWing.transform.translation = SIMD3<Float>(0, 0, -0.3)
        
        wingsEntity.addChild(leftWing)
        wingsEntity.addChild(rightWing)
        wingsEntity.addChild(deltaWing)
        wingsEntity.name = "Wings"
        
        return wingsEntity
    }
    
    private static func createEngines() -> Entity {
        let enginesEntity = Entity()
        
        let leftEngineMesh = MeshResource.generateCylinder(height: 0.6, radius: 0.08)
        let rightEngineMesh = MeshResource.generateCylinder(height: 0.6, radius: 0.08)
        let engineMaterial = SimpleMaterial(color: .black, roughness: 0.1, isMetallic: true)
        
        let leftEngine = ModelEntity(mesh: leftEngineMesh, materials: [engineMaterial])
        let rightEngine = ModelEntity(mesh: rightEngineMesh, materials: [engineMaterial])
        
        leftEngine.transform.translation = SIMD3<Float>(-0.15, -0.05, -0.3)
        rightEngine.transform.translation = SIMD3<Float>(0.15, -0.05, -0.3)
        
        leftEngine.transform.rotation = simd_quatf(angle: .pi/2, axis: SIMD3<Float>(0, 0, 1))
        rightEngine.transform.rotation = simd_quatf(angle: .pi/2, axis: SIMD3<Float>(0, 0, 1))
        
        enginesEntity.addChild(leftEngine)
        enginesEntity.addChild(rightEngine)
        enginesEntity.name = "Engines"
        
        return enginesEntity
    }
    
    private static func createCockpit() -> Entity {
        let cockpitMesh = MeshResource.generateSphere(radius: 0.1)
        let cockpitMaterial = SimpleMaterial(color: UIColor.blue.withAlphaComponent(0.6), roughness: 0.0, isMetallic: false)
        let cockpit = ModelEntity(mesh: cockpitMesh, materials: [cockpitMaterial])
        cockpit.transform.translation = SIMD3<Float>(0, 0.08, 0.3)
        cockpit.name = "Cockpit"
        return cockpit
    }
    
    private static func addSpecialEffects(to fighter: Entity) {
        addStealthCoating(to: fighter)
        addThrusterEffects(to: fighter)
    }
    
    private static func addStealthCoating(to fighter: Entity) {
        
    }
    
    private static func addThrusterEffects(to fighter: Entity) {
        
    }
    
    static func createFlightFormation(count: Int = 9) -> [Entity] {
        var formation: [Entity] = []
        
        let positions = [
            SIMD3<Float>(0, 0, 0),
            SIMD3<Float>(-0.5, 0, -0.3),
            SIMD3<Float>(0.5, 0, -0.3),
            SIMD3<Float>(-1.0, 0, -0.6),
            SIMD3<Float>(1.0, 0, -0.6),
            SIMD3<Float>(-1.5, 0, -0.9),
            SIMD3<Float>(1.5, 0, -0.9),
            SIMD3<Float>(-2.0, 0, -1.2),
            SIMD3<Float>(2.0, 0, -1.2)
        ]
        
        for i in 0..<min(count, positions.count) {
            let fighter = createModel()
            fighter.transform.translation = positions[i]
            formation.append(fighter)
        }
        
        return formation
    }
    
    static func getSpecifications() -> [String: String] {
        return [
            "名称": "歼-XX 第六代隐身战斗机",
            "最大速度": "马赫 3.5+",
            "航程": "4000+ 公里",
            "特色功能": "AI 辅助驾驶、变循环发动机、主动隐身技术",
            "武器系统": "内置弹舱、激光武器、电磁炮",
            "雷达系统": "有源相控阵雷达 + 量子雷达",
            "首飞时间": "2024年",
            "服役状态": "2025年正式服役"
        ]
    }
}

class ModernMilitaryEquipment {
    static func createMainBattleTank() -> Entity {
        let tankEntity = Entity()
        tankEntity.name = "Type99A主战坦克"
        
        let hull = MeshResource.generateBox(width: 0.8, height: 0.3, depth: 1.2)
        let hullMaterial = SimpleMaterial(color: UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0), roughness: 0.6, isMetallic: true)
        let hullModel = ModelEntity(mesh: hull, materials: [hullMaterial])
        
        let turret = MeshResource.generateCylinder(height: 0.2, radius: 0.35)
        let turretModel = ModelEntity(mesh: turret, materials: [hullMaterial])
        turretModel.transform.translation = SIMD3<Float>(0, 0.25, 0)
        
        let barrel = MeshResource.generateCylinder(height: 1.0, radius: 0.03)
        let barrelModel = ModelEntity(mesh: barrel, materials: [hullMaterial])
        barrelModel.transform.translation = SIMD3<Float>(0, 0, 0.5)
        barrelModel.transform.rotation = simd_quatf(angle: .pi/2, axis: SIMD3<Float>(0, 0, 1))
        
        tankEntity.addChild(hullModel)
        tankEntity.addChild(turretModel)
        tankEntity.addChild(barrelModel)
        
        return tankEntity
    }
    
    static func createICBM() -> Entity {
        let missileEntity = Entity()
        missileEntity.name = "东风-41洲际弹道导弹"
        
        let launcher = MeshResource.generateBox(width: 0.4, height: 0.3, depth: 2.0)
        let launcherMaterial = SimpleMaterial(color: .gray, roughness: 0.5, isMetallic: true)
        let launcherModel = ModelEntity(mesh: launcher, materials: [launcherMaterial])
        
        let missile = MeshResource.generateCylinder(height: 1.5, radius: 0.08)
        let missileMaterial = SimpleMaterial(color: .white, roughness: 0.3, isMetallic: false)
        let missileModel = ModelEntity(mesh: missile, materials: [missileMaterial])
        missileModel.transform.translation = SIMD3<Float>(0, 0.4, 0)
        
        missileEntity.addChild(launcherModel)
        missileEntity.addChild(missileModel)
        
        return missileEntity
    }
    
    static func createStrategicBomber() -> Entity {
        let bomberEntity = Entity()
        bomberEntity.name = "轰-20隐身战略轰炸机"
        
        let fuselage = MeshResource.generateBox(width: 0.4, height: 0.15, depth: 1.8)
        let fuselageMaterial = SimpleMaterial(color: UIColor.darkGray, roughness: 0.2, isMetallic: true)
        let fuselageModel = ModelEntity(mesh: fuselage, materials: [fuselageMaterial])
        
        let wings = MeshResource.generateBox(width: 2.0, height: 0.05, depth: 0.8)
        let wingsModel = ModelEntity(mesh: wings, materials: [fuselageMaterial])
        
        bomberEntity.addChild(fuselageModel)
        bomberEntity.addChild(wingsModel)
        
        return bomberEntity
    }
    
    static func createDroneSwarm() -> [Entity] {
        var swarm: [Entity] = []
        
        for i in 0..<12 {
            let drone = Entity()
            drone.name = "无人作战飞机"
            
            let body = MeshResource.generateBox(width: 0.15, height: 0.03, depth: 0.25)
            let bodyMaterial = SimpleMaterial(color: .black, roughness: 0.3, isMetallic: true)
            let bodyModel = ModelEntity(mesh: body, materials: [bodyMaterial])
            
            let propellers = MeshResource.generateCylinder(height: 0.01, radius: 0.08)
            let propellerMaterial = SimpleMaterial(color: .gray, roughness: 0.1, isMetallic: true)
            
            for j in 0..<4 {
                let propeller = ModelEntity(mesh: propellers, materials: [propellerMaterial])
                let angle = Float(j) * .pi / 2
                let radius: Float = 0.1
                propeller.transform.translation = SIMD3<Float>(
                    cos(angle) * radius,
                    0.05,
                    sin(angle) * radius
                )
                drone.addChild(propeller)
            }
            
            drone.addChild(bodyModel)
            
            let formation_x = Float(i % 4 - 1) * 0.3
            let formation_z = Float(i / 4 - 1) * 0.3
            drone.transform.translation = SIMD3<Float>(formation_x, Float(i) * 0.1, formation_z)
            
            swarm.append(drone)
        }
        
        return swarm
    }
}