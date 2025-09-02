import RealityKit
import MultipeerConnectivity
import SwiftUI

class MultiUserARSession: NSObject, ObservableObject {
    @Published var isSessionActive = false
    @Published var connectedPeers: [MCPeerID] = []
    @Published var receivedMessages: [ARMessage] = []
    
    private var session: MCSession
    private var advertiser: MCNearbyServiceAdvertiser
    private var browser: MCNearbyServiceBrowser
    private let serviceType = "military-parade"
    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    
    private weak var arView: ARView?
    
    override init() {
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        
        super.init()
        
        session.delegate = self
        advertiser.delegate = self
        browser.delegate = self
    }
    
    func setupARView(_ arView: ARView) {
        self.arView = arView
    }
    
    func startHosting() {
        advertiser.startAdvertisingPeer()
        isSessionActive = true
    }
    
    func startBrowsing() {
        browser.startBrowsingForPeers()
    }
    
    func stopSession() {
        advertiser.stopAdvertisingPeer()
        browser.stopBrowsingForPeers()
        session.disconnect()
        isSessionActive = false
        connectedPeers.removeAll()
    }
    
    func sendMessage(_ message: ARMessage) {
        guard !session.connectedPeers.isEmpty else { return }
        
        do {
            let data = try JSONEncoder().encode(message)
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Failed to send message: \(error)")
        }
    }
    
    func sendEntityUpdate(_ entity: Entity, action: EntityAction) {
        let message = ARMessage(
            type: .entityUpdate,
            senderID: myPeerID.displayName,
            data: EntityUpdateData(
                entityID: entity.name ?? UUID().uuidString,
                action: action,
                transform: entity.transform,
                timestamp: Date()
            )
        )
        sendMessage(message)
    }
    
    func sendPerspectiveChange(_ perspective: CameraPerspective) {
        let message = ARMessage(
            type: .perspectiveChange,
            senderID: myPeerID.displayName,
            data: PerspectiveChangeData(
                perspective: perspective,
                timestamp: Date()
            )
        )
        sendMessage(message)
    }
    
    func sendParadeControl(_ control: ParadeControlAction) {
        let message = ARMessage(
            type: .paradeControl,
            senderID: myPeerID.displayName,
            data: ParadeControlData(
                action: control,
                timestamp: Date()
            )
        )
        sendMessage(message)
    }
}

extension MultiUserARSession: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                if !self.connectedPeers.contains(peerID) {
                    self.connectedPeers.append(peerID)
                }
            case .notConnected:
                self.connectedPeers.removeAll { $0 == peerID }
            case .connecting:
                break
            @unknown default:
                break
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            let message = try JSONDecoder().decode(ARMessage.self, from: data)
            DispatchQueue.main.async {
                self.handleReceivedMessage(message)
            }
        } catch {
            print("Failed to decode message: \(error)")
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
    
    private func handleReceivedMessage(_ message: ARMessage) {
        receivedMessages.append(message)
        
        switch message.type {
        case .entityUpdate:
            if let data = message.data as? EntityUpdateData {
                handleEntityUpdate(data)
            }
        case .perspectiveChange:
            if let data = message.data as? PerspectiveChangeData {
                handlePerspectiveChange(data)
            }
        case .paradeControl:
            if let data = message.data as? ParadeControlData {
                handleParadeControl(data)
            }
        case .chatMessage:
            if let data = message.data as? ChatMessageData {
                handleChatMessage(data)
            }
        }
    }
    
    private func handleEntityUpdate(_ data: EntityUpdateData) {
        guard let arView = arView else { return }
        
    }
    
    private func handlePerspectiveChange(_ data: PerspectiveChangeData) {
        
    }
    
    private func handleParadeControl(_ data: ParadeControlData) {
        
    }
    
    private func handleChatMessage(_ data: ChatMessageData) {
        
    }
}

extension MultiUserARSession: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}

extension MultiUserARSession: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost peer: \(peerID)")
    }
}

struct ARMessage: Codable {
    let id = UUID()
    let type: MessageType
    let senderID: String
    let data: MessageData
    let timestamp = Date()
    
