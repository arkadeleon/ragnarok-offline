//
//  MapSession+Player.swift
//  RagnarokNetwork
//
//  Created by Leon Li on 2024/12/18.
//

import RagnarokConstants
import RagnarokModels
import RagnarokPackets

extension MapSession {
    func subscribeToPlayerPackets(with subscription: inout ClientSubscription) {
        // See `clif_walkok`
        subscription.subscribe(to: PACKET_ZC_NOTIFY_PLAYERMOVE.self) { [unowned self] packet in
            let moveData = MoveData(from: packet.moveData)

            let event = MapSession.Event.playerMoved(
                startPosition: moveData.startPosition,
                endPosition: moveData.endPosition
            )
            self.postEvent(event)
        }

        // See `clif_initialstatus`
        subscription.subscribe(to: PACKET_ZC_STATUS.self) { [unowned self] packet in
            let basicStatus = CharacterBasicStatus(from: packet)
            let event = MapSession.Event.playerStatusChanged(basicStatus: basicStatus)
            self.postEvent(event)
        }

        // See `clif_par_change`
        subscription.subscribe(to: PACKET_ZC_PAR_CHANGE.self) { [unowned self] packet in
            guard let sp = StatusProperty(rawValue: Int(packet.varID)) else {
                return
            }

            let event = MapSession.Event.playerStatusPropertyChanged(property: sp, value: Int(packet.count))
            self.postEvent(event)
        }

        // See `clif_longpar_change`
        subscription.subscribe(to: PACKET_ZC_LONGPAR_CHANGE.self) { [unowned self] packet in
            guard let sp = StatusProperty(rawValue: Int(packet.varID)) else {
                return
            }

            let event = MapSession.Event.playerStatusPropertyChanged(property: sp, value: Int(packet.amount))
            self.postEvent(event)
        }

        // See `clif_longlongpar_change`
        subscription.subscribe(to: PACKET_ZC_LONGLONGPAR_CHANGE.self) { [unowned self] packet in
            guard let sp = StatusProperty(rawValue: Int(packet.varID)) else {
                return
            }

            let event = MapSession.Event.playerStatusPropertyChanged(property: sp, value: Int(packet.amount))
            self.postEvent(event)
        }

        // See `clif_zc_status_change`
        subscription.subscribe(to: PACKET_ZC_STATUS_CHANGE.self) { [unowned self] packet in
            guard let sp = StatusProperty(rawValue: Int(packet.statusID)) else {
                return
            }

            let event = MapSession.Event.playerStatusPropertyChanged(property: sp, value: Int(packet.value))
            self.postEvent(event)
        }

        // See `clif_couplestatus`
        subscription.subscribe(to: PACKET_ZC_COUPLESTATUS.self) { [unowned self] packet in
            guard let sp = StatusProperty(rawValue: Int(packet.statusType)) else {
                return
            }

            let event = MapSession.Event.playerStatusPropertyChanged2(property: sp, value: Int(packet.defaultStatus), value2: Int(packet.plusStatus))
            self.postEvent(event)
        }

        // See `clif_statusupack`
        subscription.subscribe(to: PACKET_ZC_STATUS_CHANGE_ACK.self) { packet in
        }

        // See `clif_attackrange`
        subscription.subscribe(to: PACKET_ZC_ATTACK_RANGE.self) { [unowned self] packet in
            let event = MapSession.Event.playerAttackRangeChanged(value: Int(packet.currentAttRange))
            self.postEvent(event)
        }

        // See `clif_cartcount`
        subscription.subscribe(to: PACKET_ZC_NOTIFY_CARTITEM_COUNTINFO.self) { packet in
        }
    }

    /// Request move to position.
    ///
    /// Send ``PACKET_CZ_REQUEST_MOVE``
    public func requestMove(to position: SIMD2<Int>) {
        let packet = PacketFactory.CZ_REQUEST_MOVE(position: position)
        client.sendPacket(packet)
    }

    /// Request action on target.
    ///
    /// Send ``PACKET_CZ_REQUEST_ACT``
    public func requestAction(_ actionType: DamageType, onTarget targetID: UInt32 = 0) {
        let packet = PacketFactory.CZ_REQUEST_ACT(targetID: targetID, actionType: actionType)
        client.sendPacket(packet)
    }

    /// Change direction.
    ///
    /// Send ``PACKET_CZ_CHANGE_DIRECTION``
    ///
    /// Receive ``PACKET_ZC_CHANGE_DIRECTION``
    public func changeDirection(headDirection: UInt16, direction: UInt8) {
        let packet = PacketFactory.CZ_CHANGE_DIRECTION(headDirection: headDirection, direction: direction)
        client.sendPacket(packet)
    }

    public func incrementStatusProperty(_ sp: StatusProperty, by amount: Int) {
        switch sp {
        case .str, .agi, .vit, .int, .dex, .luk:
            let packet = PacketFactory.CZ_STATUS_CHANGE(property: sp, amount: amount)
            client.sendPacket(packet)
        case .pow, .sta, .wis, .spl, .con, .crt:
            let packet = PacketFactory.CZ_ADVANCED_STATUS_CHANGE(property: sp, amount: amount)
            client.sendPacket(packet)
        default:
            break
        }
    }
}
