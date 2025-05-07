import Foundation
import CoreMotion
import UserNotifications

class DashBoardViewModel: ObservableObject {
    private let motionManager = CMHeadphoneMotionManager()
    @Published var graphDataModel = DataModel() // 공유 데이터 모델
    @Published var extendedGraphDataModel = ExtendedDataModel()
    
    @Published var pitch: Double = 0
    @Published var roll: Double = 0
    
    @Published var referencePitch: Double = 0
    @Published var referenceRoll: Double = 0
    
    @Published var posture = true
    @Published var isPaused = false
    
    @Published var formattedTotalTime = "00:00"
    @Published var formattedNormalTime = "00:00"
    @Published var formattedAbnormalTime = "00:00"
    @Published var formattedConnectTime = "00:00"
    
    @Published var filteredForwardAcceleration: Double = 0
    
    private var totalTime = 0.0
    @Published var normalTime = 0.0
    private var abnormalTime = 0.0
    private var connectTime = 0.0
    
    private var checkingTimer: Timer?
    private var dailyResetTimer: Timer?
    
    private var lastMotionUpdateTime: Date = Date()
    private let pauseThreshold: TimeInterval = 3.0
    
    private var referenceAttitude: CMAttitude?
    
    private var filteredPitch: Double = 0
    private var filteredRoll: Double = 0
    private let alpha = 0.1
    
    private var forwardAccelerationThreshold: Double = 0.02
    private var isTurtleNeck: Bool = false

    private var abnormalPostureDuration: TimeInterval = 0.0
    private let abnormalPostureThreshold: TimeInterval = 3.0

    init() {
        setupMotionManager()
        startMonitoringPosture()
        scheduleMidnightReset()
        requestNotificationAuthorization()
    }
        
    func setupMotionManager() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
                guard let self = self, let motion = motion, error == nil else { return }
                
                self.filteredPitch = self.alpha * motion.attitude.pitch + (1 - self.alpha) * self.filteredPitch
                self.filteredRoll = self.alpha * motion.attitude.roll + (1 - self.alpha) * self.filteredRoll
                
                self.pitch = self.filteredPitch
                self.roll = self.filteredRoll
                
                self.lastMotionUpdateTime = Date()
            }
        }
    }
    
    func check() {
        print("Pitch: \(String(format: "%.2f", pitch))")
        print("Roll: \(String(format: "%.2f", roll))")
        print("Reference Pitch: \(String(format: "%.2f", referencePitch))")
        print("Reference Roll: \(String(format: "%.2f", referenceRoll))")
    }
    
    func setReferenceAttitude() {
        print("재설정")
        check()
        if let currentAttitude = motionManager.deviceMotion?.attitude {
            referenceAttitude = currentAttitude.copy() as? CMAttitude
            referencePitch = pitch
            referenceRoll = roll
            DispatchQueue.main.async {
                self.resetPostureState()
            }
        }
    }
    
    private func resetPostureState() {
        self.normalTime = 0.0
        self.abnormalTime = 0.0
        self.abnormalPostureDuration = 0.0
        self.formattedNormalTime = "00:00"
        self.formattedAbnormalTime = "00:00"
        self.posture = true  
    }
    
    func stopMonitoringPosture() {
        checkingTimer?.invalidate()
        checkingTimer = nil
    }
    
    func requestNotificationAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("알림 권한 요청 오류: \(error.localizedDescription)")
            } else if granted {
                print("알림 권한이 승인되었습니다.")
            } else {
                print("알림 권한이 거부되었습니다.")
            }
        }
    }
    
    func sendPostureNotification(for type: String) {
        let content = UNMutableNotificationContent()
        content.title = "📣 자세 교정 알림"
        if type == "turtleNeck" {
            content.body = "거북목 자세가 감지되었습니다. 올바른 자세로 교정하세요!"
        } else {
            content.body = "비정상적인 자세가 3초 이상 유지되었습니다. 올바른 자세로 교정하세요!"
        }
        content.sound = UNNotificationSound.default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("알림 전송 오류: \(error.localizedDescription)")
            }
        }
    }
}