    enum MessageType: String, Codable {
        case entityUpdate
        case perspectiveChange
        case paradeControl
        case chatMessage
    }
}

protocol MessageData: Codable {}

struct EntityUpdateData: MessageData {
    let entityID: String
    let action: EntityAction
    let transform: Transform
    let timestamp: Date
}

struct PerspectiveChangeData: MessageData {
    let perspective: CameraPerspective
    let timestamp: Date
}

struct ParadeControlData: MessageData {
    let action: ParadeControlAction
    let timestamp: Date
}

struct ChatMessageData: MessageData {
    let message: String
    let timestamp: Date
}

enum EntityAction: String, Codable {
    case created
    case moved
    case rotated
    case scaled
    case deleted
    case selected
}

enum ParadeControlAction: String, Codable {
    case start
    case pause
    case stop
    case reset
    case nextPhase
}

extension CameraPerspective: Codable {}
extension Transform: Codable {}

struct MultiUserControlView: View {
    @ObservedObject var multiUserSession: MultiUserARSession
    @State private var showingPeerList = false
    @State private var chatMessage = ""
    @State private var showingChat = false
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    if multiUserSession.isSessionActive {
                        multiUserSession.stopSession()
                    } else {
                        multiUserSession.startHosting()
                        multiUserSession.startBrowsing()
                    }
                }) {
                    HStack {
                        Image(systemName: multiUserSession.isSessionActive ? "person.2.fill" : "person.2")
                        Text(multiUserSession.isSessionActive ? "断开连接" : "多人协同")
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(multiUserSession.isSessionActive ? Color.green.opacity(0.8) : Color.blue.opacity(0.8))
                    .cornerRadius(15)
                }
                
                if multiUserSession.isSessionActive && !multiUserSession.connectedPeers.isEmpty {
                    Button("参与者 (\(multiUserSession.connectedPeers.count))") {
                        showingPeerList = true
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.orange.opacity(0.8))
                    .cornerRadius(15)
                }
                
                Spacer()
                
                if multiUserSession.isSessionActive {
                    Button(action: {
                        showingChat = true
                    }) {
                        Image(systemName: "message.fill")
                            .foregroundColor(.white)
                            .font(.title3)
                            .frame(width: 40, height: 40)
                            .background(Color.purple.opacity(0.8))
                            .cornerRadius(20)
                    }
                }
            }
            .padding()
        }
        .sheet(isPresented: $showingPeerList) {
            PeerListView(peers: multiUserSession.connectedPeers)
        }
        .sheet(isPresented: $showingChat) {
            ChatView(
                multiUserSession: multiUserSession,
                messages: multiUserSession.receivedMessages
            )
        }
    }
}

struct PeerListView: View {
    let peers: [MCPeerID]
    
    var body: some View {
        NavigationView {
            List(peers, id: \.self) { peer in
                HStack {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                    
                    VStack(alignment: .leading) {
                        Text(peer.displayName)
                            .font(.headline)
                        Text("已连接")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("参与者")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        
                    }
                }
            }
        }
    }
}

struct ChatView: View {
    let multiUserSession: MultiUserARSession
    let messages: [ARMessage]
    @State private var newMessage = ""
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(chatMessages, id: \.id) { message in
                            ChatBubbleView(message: message)
                        }
                    }
                    .padding()
                }
                
                HStack {
                    TextField("输入消息...", text: $newMessage)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("发送") {
                        sendMessage()
                    }
                    .disabled(newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
            }
            .navigationTitle("协同聊天")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        
                    }
                }
            }
        }
    }
    
    private var chatMessages: [ARMessage] {
        messages.filter { $0.type == .chatMessage }
    }
    
    private func sendMessage() {
        let trimmedMessage = newMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }
        
        let message = ARMessage(
            type: .chatMessage,
            senderID: multiUserSession.session.myPeerID.displayName,
            data: ChatMessageData(message: trimmedMessage, timestamp: Date())
        )
        
        multiUserSession.sendMessage(message)
        newMessage = ""
    }
}

struct ChatBubbleView: View {
    let message: ARMessage
    
    var body: some View {
        if let data = message.data as? ChatMessageData {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.senderID)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(data.message)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(15)
                }
                Spacer()
            }
        }
    }
}