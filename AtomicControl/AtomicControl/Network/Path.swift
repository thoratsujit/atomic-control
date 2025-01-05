//
//  Path.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 04/09/24.
//

import Foundation

enum Path: String {
    case deviceState = "/v1/get_device_state"
    case devicesList = "/v1/get_list_of_devices"
    case refreshToken = "/v1/get_access_token"
    case sendCommand = "/v1/send_command"
    case dogAPIRandom = "/api/breeds/image/random"
}

//https://dog.ceo/api/breeds/image/random

//https://api.developer.atomberg-iot.com/
//https://api.developer.atomberg-iot.com/v1/get_list_of_devices
//https://api.developer.atomberg-iot.com/v1/get_access_token
//https://api.developer.atomberg-iot.com/v1/send_command



struct Dog: Decodable {
    let message: String
    let status: String
}


//{
//    "message": "https://images.dog.ceo/breeds/hound-english/n02089973_3119.jpg",
//    "status": "success"
//}
