//
//  PodInfoTests.swift
//  OmniKitTests
//
//  Created by Eelke Jager on 18/09/2018.
//  Copyright © 2018 Pete Schwamb. All rights reserved.
//

import Foundation

import XCTest
@testable import OmniKit

class PodInfoTests: XCTestCase {
    func testPodInfoConfiguredAlertsNoAlerts() {
        // 02 13 first 2 bytes are omitted: 01 0000 0000 0000 0000 0000 0000 0000 0000 0000
        do {
            // Decode
            let decoded = try PodInfoConfiguredAlerts(encodedData: Data(hexadecimalString: "01000000000000000000000000000000000000")!)
            XCTAssertEqual(.configuredAlerts, decoded.podInfoType)
        } catch (let error) {
            XCTFail("message decoding threw error: \(error)")
        }
    }
    
    func testPodInfoConfiguredAlertsSuspendStillActive() {
        // 02 13 // 01 0000 0000 0000 0000 0000 0000 0bd7 0c40 0000 // real alert value after 2 hour suspend
        // 02 13 // 01 0000 0102 0304 0506 0708 090a 0bd7 0c40 0000 // used as a tester to find each alarm
        // AlarmTyoe     1    2    3    4    5    6    7    8
        // alertActivation nr  0    1    2    3    4    5    6    7
        do {
            // Decode
            let decoded = try PodInfoConfiguredAlerts(encodedData: Data(hexadecimalString: "010000000000000000000000000bd70c400000828c")!)
            XCTAssertEqual(.configuredAlerts, decoded.podInfoType)
            XCTAssertEqual(.beepBeepBeep, decoded.alertsActivations[5].beepType)
            XCTAssertEqual(11, decoded.alertsActivations[5].timeFromPodStart) // in minutes
            XCTAssertEqual(10.75, decoded.alertsActivations[5].unitsLeft) //, accuracy: 1)
            XCTAssertEqual(.beeeeeep, decoded.alertsActivations[6].beepType)
            XCTAssertEqual(12, decoded.alertsActivations[6].timeFromPodStart) // in minutes
            XCTAssertEqual(3.2, decoded.alertsActivations[6].unitsLeft) //, accuracy: 1)
        } catch (let error) {
            XCTFail("message decoding threw error: \(error)")
        }
    }
    
    func testPodInfoConfiguredAlertsReplacePodAfter3DaysAnd8Hours() {
        // 02 13 (omitted)// 01 0000 0000 0000 0000 0000 0000 0000 0000 1160
        do {
            let decoded = try PodInfoConfiguredAlerts(encodedData: Data(hexadecimalString: "010000000000000000000000000000000010e10208")!)
            XCTAssertEqual(.configuredAlerts, decoded.podInfoType)
            XCTAssertEqual(.bipBipBipbipBipBip, decoded.alertsActivations[7].beepType)
            XCTAssertEqual(16, decoded.alertsActivations[7].timeFromPodStart) // in 2 hours steps
            XCTAssertEqual(11.25, decoded.alertsActivations[7].unitsLeft, accuracy: 1)
        } catch (let error) {
            XCTFail("message decoding threw error: \(error)")
        }
    }
    
    func testPodInfoConfiguredAlertsReplacePodAfterReservoirEmpty() {
        // 02 13 (omitted)// 01 0000 0000 0000 1285 0000 11c7 0000 0000 119c 82b8
        do {
            let decoded = try PodInfoConfiguredAlerts(encodedData: Data(hexadecimalString: "010000000000001285000011c700000000119c82b8")!)
            XCTAssertEqual(.configuredAlerts, decoded.podInfoType)
            XCTAssertEqual(.bipBeepBipBeepBipBeepBipBeep, decoded.alertsActivations[2].beepType)
            XCTAssertEqual(18, decoded.alertsActivations[2].timeFromPodStart) // in 2 hours steps
            XCTAssertEqual(6.6, decoded.alertsActivations[2].unitsLeft, accuracy: 1)
            XCTAssertEqual(.beep, decoded.alertsActivations[4].beepType)
            XCTAssertEqual(17, decoded.alertsActivations[4].timeFromPodStart) // in 2 hours steps
            XCTAssertEqual(9.95, decoded.alertsActivations[4].unitsLeft, accuracy: 2)
            XCTAssertEqual(.bipBipBipbipBipBip, decoded.alertsActivations[7].beepType)
            XCTAssertEqual(17, decoded.alertsActivations[7].timeFromPodStart) // in 2 hours steps
            XCTAssertEqual(7.8, decoded.alertsActivations[7].unitsLeft, accuracy: 1)
        } catch (let error) {
            XCTFail("message decoding threw error: \(error)")
        }
    }
    
