import SwiftUI
import AVFoundation
import AudioToolbox

struct AlarmView: View {
    let todoTitle: String
    let subtitle: String
    let onDismiss: () -> Void

    @State private var isAnimating = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var vibrationTimer: Timer?

    var body: some View {
        ZStack {
            // 배경 그라데이션
            LinearGradient(
                colors: [Color(hex: "FF8A65"), Color(hex: "FF6B6B"), Color(hex: "A78BFA")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ).ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // 알람 아이콘 (흔들림 애니메이션)
                Text("🔔")
                    .font(.system(size: 80))
                    .rotationEffect(.degrees(isAnimating ? 15 : -15))
                    .animation(
                        .easeInOut(duration: 0.15).repeatForever(autoreverses: true),
                        value: isAnimating
                    )

                VStack(spacing: 12) {
                    Text("Todoly 알림")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))

                    Text(todoTitle)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    Text(subtitle)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                // 해제 버튼
                Button {
                    stopAlarm()
                    NotificationService.shared.endAlarmLiveActivity()
                    onDismiss()
                } label: {
                    Text("알림 끄기")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "FF6B6B"))
                        .frame(maxWidth: .infinity).frame(height: 56)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                        .shadow(color: .black.opacity(0.2), radius: 20, y: 8)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            isAnimating = true
            startAlarm()
        }
        .onDisappear {
            stopAlarm()
        }
    }

    // MARK: - Alarm Control

    private func startAlarm() {
        // 오디오 세션 설정 (무음모드에서도 재생)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("오디오 세션 설정 실패: \(error)")
        }

        // 커스텀 알람 사운드 재생
        if let url = Bundle.main.url(forResource: "todoly_alarm", withExtension: "caf") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.numberOfLoops = -1 // 무한 반복
                audioPlayer?.volume = 1.0
                audioPlayer?.play()
            } catch {
                print("알람 사운드 재생 실패: \(error)")
            }
        }

        // 진동 반복
        vibrationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }

    private func stopAlarm() {
        audioPlayer?.stop()
        audioPlayer = nil
        vibrationTimer?.invalidate()
        vibrationTimer = nil
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}

// MARK: - Preview

#Preview("AlarmView") {
    AlarmView(todoTitle: "프로젝트 보고서 제출", subtitle: "마감 시간입니다!") {}
}
