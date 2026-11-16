//
//  APIClient.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/16/26.
//

import Foundation

/// 서버와 JSON으로 주고받는 공통 클라이언트
struct APIClient {
    private let baseURL: URL
    private let session: URLSession
    private let decoder = JSONDecoder()
    
    init(baseURL: URL = APIConfig.baseURL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
        decoder.dateDecodingStrategy = .custom(Self.decodeServerDate)
    }
    
    /// GET 요청을 보내고 응답 JSON을 원하는 타입으로 변환
    func get<Response: Decodable>(_ path: String) async throws -> Response {
        let url = baseURL.appending(path: path)
        let (data, response) = try await session.data(from: url)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard (200..<300).contains(statusCode) else {
            throw APIError.badStatus(statusCode)
        }
        return try decoder.decode(Response.self, from: data)
    }
    
    /// 서버 날짜 해석
    nonisolated private static func decodeServerDate(_ decoder: Decoder) throws -> Date {
        let container = try decoder.singleValueContainer()
        let text = try container.decode(String.self)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        // 소수점 아래 초 (.123456)가 붙어 와도 앞 글자(초까지)만 사용
        guard let date = formatter.date(from: String(text.prefix(19))) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "날짜 형식이 아니에요 : \(text)")
        }
        return date
    }
}