    func testPodInfoConfiguredAlertsReplacePod() {
        // 02 13 (omitted) // 01 0000 0000 0000 1284 0000 0000 0000 0000 10e0 0191
        do {
            let decoded = try PodInfoConfiguredAlerts(encodedData: Data(hexadecimalString: "010000000000001284000000000000000010e00191")!)
            XCTAssertEqual(.configuredAlerts, decoded.podInfoType)
            XCTAssertEqual(.bipBeepBipBeepBipBeepBipBeep, decoded.alertsActivations[2].beepType)
            XCTAssertEqual(18, decoded.alertsActivations[2].timeFromPodStart) // in 2 hours steps
            XCTAssertEqual(6.6, decoded.alertsActivations[2].unitsLeft, accuracy: 1)
            XCTAssertEqual(.bipBipBipbipBipBip, decoded.alertsActivations[7].beepType)
            XCTAssertEqual(16, decoded.alertsActivations[7].timeFromPodStart) // in 2 hours steps
            XCTAssertEqual(11.2, decoded.alertsActivations[7].unitsLeft, accuracy: 1)
        } catch (let error) {
            XCTFail("message decoding threw error: \(error)")
        }
    }
    
    func testPodInfoNoFaultAlerts() {
        // 02 16 (omitted) // 02 08 01 0000 0a 0038 00 0000 03ff 0087 00 00 00 95 ff 0000
        
        do {
            // Decode
            let decoded = try PodInfoFaultEvent(encodedData: Data(hexadecimalString: "02080100000a003800000003ff008700000095ff0000")!)
            XCTAssertEqual(.faultEvents, decoded.podInfoType)
            XCTAssertEqual(.aboveFiftyUnits, decoded.reservoirStatus)
            XCTAssertEqual(.basal, decoded.deliveryInProgressType)
            XCTAssertEqual(0000, decoded.insulinNotDelivered)
            XCTAssertEqual(0x0a, decoded.podMessageCounter)
            XCTAssertEqual(.noFaults, decoded.originalLoggedFaultEvent)
            XCTAssertEqual(0000, decoded.faultEventTimeSinceActivation)
            XCTAssertEqual(51.15, decoded.insulinRemaining, accuracy: 0.05)
            XCTAssertEqual(135*60, decoded.timeActive, accuracy: 0) // timeActive converts minutes to seconds
            XCTAssertEqual(.noFaults, decoded.secondaryLoggedFaultEvent)
            XCTAssertEqual(false, decoded.logEventError)
            XCTAssertEqual(.insulinStateCorruptionDuringErrorLogging, decoded.infoLoggedFaultEvent)
            XCTAssertEqual(.initialized, decoded.reservoirStatusAtFirstLoggedFaultEvent)
            XCTAssertEqual(9, decoded.recieverLowGain)
            XCTAssertEqual(5, decoded.radioRSSI)
            XCTAssertEqual(.inactive, decoded.reservoirStatusAtFirstLoggedFaultEventCheck)
        } catch (let error) {
            XCTFail("message decoding threw error: \(error)")
        }
        
    }
    
    func testPodInfoFaultAlert() {
        // 02 16 02 0d 00 0000 06 0034 5c 0001 03ff 0001 00 00 05 a1 05 0186
        do {
            // Decode
            let decoded = try PodInfoFaultEvent(encodedData: Data(hexadecimalString: "020d0000000600345c000103ff0001000005a1050186")!)
            XCTAssertEqual(.faultEvents, decoded.podInfoType)
            XCTAssertEqual(.errorEventLoggedShuttingDown, decoded.reservoirStatus)
            XCTAssertEqual(.none, decoded.deliveryInProgressType)
            XCTAssertEqual(0000, decoded.insulinNotDelivered)
            XCTAssertEqual(6, decoded.podMessageCounter)
            XCTAssertEqual(.deliveryErrorDuringPriming, decoded.originalLoggedFaultEvent)
            XCTAssertEqual(0001*60, decoded.faultEventTimeSinceActivation)
            XCTAssertEqual(51.15, decoded.insulinRemaining, accuracy: 0.05)
            XCTAssertEqual(0001*60, decoded.timeActive, accuracy: 0) // timeActive converts minutes to seconds
            XCTAssertEqual(.noFaults, decoded.secondaryLoggedFaultEvent)
            XCTAssertEqual(false, decoded.logEventError)
            XCTAssertEqual(.insulinStateCorruptionDuringErrorLogging, decoded.infoLoggedFaultEvent)
            XCTAssertEqual(.readyForInjection, decoded.reservoirStatusAtFirstLoggedFaultEvent)
            XCTAssertEqual(10, decoded.recieverLowGain)
            XCTAssertEqual(1, decoded.radioRSSI)
            XCTAssertEqual(.readyForInjection, decoded.reservoirStatusAtFirstLoggedFaultEventCheck)
        } catch (let error) {
            XCTFail("message decoding threw error: \(error)")
        }
    }
    
