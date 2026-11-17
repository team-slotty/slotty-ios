//
//  Slotty_iosApp.swift
//  Slotty_ios
//
//  Created by WuHeuiJeong on 11/11/26.
//

import SwiftUI

@main
struct Slotty_iosApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView(parkingViewModel: ParkingHomeViewModel(repository: LiveParkingRepository()))
        }
    }
    
    /// 실행 인자에 -useMockData가 있으면 목 저장소, 없으면 서버 저장소 (Debug 빌드에서만)
    private static var parkingRepository: any ParkingRepository {
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-useMockData") {
            return MockParkingRepository()
        }
#endif
        return LiveParkingRepository()
    }
}
