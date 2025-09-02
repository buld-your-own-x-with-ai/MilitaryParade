import SwiftUI
import RealityKit
import AVFoundation

struct MilitaryParadeControlView: View {
    @Binding var isARSessionActive: Bool
    @Binding var selectedPerspective: CameraPerspective
    @Binding var isTimelineModeEnabled: Bool
    @State private var selectedTimelineYear: Int = 2025
    @State private var showingKnowledgeCard = false
    @State private var selectedKnowledgeCard: KnowledgeCard?
    @State private var audioPlayer: AVAudioPlayer?
    
    let timelineYears = [1949, 1984, 1999, 2009, 2015, 2019, 2025]
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    perspectiveControls
                    timelineControls
                    paradeControls
                }
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(15)
                
                Spacer()
                
                VStack(spacing: 10) {
                    knowledgeButton
                    settingsButton
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingKnowledgeCard) {
            if let card = selectedKnowledgeCard {
                KnowledgeCardView(card: card)
            }
        }
    }
    
    private var perspectiveControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("视角选择")
                .foregroundColor(.white)
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(CameraPerspective.allCases, id: \.self) { perspective in
                    Button(perspective.displayName) {
                        selectedPerspective = perspective
                        playButtonSound()
                    }
                    .font(.caption)
                    .foregroundColor(selectedPerspective == perspective ? .black : .white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(selectedPerspective == perspective ? Color.yellow : Color.clear)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.yellow, lineWidth: 1)
                    )
                }
            }
        }
    }
    
    private var timelineControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("时光回溯")
                    .foregroundColor(.white)
                    .font(.headline)
                
                Toggle("", isOn: $isTimelineModeEnabled)
                    .toggleStyle(SwitchToggleStyle())
                    .scaleEffect(0.8)
            }
            
            if isTimelineModeEnabled {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(timelineYears, id: \.self) { year in
                            Button("\(year)年") {
                                selectedTimelineYear = year
                                playButtonSound()
                            }
                            .font(.caption)
                            .foregroundColor(selectedTimelineYear == year ? .black : .white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedTimelineYear == year ? Color.red : Color.clear)
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.red, lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
    }
    
    private var paradeControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("阅兵控制")
                .foregroundColor(.white)
                .font(.headline)
            
            HStack(spacing: 15) {
                Button(action: {
                    isARSessionActive.toggle()
                    playButtonSound()
                }) {
                    Image(systemName: isARSessionActive ? "pause.fill" : "play.fill")
                        .foregroundColor(.white)
                        .font(.title2)
                        .frame(width: 40, height: 40)
                        .background(Color.green.opacity(0.8))
                        .cornerRadius(20)
                }
                
                Button(action: {
                    isARSessionActive = false
                    playButtonSound()
                }) {
                    Image(systemName: "stop.fill")
                        .foregroundColor(.white)
                        .font(.title2)
                        .frame(width: 40, height: 40)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(20)
                }
                
                Button("重置场景") {
                    resetScene()
                    playButtonSound()
                }
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.8))
                .cornerRadius(15)
            }
        }
    }
    
    private var knowledgeButton: some View {
        Button(action: {
            selectedKnowledgeCard = KnowledgeCard.sampleCards.randomElement()
            showingKnowledgeCard = true
            playButtonSound()
        }) {
            Image(systemName: "book.fill")
                .foregroundColor(.white)
                .font(.title2)
                .frame(width: 50, height: 50)
                .background(Color.blue.opacity(0.8))
                .cornerRadius(25)
        }
    }
    
    private var settingsButton: some View {
        Button(action: {
            playButtonSound()
        }) {
            Image(systemName: "gearshape.fill")
                .foregroundColor(.white)
                .font(.title2)
                .frame(width: 50, height: 50)
                .background(Color.gray.opacity(0.8))
                .cornerRadius(25)
        }
    }
    
    private func resetScene() {
        isARSessionActive = false
        selectedPerspective = .free
        isTimelineModeEnabled = false
        selectedTimelineYear = 2025
    }
    
    private func playButtonSound() {
        guard let soundURL = Bundle.main.url(forResource: "button_click", withExtension: "mp3") else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.volume = 0.3
            audioPlayer?.play()
        } catch {
            print("Error playing button sound: \(error)")
        }
    }
}

struct KnowledgeCard: Identifiable {
    let id = UUID()
    let title: String
    let content: String
    let category: Category
    let imageSystemName: String
    
    enum Category {
        case history
        case equipment
        case formation
        case significance
        
        var displayName: String {
            switch self {
            case .history:
                return "历史背景"
            case .equipment:
                return "装备介绍"
            case .formation:
                return "队列知识"
            case .significance:
                return "意义阐述"
            }
        }
        
        var color: Color {
            switch self {
            case .history:
                return .brown
            case .equipment:
                return .green
            case .formation:
                return .blue
            case .significance:
                return .red
            }
        }
    }
    
    static let sampleCards = [
        KnowledgeCard(
            title: "中华人民共和国成立75周年",
            content: "2025年是中华人民共和国成立75周年。从1949年开国大典到今日，国庆阅兵展现了人民军队的发展历程和国家综合实力的提升。每一次阅兵都承载着历史的记忆和民族的自豪。",
            category: .history,
            imageSystemName: "flag.fill"
        ),
        KnowledgeCard(
            title: "六代机首次公开亮相",
            content: "2025年阅兵中，我国自主研发的第六代隐身战斗机首次公开展示。该机型采用先进的人工智能辅助驾驶系统、变循环发动机技术，代表了我国航空工业的最高水平。",
            category: .equipment,
            imageSystemName: "airplane"
        ),
        KnowledgeCard(
            title: "仪仗队的正步走",
            content: "中国人民解放军仪仗队的正步走是阅兵式上最具标志性的动作。每分钟116步的节拍、75厘米的步幅、25厘米的摆臂高度，展现了中国军人的精神风貌。",
            category: .formation,
            imageSystemName: "figure.walk"
        ),
        KnowledgeCard(
            title: "阅兵的时代意义",
            content: "阅兵不仅是展示国防力量，更是彰显和平发展决心。通过阅兵，向世界传递中国维护和平、促进发展的理念，展现负责任大国的形象。",
            category: .significance,
            imageSystemName: "globe.asia.australia.fill"
        )
    ]
}

struct KnowledgeCardView: View {
    let card: KnowledgeCard
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image(systemName: card.imageSystemName)
                        .font(.largeTitle)
                        .foregroundColor(card.category.color)
                    
                    VStack(alignment: .leading) {
                        Text(card.category.displayName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(card.title)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(card.category.color.opacity(0.1))
                .cornerRadius(15)
                
                ScrollView {
                    Text(card.content)
                        .font(.body)
                        .lineSpacing(6)
                        .padding()
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("知识卡片")
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