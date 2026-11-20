# Slotty iOS

공동주택 세대원이 주차 현황을 확인하고, 입출차와 방문차량을 기록하는 iOS 앱입니다.

현대오토에버 모빌리티스쿨 3차 프로젝트 (2026.11.11 ~ 11.24)

## 주요 기능

| 기능 | 설명 |
|---|---|
| 주차 현황 | 주차면 현황판, 면별 상태와 상세 보기 |
| 입출차 | 내 차량과 주차면을 골라 입차 기록, 출차 확인 |
| 차량 검색 | 차량번호로 주차 차량 찾기 |
| 방문차량 | 방문 등록, 예정/방문 중/지난 방문 보기, 방문 종료와 삭제, 홈 "오늘 방문 예정" 카드 |
| 시작 | 스플래시, 로그인, 회원가입 |

## 개발 환경

- Xcode 26.6
- iOS 26.5 이상
- Swift 5, SwiftUI
- 테스트: Swift Testing

## 실행 방법

1. `Slotty_ios/Slotty_ios.xcodeproj`를 Xcode로 엽니다.
2. `Slotty` 스킴을 선택하고 시뮬레이터에서 실행합니다.

### 서버 주소

서버 주소는 `Slotty_ios/Config`의 xcconfig 파일에서 `API_BASE_URL`로 정합니다.

| 빌드 | 파일 | 기본값 |
|---|---|---|
| Debug | `Debug.xcconfig` | `http://localhost:8080` |
| Release | `Release.xcconfig` | 배포 서버 주소 (미정) |

시뮬레이터는 `localhost:8080`으로 로컬 서버에 바로 접속합니다.

### 서버 없이 실행하기 (목 데이터)

Debug 빌드에서 실행 인자에 `-useMockData`를 넣으면 서버 대신 목 데이터로 화면을 볼 수 있습니다.

`Product > Scheme > Edit Scheme... > Run > Arguments > Arguments Passed On Launch`에 `-useMockData` 추가

> 개인 스킴 설정이라 커밋하지 않습니다.

### 테스트

`Cmd + U` 또는

```bash
xcodebuild test -scheme Slotty -destination 'platform=iOS Simulator,name=iPhone 17'
```

## 아키텍처

**MVVM + 저장소(Repository) 프로토콜**

```
View  ──>  ViewModel (@Observable)  ──>  Repository (protocol)
                                           ├─ Mock 저장소 (목 데이터)
                                           └─ Live 저장소 (APIClient로 서버 통신)
```

- 화면은 ViewModel의 상태만 보고 그립니다.
- ViewModel은 저장소 프로토콜에만 의존하므로, 서버 API가 준비되기 전에는 목 저장소로 먼저 화면과 동작을 만들고 나중에 서버 저장소로 바꿉니다.
- 어떤 저장소를 쓸지는 `App/Slotty_iosApp.swift` 한 곳에서 정합니다.
- 상태 판단(방문 상태, 삭제/종료 가능 여부 등)은 모델에서 시각을 받아 계산하고, 단위 테스트로 검증합니다.

## 폴더 구조

```
Slotty_ios/
├── Config/                 # Debug/Release xcconfig (API_BASE_URL)
├── Slotty_ios/
│   ├── App/                # 앱 시작점, 저장소 선택
│   ├── Core/
│   │   ├── DesignSystem/   # 색상, 폰트, 버튼, 입력칸, 로고
│   │   ├── Model/          # 주차면, 차량, 방문 등 공통 모델
│   │   └── Network/        # APIClient, 서버 설정, 에러, DTO
│   ├── Features/           # 기능별 폴더 (View, ViewModel, 저장소)
│   │   ├── Start/          # 스플래시, 로그인, 회원가입
│   │   ├── Parking/        # 주차 현황, 입출차
│   │   ├── VehicleSearch/  # 차량 검색
│   │   ├── Visitor/        # 방문차량
│   │   └── My/             # 마이
│   └── Resources/          # 에셋, Noto Sans KR 폰트
└── SlottyTests/            # 단위 테스트
```

## 협업 규칙

### 브랜치

| 브랜치 | 용도 |
|---|---|
| `main` | 기본 브랜치 |
| `feat/기능` | 새 기능 |
| `fix/내용` | 버그 수정 |
| `docs/내용` | 문서 |

이슈 하나에 브랜치 하나, 커밋은 1~3개로 작게 나누고 PR은 Squash merge 합니다.

### 커밋 메시지

```
유형: 설명 (#이슈번호)
```

| 유형 | 의미 |
|---|---|
| feat | 새 기능 |
| fix | 버그 수정 |
| refactor | 동작 변화 없는 코드 정리 |
| docs | 문서 |
| test | 테스트 |
| chore | 설정, 빌드 |

예: `feat: 방문 상세와 방문 종료 (#33)`

### 비밀값

서버 비밀키, 토큰, 테스트 계정 비밀번호는 코드와 README에 넣지 않습니다.
