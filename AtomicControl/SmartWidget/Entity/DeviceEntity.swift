//
//  DeviceEntity.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 25/09/24.
//

import AppIntents

struct DeviceEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Device")
    
    static let defaultQuery = DeviceIntentEntityQuery()
    
    var id: String
    var name: String
    var room: String
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
    
    init(id: String, name: String, room: String) {
        self.id = id
        self.name = name
        self.room = room
    }
}

struct DeviceIntentEntityQuery: EntityQuery, EntityStringQuery {
    
    func entities(for identifiers: [String]) async throws -> [DeviceEntity] {
        try await getDeviceEntities().filter { identifiers.contains($0.id) }
    }
    
    func entities(matching string: String) async throws -> IntentItemCollection<DeviceEntity> {
        // Fetch the device entities asynchronously
        let entities = try await getDeviceEntities()
        
        // Filter the entities based on whether the string matches the name
        let matchingEntities = entities.filter { entity in
            entity.name.localizedCaseInsensitiveContains(string)
        }
        
        // Wrap the filtered results in an IntentItemCollection and return
        return IntentItemCollection(items: matchingEntities)
    }
    
    func suggestedEntities() async throws -> IntentItemCollection<DeviceEntity> {
        // Fetch the device entities asynchronously
        let entities = try await getDeviceEntities()
        
        // For now, we're just suggesting all available entities
        return IntentItemCollection(items: entities)
    }
    
    private func getDeviceEntities() async throws -> [DeviceEntity] {
        // MARK: Load from API - not working
        WidgetVM.shared.fetchData()
        
        // MARK: Load from user defaults
        let devices = WidgetVM.shared.devices
        
        var entities: [DeviceEntity] = []
        
        for device in devices {
            entities.append(.init(id: device.deviceID, name: device.name, room: device.room))
        }
        
        return entities
    }
}
