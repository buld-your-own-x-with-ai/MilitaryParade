import SwiftUI
import RealityKit
import ARKit

struct MilitaryParadeARView: View {
    @State private var isARSessionActive = false
    @State private var selectedPerspective: CameraPerspective = .free
    @State private var isTimelineModeEnabled = false
    @State private var showingWelcomeScreen = true
    
    var body: some View {
        ZStack {
            if showingWelcomeScreen {
                WelcomeView {
                    withAnimation {
                        showingWelcomeScreen = false
                    }
                }
            } else {
                ARViewContainer(
                    isARSessionActive: $isARSessionActive,
                    selectedPerspective: $selectedPerspective,
                    isTimelineModeEnabled: $isTimelineModeEnabled
                )
                .edgesIgnoringSafeArea(.all)
                
                MilitaryParadeControlView(
                    isARSessionActive: $isARSessionActive,
                    selectedPerspective: $selectedPerspective,
                    isTimelineModeEnabled: $isTimelineModeEnabled
                )
            }
        }
    }
}

struct WelcomeView: View {
    let onStart: () -> Void
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.red, .yellow]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Spacer()
                
                VStack(spacing: 20) {
                    Image(systemName: "flag.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                        .offset(y: animationOffset)
                        .animation(
                            Animation.easeInOut(duration: 2)
                                .repeatForever(autoreverses: true),
                            value: animationOffset
                        )
                    
                    Text("2025年9月3日")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("中华人民共和国")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                    
                    Text("大阅兵AR体验")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                VStack(spacing: 15) {
                    FeatureRow(
                        icon: "camera.viewfinder",
                        text: "沉浸式AR场景还原"
                    )
                    
                    FeatureRow(
                        icon: "airplane",
                        text: "六代机首次亮相"
                    )
                    
                    FeatureRow(
                        icon: "clock.arrow.circlepath",
                        text: "历史时光回溯功能"
                    )
                    
                    FeatureRow(
                        icon: "person.3.fill",
                        text: "多人协同体验"
                    )
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: onStart) {
                    HStack {
                        Image(systemName: "arkit")
                        Text("开始AR体验")
                            .fontWeight(.semibold)
                    }
                    .font(.title3)
                    .foregroundColor(.red)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 15)
                    .background(Color.white)
                    .cornerRadius(25)
                    .shadow(radius: 5)
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            animationOffset = -10
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 30)
            
            Text(text)
                .font(.body)
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

struct SixthGenFighterModel: View {
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [.blue.opacity(0.1), .blue.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 300, height: 200)
            
            VStack {
                Image(systemName: "airplane")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                    .rotationEffect(.degrees(rotationAngle))
                    .animation(
                        Animation.linear(duration: 4)
                            .repeatForever(autoreverses: false),
                        value: rotationAngle
                    )
                
                Text("第六代隐身战斗机")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("首次公开展示")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            rotationAngle = 360
        }
    }
}

#Preview {
    MilitaryParadeARView()
}