    func testPodInfoDeliveryErrorDuringPriming() {
        //0216 BODY:020f0000000900345c000103ff0001000005ae05602903
        do {
            // Decode
            let decoded = try PodInfoFaultEvent(encodedData: Data(hexadecimalString: "020f0000000900345c000103ff0001000005ae05602903")!)
            XCTAssertEqual(.faultEvents, decoded.podInfoType)
            XCTAssertEqual(.inactive, decoded.reservoirStatus)
            XCTAssertEqual(.none, decoded.deliveryInProgressType)
            XCTAssertEqual(0000, decoded.insulinNotDelivered)
            XCTAssertEqual(9, decoded.podMessageCounter)
            XCTAssertEqual(.deliveryErrorDuringPriming, decoded.originalLoggedFaultEvent)
            XCTAssertEqual(0001*60, decoded.faultEventTimeSinceActivation)
            XCTAssertEqual(51.15, decoded.insulinRemaining, accuracy: 0.05)
            XCTAssertEqual(0001*60, decoded.timeActive, accuracy: 0) // timeActive converts minutes to seconds
            XCTAssertEqual(.noFaults, decoded.secondaryLoggedFaultEvent)
            XCTAssertEqual(false, decoded.logEventError)
            XCTAssertEqual(.insulinStateCorruptionDuringErrorLogging, decoded.infoLoggedFaultEvent)
            XCTAssertEqual(.readyForInjection, decoded.reservoirStatusAtFirstLoggedFaultEvent)
            XCTAssertEqual(10, decoded.recieverLowGain)
            XCTAssertEqual(14, decoded.radioRSSI)
            XCTAssertEqual(.readyForInjection, decoded.reservoirStatusAtFirstLoggedFaultEventCheck)
        } catch (let error) {
            XCTFail("message decoding threw error: \(error)")
        }
    }
    func testPodInfoDuringPriming() {
        // Needle cap accidentally removed before priming started leaking and gave error:
        // 0216020d0000000600008f000003ff0000000003a20386a002
        do {
            // Decode
            let decoded = try PodInfoFaultEvent(encodedData: Data(hexadecimalString: "020d0000000600008f000003ff0000000003a20386a002")!)
            XCTAssertEqual(.faultEvents, decoded.podInfoType)
            XCTAssertEqual(.errorEventLoggedShuttingDown, decoded.reservoirStatus)
            XCTAssertEqual(.none, decoded.deliveryInProgressType)
            XCTAssertEqual(0000, decoded.insulinNotDelivered)
            XCTAssertEqual(6, decoded.podMessageCounter)
            XCTAssertEqual(.faultEventSetupPodType8F, decoded.originalLoggedFaultEvent)
            XCTAssertEqual(0000*60, decoded.faultEventTimeSinceActivation)
            XCTAssertEqual(51.15, decoded.insulinRemaining, accuracy: 0.05)
            XCTAssertEqual(0000*60, decoded.timeActive, accuracy: 0) // timeActive converts minutes to seconds
            XCTAssertEqual(.noFaults, decoded.secondaryLoggedFaultEvent)
            XCTAssertEqual(false, decoded.logEventError)
            XCTAssertEqual(.insulinStateCorruptionDuringErrorLogging, decoded.infoLoggedFaultEvent)
            XCTAssertEqual(.pairingSuccess, decoded.reservoirStatusAtFirstLoggedFaultEvent)
            XCTAssertEqual(10, decoded.recieverLowGain)
            XCTAssertEqual(2, decoded.radioRSSI)
            XCTAssertEqual(.pairingSuccess, decoded.reservoirStatusAtFirstLoggedFaultEventCheck)
        } catch (let error) {
            XCTFail("message decoding threw error: \(error)")
        }
    }

    func testPodInfoDataLog() {
        // 027c // 030100010001043c
        do {
            let decoded = try PodInfoDataLog(encodedData: Data(hexadecimalString: "030100010001043c")!)
            XCTAssertEqual(.dataLog, decoded.podInfoType)
            XCTAssertEqual(.failedFlashErase, decoded.faultEventType)
            XCTAssertEqual(0001*60, decoded.timeFaultEvent)
            XCTAssertEqual(0001*60, decoded.timeActivation)
            XCTAssertEqual(04, decoded.dataChunkSize)
            XCTAssertEqual(60, decoded.dataChunkWords)
            // TODO adding a datadump variable based on length
        } catch (let error) {
            XCTFail("message decoding threw error: \(error)")
        }
    }
    
