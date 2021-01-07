//
//  RiotController.swift
//  ValorantTracker
//
//  Created by Aritro Paul on 05/01/21.
//

import Foundation

var username = ""
var password = ""
var userChanged = false

class Riot {
    
    static let shared = Riot()
    static var accessToken = ""
    static var entitlementToken = ""
    static var session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
    static var userID = ""
    static var user : User?
    
    func authenticate(username: String, password: String, completion: @escaping(Bool, RiotError?)->()) {
        let url = URL(string: "https://auth.riotgames.com/api/v1/authorization")!
        var request = URLRequest(url: url)
        let body: [String : Any] = [
                    "client_id": "play-valorant-web-prod",
                    "nonce": "1",
                    "redirect_uri": "https://playvalorant.com/opt_in",
                    "scope": "account openid",
                    "response_type": "token id_token"
                ]
        request.httpBody = try! JSONSerialization.data(withJSONObject: body)
        request.httpMethod = "POST"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        let task = Riot.session.dataTask(with: request) { (data, response, error) in
            guard let response = response as? HTTPURLResponse else { return }
            let status = response.statusCode
            guard let data = data else { return }
            if status == 200 {
                print("✅ Status: \(status)")
                print(String(data: data, encoding: .utf8)!)
                guard let responseString = String(data: data, encoding: .utf8) else { return }
                if responseString.contains("access_token") {
                    Riot.accessToken = responseString.components(separatedBy: "access_token=")[1].components(separatedBy: "&scope")[0]
                    print(Riot.accessToken)
                    completion(true, nil)
                }
                else {
                    self.subAuth(session: Riot.session, username: username, password: password) { (status, err) in
                        completion(status, err)
                    }
                }
            }
            else {
                print("❌ Status: \(status)")
                print(String(data: data, encoding: .utf8)!)
                completion(false, .invalidRequest)
            }
        }
        task.resume()
    }
    
    func subAuth(session: URLSession, username: String, password: String, completion: @escaping(Bool, RiotError?)->()) {
        print("🔐 Authenticating")
        print(username, password)
        let url = URL(string: "https://auth.riotgames.com/api/v1/authorization")!
        var request = URLRequest(url: url)
        let body: [String : Any] = [
                    "type": "auth",
                    "username": username,
                    "password": password
                ]
        request.httpBody = try! JSONSerialization.data(withJSONObject: body)
        request.httpMethod = "PUT"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let response = response as? HTTPURLResponse else { return }
            let status = response.statusCode
            guard let data = data else { return }
            if status == 200 {
                print("✅ Status: \(status)")
                guard let responseString = String(data: data, encoding: .utf8) else { return }
                if responseString.contains("access_token") {
                    Riot.accessToken = responseString.components(separatedBy: "access_token=")[1].components(separatedBy: "&scope")[0]
                    print(Riot.accessToken)
                    completion(true, nil)
                }
                else {
                    print("❌ Auth Failed")
                    completion(false, .failedLogin)
                }
            }
            else {
                print("❌ Status: \(status)")
                print(String(data: data, encoding: .utf8)!)
                completion(false, .invalidRequest)
            }
        }
        task.resume()
    }
    
    
    func getEntitlementToken(completion: @escaping(Bool)->()) {
        print("📇 Obtaining Entitlement")
        let url = URL(string: "https://entitlements.auth.riotgames.com/api/token/v1")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        let body: [String : Any] = [
                    "": "",
                ]
        request.httpBody = try! JSONSerialization.data(withJSONObject: body)
        request.httpMethod = "POST"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(Riot.accessToken)", forHTTPHeaderField: "Authorization")
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let response = response as? HTTPURLResponse else { return }
            let status = response.statusCode
            guard let data = data else { return }
            if status == 200 {
                print("✅ Status: \(status)")
                let token = try! JSONDecoder().decode(EntitlementToken.self, from: data)
                Riot.entitlementToken = token.entitlementsToken
                print(Riot.entitlementToken)
                completion(true)
            }
            else {
                print("❌ Status: \(status)")
                print(String(data: data, encoding: .utf8)!)
                completion(false)
            }
        }
        task.resume()
    }
    
    func getUserInfo(completion: @escaping(Bool)->()) {
        print("🙋‍♂️ Obtaining User information")
        let url = URL(string: "https://auth.riotgames.com/userinfo")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(Riot.accessToken)", forHTTPHeaderField: "Authorization")
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let response = response as? HTTPURLResponse else { return }
            let status = response.statusCode
            guard let data = data else { return }
            if status == 200 {
                print("✅ Status: \(status)")
                let user = try! JSONDecoder().decode(User.self, from: data)
                print(user)
                Riot.user = user
                Riot.userID = user.sub
                completion(true)
            }
            else {
                print("❌ Status: \(status)")
                print(String(data: data, encoding: .utf8)!)
                completion(false)
            }
        }
        task.resume()
    }
    
    func getMatchQueue(server: String, completion: @escaping(Result<[Match], RiotError>)->()){
        print("⚔️ Getting Matches")
        let url = URL(string: "https://pd.\(server).a.pvp.net/mmr/v1/players/\(Riot.userID)/competitiveupdates?startIndex=0&endIndex=10")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(Riot.accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue(Riot.entitlementToken, forHTTPHeaderField: "X-Riot-Entitlements-JWT")
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let response = response as? HTTPURLResponse else { return }
            let status = response.statusCode
            guard let data = data else { return }
            if status == 200 {
                print("✅ Status: \(status)")
                let matches = try! JSONDecoder().decode(Matches.self, from: data)
                print(matches)
                completion(.success(matches.matches))
            }
            else {
                print("❌ Status: \(status)")
                print(String(data: data, encoding: .utf8)!)
                completion(.failure(.invalidRequest))
            }
        }
        task.resume()
    }
}
