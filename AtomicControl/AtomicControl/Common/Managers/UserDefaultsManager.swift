//
//  UserDefaultsManager.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 19/09/24.
//

import Foundation

class UserDefaultsManager {
    
    static let shared = UserDefaultsManager()
    
    private init() {}
    
    private let appGroupName = "group.983VYQQND2.com.fabex3d.atomichome"
    
    private var userDefaults: UserDefaults {
        return UserDefaults(suiteName: appGroupName) ?? UserDefaults.standard
    }
    
    // Save Codable object to UserDefaults
    func save<T: Codable>(object: T, key: AtomicKeys) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            userDefaults.set(data, forKey: key.value)
            userDefaults.synchronize()
        } catch {
            print("Failed to save object: \(error)")
        }
    }
    
    // Retrieve Codable object from UserDefaults
    func retrieve<T: Codable>(key: AtomicKeys, as type: T.Type) -> T? {
        if let data = userDefaults.data(forKey: key.value) {
            let decoder = JSONDecoder()
            do {
                let object = try decoder.decode(type, from: data)
                return object
            } catch {
                print("Failed to decode object: \(error)")
            }
        }
        return nil
    }
    
    // Remove object from UserDefaults
    func remove(key: AtomicKeys) {
        userDefaults.removeObject(forKey: key.value)
        userDefaults.synchronize()
    }
}