extension DashBoardViewModel {
    func isAbnormalPosture() -> Bool {
        guard let referenceAttitude = referenceAttitude, let currentMotion = motionManager.deviceMotion else {
            return false
        }
        
        let currentAttitude = currentMotion.attitude
        let relativeAttitude = currentAttitude.copy() as! CMAttitude
        relativeAttitude.multiply(byInverseOf: referenceAttitude)
        
        let pitchDiff = abs(relativeAttitude.pitch)
        let rollDiff = abs(relativeAttitude.roll)
        let yawDiff = abs(relativeAttitude.yaw)
        
        let pitchThreshold = 0.2
        let rollThreshold = 0.2
        let yawThreshold = 0.2
        
        DispatchQueue.main.async {
            if pitchDiff > pitchThreshold || rollDiff > rollThreshold || yawDiff > yawThreshold {
                        self.posture = false
                    } else {
                        self.posture = true
                    }
        }
        
        detectTurtleNeck(using: currentMotion)
        
        return pitchDiff > pitchThreshold || rollDiff > rollThreshold || yawDiff > yawThreshold || isTurtleNeck
    }
    
    func detectTurtleNeck(using motion: CMDeviceMotion) {
        let userAcceleration = motion.userAcceleration
        let rotationMatrix = motion.attitude.rotationMatrix
        
        let forwardVectorX = rotationMatrix.m31
        let forwardVectorY = rotationMatrix.m32
        let forwardVectorZ = rotationMatrix.m33
        
        let forwardAcceleration = userAcceleration.x * forwardVectorX +
                                  userAcceleration.y * forwardVectorY +
                                  userAcceleration.z * forwardVectorZ

        filteredForwardAcceleration = alpha * forwardAcceleration + (1 - alpha) * (isTurtleNeck ? forwardAcceleration : 0)
        
        if filteredForwardAcceleration > forwardAccelerationThreshold {
            if !isTurtleNeck {
                isTurtleNeck = true
                print("거북목 상태 감지됨!")
                sendPostureNotification(for: "turtleNeck")
            }
        } else {
            isTurtleNeck = false
        }
    }
    
    func startMonitoringPosture() {
        checkingTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.totalTime += 0.5

            DispatchQueue.main.async {
                self.formattedTotalTime = TimeFormatter.formattedtime(from: self.totalTime)
            }
            
            let currentTime = Date()
            if currentTime.timeIntervalSince(self.lastMotionUpdateTime) >= self.pauseThreshold {
                self.isPaused = true
                print("Pause 상태 - 자세 변화 없음")
                self.abnormalPostureDuration = 0.0
            } else {
                DispatchQueue.main.async {
                    self.connectTime += 0.5
                    self.isPaused = false
                    self.formattedConnectTime = TimeFormatter.formattedtime(from: self.connectTime)
                    if self.isAbnormalPosture() {
                        print("비정상 자세")
                        self.abnormalTime += 0.5
                        self.formattedAbnormalTime = TimeFormatter.formattedtime(from: self.abnormalTime)
                        self.posture = false

                        if self.isTurtleNeck {
                            self.abnormalPostureDuration = 0.0
                        } else {
                            self.abnormalPostureDuration += 0.5

                            if self.abnormalPostureDuration >= self.abnormalPostureThreshold {
                                self.sendPostureNotification(for: "abnormalPosture")
                                self.abnormalPostureDuration = 0.0
                            }
                        }
                    } else {
                        print("정상 자세")
                        self.normalTime += 0.5
                        self.formattedNormalTime = TimeFormatter.formattedtime(from: self.normalTime)
                        self.posture = true

                        self.abnormalPostureDuration = 0.0
                    }
                }
            }
        }
    }
}

extension DashBoardViewModel {
    func scheduleMidnightReset() {
        let now = Date()
        let calendar = Calendar.current
        
        var midnight = calendar.nextDate(after: now, matching: DateComponents(hour: 0, minute: 0, second: 0), matchingPolicy: .nextTime)!
        
        if now >= midnight {
            midnight = calendar.date(byAdding: .day, value: 1, to: midnight)!
        }
        
        let timeInterval = midnight.timeIntervalSince(now)
        
        dailyResetTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
            self?.resetTimes()
            self?.scheduleMidnightReset()
        }
    }
    
    func resetTimes() {
        print("자정이 되어 값들이 초기화됩니다.")
        totalTime = 0.0
        normalTime = 0.0
        abnormalTime = 0.0
        abnormalPostureDuration = 0.0
    }
}