    func testPodInfoFault() {
        // 02 11 (omitted)// 05 92 0001 00000000 00000000 091912170e
        // 09-25-18 23:14 int values for datetime
        do {                                            
            // Decode
            let decoded = try PodInfoFault(encodedData: Data(hexadecimalString: "059200010000000000000000091912170e")!)
            XCTAssertEqual(.fault, decoded.podInfoType)
            XCTAssertEqual(.faultEventSetupPodType92, decoded.faultEventType)
            XCTAssertEqual(0001*60, decoded.timeActivation)
            let decodedDateTime = decoded.dateTime
            XCTAssertEqual(2018, decodedDateTime.year)
            XCTAssertEqual(09, decodedDateTime.month)
            XCTAssertEqual(25, decodedDateTime.day)
            XCTAssertEqual(23, decodedDateTime.hour)
            XCTAssertEqual(14, decodedDateTime.minute)
        } catch (let error) {
            XCTFail("message decoding threw error: \(error)")
        }
    }
    
    func testPodInfoTester() {
        //02 05 // 06 01 00 3F A8
        do {
            // Decode
            let decoded = try PodInfoTester(encodedData: Data(hexadecimalString: "0601003FA8")!)
            XCTAssertEqual(.hardcodedTestValues, decoded.podInfoType)
            XCTAssertEqual(0x01, decoded.byte1)
            XCTAssertEqual(0x00, decoded.byte2)
            XCTAssertEqual(0x3F, decoded.byte3)
            XCTAssertEqual(0xA8, decoded.byte4)
        } catch (let error) {
            XCTFail("message decoding threw error: \(error)")
        }
    }
    
    func testPodInfoFlashLogRecent() {
        //02 cb 50 0086 34212e00 39203100 3c212d00 41203000 44202c00 49212e00 4c212b00 51202f00 54212c00 59203080 5c202d80 61203080 00212e80 05213180 08202f80 0d203280 10202f80 15213180 18202f80 1d213180 20202e80 25213300 28203200 2d213500 30213100 35213400 38213100 3d203500 40203100 45213300 48203000 4d213200 50212f00 55203300 58203080 5d213280 60202f800 12030800 4202c800 92131800 c2130801 12132801 42031801 92133801 c2031802 12032802 42132002 92035002 c2131003 12134000 3c3801c2 03180212 03280242 13200292 035002c2 13100312 1340003c 3
        do {
            // Decode
            let decoded = try PodInfoFlashLogRecent(encodedData: Data(hexadecimalString: "50008634212e00392031003c212d004120300044202c0049212e004c212b0051202f0054212c00592030805c202d806120308000212e800521318008202f800d20328010202f801521318018202f801d21318020202e8025213300282032002d2135003021310035213400382131003d2035004020310045213300482030004d21320050212f0055203300582030805d21328060202f800120308004202c80092131800c2130801121328014203180192133801c2031802120328024213200292035002c2131003121340003c3801c2031802120328024213200292035002c2131003121340003c3")!)
            XCTAssertEqual(.flashLogRecent, decoded.podInfoType)
            XCTAssertEqual(134, decoded.indexLastEntry)
            XCTAssertEqual(Data(hexadecimalString:"34212e00392031003c212d004120300044202c0049212e004c212b0051202f0054212c00592030805c202d806120308000212e800521318008202f800d20328010202f801521318018202f801d21318020202e8025213300282032002d2135003021310035213400382131003d2035004020310045213300482030004d21320050212f"), decoded.hexWordLog)
        } catch (let error) {
            XCTFail("message decoding threw error: \(error)")
        }
    }
    
    
    
    
    
    func testPodInfoResetStatus() {
        //02 7c (omitted)// 4600791f00ee841f00ee84ff00ff00ffffffffffff0000ffffffffffffffffffffffff04060d10070000a62b0004e3db0000ffffffffffffff32cd50af0ff014eb01fe01fe06f9ff00ff0002fd649b14eb14eb07f83cc332cd05fa02fd58a700ffffffffffffffffffffffffffffffffffffffffffffffffffffff2d00658effffffffffffff2d0065
        do {
            // Decode
            let decoded = try PodInfoResetStatus(encodedData: Data(hexadecimalString: "4600791f00ee841f00ee84ff00ff00ffffffffffff0000ffffffffffffffffffffffff04060d10070000a62b0004e3db0000ffffffffffffff32cd50af0ff014eb01fe01fe06f9ff00ff0002fd649b14eb14eb07f83cc332cd05fa02fd58a700ffffffffffffffffffffffffffffffffffffffffffffffffffffff2d00658effffffffffffff2d0065")!)
            XCTAssertEqual(.resetStatus, decoded.podInfoType)
            XCTAssertEqual(0, decoded.zero)
            XCTAssertEqual(121, decoded.numberOfBytes)
            XCTAssertEqual(0x1f00ee84, decoded.address)

        } catch (let error) {
            XCTFail("message decoding threw error: \(error)")
        }
    }
    
}
