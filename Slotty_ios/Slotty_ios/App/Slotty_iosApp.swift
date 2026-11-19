//
//  Slotty_iosApp.swift
//  Slotty_ios
//
//  Created by WuHeuiJeong on 11/11/26.
//

import SwiftUI

@main
struct Slotty_iosApp: App {
    /// 앱이 켜져 있는 동안 계속 쓰는 ViewModel - 화면이 바뀌어도 새로 만들지 않는다
    @State private var parkingViewModel = ParkingHomeViewModel(repository: Self.parkingRepository)
    @State private var visitViewModel = VisitListViewModel(repository: Self.visitRepository)
    /// 스플래시를 보여 주는 중인지
    @State private var isLaunching = true
    
    var body: some Scene {
        WindowGroup {
            if isLaunching {
                SplashView()
                    .task {
                        // 자동 로그인이 생기기 전까지는 1초만 보여 준다
                        try? await Task.sleep(for: .seconds(1))
                        isLaunching = false
                    }
            } else {
                MainTabView(
                    parkingViewModel: parkingViewModel,
                    searchRepository: Self.vehicleSearchRepository,
                    visitViewModel: visitViewModel
                )
            }
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
    /// 서버에 검색 API가 생기기 전까지는 항상 목 저장소
    private static var vehicleSearchRepository: any VehicleSearchRepository {
        MockVehicleSearchRepository()
    }
    /// 서버에 방문 API가 생기기 전까지는 항상 목 저장소
    private static var visitRepository: any VisitRepository {
        MockVisitRepository()
    }
}
