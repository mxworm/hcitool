//
//  ReadRemoteExtendedFeatures.swift
//  hcitool
//
//  Created by Carlos Duclos on 8/8/18.
//
//

import Bluetooth
import Foundation

public struct ReadRemoteExtendedFeaturesCommand: ArgumentableCommand {
    
    public typealias PacketType = HCICreateConnection.PacketType
    public typealias ClockOffset = HCICreateConnection.ClockOffset
    public typealias AllowRoleSwitch = HCICreateConnection.AllowRoleSwitch
    
    // MARK: - Properties
    
    public static let commandType: CommandType = .readRemoteSupportedFeatures
    
    public let address: Address
    
    public let packetType: UInt16
    
    public let pageScanRepetitionMode: PageScanRepetitionMode
    
    public let clockOffset: BitMaskOptionSet<ClockOffset>
    
    public let allowRoleSwitch: AllowRoleSwitch
    
    public var pageNumber: UInt8
    
    // MARK: - Initialization
    
    public init(address: Address,
                packetType: UInt16,
                pageScanRepetitionMode: PageScanRepetitionMode,
                clockOffset: BitMaskOptionSet<ClockOffset>,
                allowRoleSwitch: AllowRoleSwitch,
                pageNumber: UInt8) {
        
        self.address = address
        self.packetType = packetType
        self.pageScanRepetitionMode = pageScanRepetitionMode
        self.clockOffset = clockOffset
        self.allowRoleSwitch = allowRoleSwitch
        self.pageNumber = pageNumber
    }
    
    public init(parameters: [Parameter<Option>]) throws {
        
        guard let addressString = parameters.first(where: { $0.option == .address })?.value
            else { throw CommandError.optionMissingValue(Option.address.rawValue) }
        
        guard let address = Address(rawValue: addressString)
            else { throw CommandError.invalidOptionValue(option: Option.address.rawValue, value: addressString) }
        
        self.address = address
        
        guard let packetTypeString = parameters.first(where: { $0.option == .packetType })?.value
            else { throw CommandError.optionMissingValue(Option.packetType.rawValue) }
        
        guard let packetTypeValue = UInt16(commandLine: packetTypeString)
            else { throw CommandError.invalidOptionValue(option: Option.packetType.rawValue, value: packetTypeString) }
        
        self.packetType = packetTypeValue
        
        guard let pageScanRepetitionModeString = parameters.first(where: { $0.option == .pageScanRepetitionMode })?.value
            else { throw CommandError.optionMissingValue(Option.pageScanRepetitionMode.rawValue) }
        
        guard let pageScanRepetitionModeValue = UInt8(commandLine: pageScanRepetitionModeString)
            else { throw CommandError.invalidOptionValue(option: Option.pageScanRepetitionMode.rawValue, value: pageScanRepetitionModeString) }
        
        self.pageScanRepetitionMode = PageScanRepetitionMode(rawValue: pageScanRepetitionModeValue)
        
        guard let clockOffsetString = parameters.first(where: { $0.option == .clockOffset })?.value
            else { throw CommandError.optionMissingValue(Option.clockOffset.rawValue) }
        
        guard let clockOffsetValue = UInt16(commandLine: clockOffsetString)
            else { throw CommandError.invalidOptionValue(option: Option.clockOffset.rawValue, value: clockOffsetString) }
        
        self.clockOffset = BitMaskOptionSet<ClockOffset>(rawValue: clockOffsetValue)
        
        guard let allowRoleSwitchString = parameters.first(where: { $0.option == .allowRoleSwitch })?.value
            else { throw CommandError.optionMissingValue(Option.allowRoleSwitch.rawValue) }
        
        guard let allowRoleSwitchValue = UInt8(commandLine: allowRoleSwitchString),
            let allowRoleSwitch = AllowRoleSwitch(rawValue: allowRoleSwitchValue)
            else { throw CommandError.invalidOptionValue(option: Option.allowRoleSwitch.rawValue, value: allowRoleSwitchString) }
        
        self.allowRoleSwitch = allowRoleSwitch
        
        guard let pageNumberString = parameters.first(where: { $0.option == .pageNumber })?.value
            else { throw CommandError.optionMissingValue(Option.pageNumber.rawValue) }
        
        guard let pageNumber = UInt8(commandLine: pageNumberString)
            else { throw CommandError.invalidOptionValue(option: Option.pageNumber.rawValue, value: pageNumberString) }
        
        self.pageNumber = pageNumber
    }
    
    // MARK: - Methods
    
    public func execute <Controller: BluetoothHostControllerInterface> (controller: Controller) throws {
        
        let connectionComplete = try controller.createConnection(address: address,
                                                                 packetType: packetType,
                                                                 pageScanRepetitionMode: pageScanRepetitionMode,
                                                                 clockOffset: clockOffset,
                                                                 allowRoleSwitch: allowRoleSwitch,
                                                                 timeout: 5000)
        
        print("Connection handle =", connectionComplete.handle.toHexadecimal())
        
        switch connectionComplete.status {
        case .success:
            let features = try controller.readRemoteExtendedFeatures(handle: connectionComplete.handle,
                                                                     pageNumber: pageNumber)
            
            print("LMP Features: \n")
            
            features.forEach { print($0.name) }
            
        case .error(let error):
            print("Connection Error:", error.name)
        }
    }
}

public extension ReadRemoteExtendedFeaturesCommand {
    
    public enum Option: String, OptionProtocol {
        
        case address = "address"
        case packetType = "packettype"
        case pageScanRepetitionMode = "pagescanrepetitionmode"
        case clockOffset = "clockoffset"
        case allowRoleSwitch = "allowroleswitch"
        case pageNumber = "pagenumber"
        
        public static let all: Set<Option> = [.address,
                                              .packetType,
                                              .pageScanRepetitionMode,
                                              .clockOffset,
                                              .allowRoleSwitch,
                                              .pageNumber]
    }
}