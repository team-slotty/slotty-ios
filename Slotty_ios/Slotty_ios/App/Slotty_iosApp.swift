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
    /// 로그인했는지 - 스플래시에서 저장된 로그인이 있으면 true로 시작
    @State private var isLoggedIn = false
    /// 세대에 소속됐는지 - 로그인할 때마다 내 정보로 다시 확인, 확인 전이면 nil
    @State private var hasHousehold: Bool?
    
    var body: some Scene {
        WindowGroup {
            if isLaunching {
                SplashView()
                    .task {
                        // 스플래시를 1초 보여 준 뒤, 저장된 로그인이 있으면 로그인 화면을 건너뛴다
                        try? await Task.sleep(for: .seconds(1))
                        isLoggedIn = Self.authRepository.hasSavedLogin
                        isLaunching = false
                    }
            } else if !isLoggedIn {
                NavigationStack {
                    LoginView(viewModel: LoginViewModel(repository: Self.authRepository)) {
                        hasHousehold = nil
                        isLoggedIn = true
                    }
                }
            } else {
                loggedInContent
                // 토큰이 없거나 만료되면, 또는 로그아웃하면 로그인 화면으로
                    .onReceive(NotificationCenter.default.publisher(for: .sessionExpired)) { _ in
                        isLoggedIn = false
                    }
            }
        }
    }
    
    /// 로그인 뒤 - 세대 소속을 확인하고, 소속 전이면 시작 방법 선택, 소속이면 메인 탭
    @ViewBuilder
    private var loggedInContent: some View {
        switch hasHousehold {
        case nil:
            ProgressView()
                .task { await checkHousehold() }
        case false?:
            NavigationStack {
                StartChoiceView(householdRepository: Self.householdRepository) {
                    hasHousehold = true
                }
            }
        case true?:
            MainTabView(
                parkingViewModel: parkingViewModel,
                searchRepository: Self.vehicleSearchRepository,
                visitViewModel: visitViewModel,
                vehicleRepository: Self.vehicleRepository,
                authRepository: Self.authRepository,
                accountRepository: Self.accountRepository,
                historyRepository: Self.historyRepository,
                availabilityRepository: Self.availabilityRepository,
                adminRepository: Self.adminRepository,
                villaRepository: Self.villaRepository
            )
        }
    }
    
    /// 내 정보로 세대 소속 확인 - 확인에 실패하면 메인 탭으로 보내고, 홈의 오류 안내와 새로고침에 맡긴다
    private func checkHousehold() async {
        do {
            hasHousehold = try await Self.householdRepository.fetchMyUnit() != nil
        } catch {
            hasHousehold = true
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
    /// 실행 인자에 -useMockData가 있으면 목 저장소, 없으면 서버 저장소 (Debug 빌드에서만)
    private static var householdRepository: any HouseholdRepository {
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-useMockData") {
            return MockHouseholdRepository()
        }
#endif
        return LiveHouseholdRepository()
    }
    /// 실행 인자에 -useMockData가 있으면 목 저장소, 없으면 서버 저장소 (Debug 빌드에서만)
    private static var vehicleRepository: any VehicleRepository {
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-useMockData") {
            return MockVehicleRepository()
        }
#endif
        return LiveVehicleRepository()
    }
    /// 실행 인자에 -useMockData가 있으면 목 저장소, 없으면 서버 저장소 (Debug 빌드에서만)
    private static var vehicleSearchRepository: any VehicleSearchRepository {
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-useMockData") {
            return MockVehicleSearchRepository()
        }
#endif
        return LiveVehicleSearchRepository()
    }
    /// 실행 인자에 -useMockData가 있으면 목 저장소, 없으면 서버 저장소 (Debug 빌드에서만)
    private static var authRepository: any AuthRepository {
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-useMockData") {
            return MockAuthRepository()
        }
#endif
        return LiveAuthRepository()
    }
    /// 실행 인자에 -useMockData가 있으면 목 저장소, 없으면 서버 저장소 (Debug 빌드에서만)
    private static var visitRepository: any VisitRepository {
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-useMockData") {
            return MockVisitRepository()
        }
#endif
        return LiveVisitRepository()
    }
    
    /// 실행 인자에 -useMockData가 있으면 목 저장소, 없으면 서버 저장소 (Debug 빌드에서만)
    private static var accountRepository: any AccountRepository {
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-useMockData") {
            return MockAccountRepository()
        }
#endif
        return LiveAccountRepository()
    }
    /// 실행 인자에 -useMockData가 있으면 목 저장소, 없으면 서버 저장소 (Debug 빌드에서만)
    private static var historyRepository: any HistoryRepository {
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-useMockData") {
            return MockHistoryRepository()
        }
#endif
        return LiveHistoryRepository()
    }
    /// 실행 인자에 -useMockData가 있으면 목 저장소, 없으면 서버 저장소 (Debug 빌드에서만)
    private static var adminRepository: any AdminRepository {
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-useMockData") {
            return MockAdminRepository()
        }
#endif
        return LiveAdminRepository()
    }
    
    /// 실행 인자에 -useMockData가 있으면 목 저장소, 없으면 서버 저장소 (Debug 빌드에서만)
    private static var villaRepository: any VillaRepository {
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-useMockData") {
            return MockVillaRepository()
        }
#endif
        return LiveVillaRepository()
    }
    
    /// 실행 인자에 -useMockData가 있으면 목 저장소, 없으면 서버 저장소 (Debug 빌드에서만)
    private static var availabilityRepository: any AvailabilityRepository {
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-useMockData") {
            return MockAvailabilityRepository()
        }
#endif
        return LiveAvailabilityRepository()
    }
}
