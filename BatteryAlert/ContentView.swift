import SwiftUI
import UserNotifications
import IOKit.ps

struct ContentView: View {
    @State private var batteryLevel: Int = 100
    @State private var lowThreshold = 20
    @State private var highThreshold = 80
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("🔋 Current Battery: \(batteryLevel)%")
                .font(.title)

            HStack {
                Text("Low Threshold:")
                TextField("e.g. 20", value: $lowThreshold, formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 60)
            }

            HStack {
                Text("High Threshold:")
                TextField("e.g. 80", value: $highThreshold, formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 60)
            }

            Button("Check Now") {
                checkBattery()
            }
        }
        .padding()
        .onAppear(perform: startBatteryMonitor)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Battery Alert"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    func startBatteryMonitor() {
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            checkBattery()
        }
    }

    func checkBattery() {
        let current = getBatteryPercentage()
        batteryLevel = current

        if current <= lowThreshold {
            alertMessage = "🔌 Battery low (\(current)%) - Please plug in!"
            showAlert = true
            triggerNotification(alertMessage)
        } else if current >= highThreshold {
            alertMessage = "⚡ Battery high (\(current)%) - Please unplug!"
            showAlert = true
            triggerNotification(alertMessage)
        }
    }

    func triggerNotification(_ message: String) {
        let content = UNMutableNotificationContent()
        content.title = "Battery Alert"
        content.body = message
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    func getBatteryPercentage() -> Int {
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef],
              let source = sources.first,
              let description = IOPSGetPowerSourceDescription(snapshot, source)?.takeUnretainedValue() as? [String: Any],
              let currentCapacity = description[kIOPSCurrentCapacityKey as String] as? Int,
              let maxCapacity = description[kIOPSMaxCapacityKey as String] as? Int else {
            return -1
        }

        return Int((Double(currentCapacity) / Double(maxCapacity)) * 100)
    }
}
