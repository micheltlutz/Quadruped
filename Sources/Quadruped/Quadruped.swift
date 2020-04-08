#if os(Linux)

import Glibc

#elseif os(macOS)

import Darwin

#endif

import SwiftyGPIO
import Foundation

final class Quadruped {
    private let busNumber: Int = 1
    private var module: PCA9685Module

    init() {
        guard let smbusUnwraped = try? SMBus(busNumber: 1),
              let moduleUnwraped = try? PCA9685Module(smBus: smbusUnwraped, address: 0x40) else {
            fatalError("It has not been possible to open the System Managed/I2C bus")
        }

        self.module = moduleUnwraped

        self.setupFrequency()
    }

    private func setupFrequency() {
        do {
            let _ = try module.set(pwmFrequency: 600)
        } catch let error {
            print("ERRO: \(error.localizedDescription))")
        }
    }

    public func wakeup() {
        do {
            let _ = try module.resetAllChannels()

            print("Wakeup")
        } catch let error {
            print("ERRO: \(error.localizedDescription))")
        }
    }

    public func moveLeg() {
        let leg1 = Leg(module: module)

        leg1.move()
    }
}

class Leg {
    private let module: PCA9685Module
    private let s0 = PCA9685Module.Channel.channelNo0
    private let s1 = PCA9685Module.Channel.channelNo1
    private let s2 = PCA9685Module.Channel.channelNo2

    init(module: PCA9685Module) {
        self.module = module
    }

    public func move() {
        print("MoveLeg 1")

        let exampleDuration: TimeInterval = 5.0
        let cycleDuration: TimeInterval = 0.01
        let numberExampleCycles = exampleDuration / cycleDuration

        for index in 0 ... Int(numberExampleCycles) {

            let dutyCycle = 1.0 / numberExampleCycles * Double(index)
            guard let _ = try? module.write(channel: s0, dutyCycle: dutyCycle)
                , let _ = try? module.write(channel: s2, dutyCycle: dutyCycle)
//                let _ = try? module.write(channel: s2, dutyCycle: dutyCycle)
                else {
                    fatalError("Failed to set the values for the given channels")
            }
            print("dutyCycle: \(UInt32(dutyCycle))")
            sleep(UInt32(cycleDuration))
            let _ = try? module.resetAllChannels()
        }




//        guard let _ = try? module.write(channel: s2, dutyCycle: dutyCycle) else {
//                fatalError("Failed to set the values for the given channels")
//        }
    }
}
