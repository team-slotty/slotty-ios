//
//  ArrivalNotifier.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/23/26.
//

import CoreLocation
import UserNotifications

/// 빌라 도착 알림 - 기준점 반경에 들어오면 시스템이 로컬 알림을 띄운다
/// 위치 비교는 시스템(기기 안)이 해서 좌표가 서버로 가지 않는다 (위치정보법 - 기획 결정)
final class ArrivalNotifier: NSObject, CLLocationManagerDelegate {
    /// 알림 요청 이름 - 다시 예약할 때 이전 것을 지우는 데 쓴다
    static let requestIdentifier = "arrival"
    /// 도착으로 보는 반경 (m) - 앱 상수 (기획 결정: 도착 150m)
    static let radius: CLLocationDistance = 150
    
    private let locationManager = CLLocationManager()
    /// 위치 권한 대답을 기다리는 중이면 그 대답을 넘길 곳
    private var authorizationContinuation: CheckedContinuation<Void, Never>?
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    /// 알림과 위치(사용하는 동안) 권한을 받고, 둘 다 있으면 기준점 반경 도착 알림을 예약한다
    func schedule(latitude: Double, longitude: Double) async {
        let center = UNUserNotificationCenter.current()
        guard (try? await center.requestAuthorization(options: [.alert, .sound])) == true else { return }
        await requestLocationAuthorization()
        guard [.authorizedWhenInUse, .authorizedAlways].contains(locationManager.authorizationStatus) else { return }
        center.removePendingNotificationRequests(withIdentifiers: [Self.requestIdentifier])
        try? await center.add(Self.request(latitude: latitude, longitude: longitude))
    }
    
    /// 예약을 지운다 - 로그아웃할 때
    func cancel() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [Self.requestIdentifier])
    }
    
    /// 도착 알림 요청 - 반경에 들어올 때마다(나갔다 다시 들어오면 또) 알림
    static func request(latitude: Double, longitude: Double) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = "빌라에 도착했어요"
        content.body = "눌러서 입차를 기록하세요"
        content.sound = .default
        let region = CLCircularRegion(
            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            radius: radius,
            identifier: requestIdentifier
        )
        region.notifyOnEntry = true
        region.notifyOnExit = false
        let trigger = UNLocationNotificationTrigger(region: region, repeats: true)
        return UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
    }
    
    /// 아직 정하지 않았으면 위치 권한을 묻고 대답을 기다린다
    private func requestLocationAuthorization() async {
        guard locationManager.authorizationStatus == .notDetermined else { return }
        await withCheckedContinuation { continuation in
            authorizationContinuation = continuation
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            // 처음 만들 때도 한 번 불리므로, 아직 정하지 않은 상태면 기다린다
            guard self.locationManager.authorizationStatus != .notDetermined else { return }
            self.authorizationContinuation?.resume()
            self.authorizationContinuation = nil
        }
    }
}
