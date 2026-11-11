import SwiftUI

struct RestReminderView: View {
    let durationSeconds: Int
    let onDismiss: () -> Void
    
    @State private var remainingSeconds: Int
    @State private var pulseScale: CGFloat = 1.0
    
    init(durationSeconds: Int = 20, onDismiss: @escaping () -> Void) {
        self.durationSeconds = durationSeconds
        self.onDismiss = onDismiss
        self._remainingSeconds = State(initialValue: durationSeconds)
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Calming "breathing" halo animation at the top
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.green.opacity(0.35), Color.clear],
                                center: .center,
                                startRadius: 20,
                                endRadius: 120
                            )
                        )
                        .frame(width: 240, height: 240)
                        .scaleEffect(pulseScale)
                        .animation(
                            Animation.easeInOut(duration: 2.5).repeatForever(autoreverses: true),
                            value: pulseScale
                        )
                    
                    Circle()
                        .stroke(Color.green.opacity(0.6), lineWidth: 4)
                        .frame(width: 140, height: 140)
                    
                    VStack(spacing: 4) {
                        Text("\(remainingSeconds)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("sec")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                VStack(spacing: 12) {
                    Text("🌿 20-20-20 Eye Break")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("Look at something at least 20 feet (6 meters) away for 20 seconds and blink a few times to let your eye muscles fully relax.")
                        .font(.system(size: 15))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.8))
                        .frame(maxWidth: 420)
                }
                
                // Skip button at the bottom
                Button(action: onDismiss) {
                    HStack(spacing: 6) {
                        Text("Skip Break (Esc)")
                        Image(systemName: "xmark.circle.fill")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(20)
                }
                .buttonStyle(.plain)
            }
        }
        .onAppear {
            pulseScale = 1.25
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                if remainingSeconds > 1 {
                    remainingSeconds -= 1
                } else {
                    timer.invalidate()
                    onDismiss()
                }
            }
            
            // Listen for the Esc key to dismiss
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if event.keyCode == 53 { // 53 is Esc key
                    onDismiss()
                    return nil
                }
                return event
            }
        }
    }
}
