//
//  String+Extension.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 04/09/24.
//

import Foundation

extension String {
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: self)
    }
    
    var hexToASCII: String? {
        // Convert the hex string to Data
        var data = Data()
        var hex = self
        if hex.count % 2 != 0 {
            hex = "0" + hex // pad with zero if necessary
        }
        
        while hex.count > 0 {
            let c = String(hex.prefix(2))
            hex = String(hex.dropFirst(2))
            if let byte = UInt8(c, radix: 16) {
                data.append(byte)
            } else {
                return nil // Return nil if the conversion fails
            }
        }
        
        // Convert Data to String
        return String(data: data, encoding: .utf8)
    }
    
    func decode<T: Codable>(to type: T.Type) -> T? {
        guard let jsonData = self.data(using: .utf8) else {
            return nil
        }
        let decoder = JSONDecoder()
        do {
            let decodedObject = try decoder.decode(T.self, from: jsonData)
            return decodedObject
        } catch {
            print("Failed to decode JSON: \(error.localizedDescription)")
            return nil
        }
    }
}
