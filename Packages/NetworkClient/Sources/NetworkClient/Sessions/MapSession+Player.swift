//
//  MapSession+Player.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/12/18.
//

import Constants
import NetworkPackets

extension MapSession {
    func subscribeToPlayerPackets(with subscription: inout ClientSubscription) {
        // See `clif_walkok`
        subscription.subscribe(to: PACKET_ZC_NOTIFY_PLAYERMOVE.self) { [unowned self] packet in
            let moveData = MoveData(data: packet.moveData)
            let startPosition = SIMD2(x: Int(moveData.x0), y: Int(moveData.y0))
            let endPosition = SIMD2(x: Int(moveData.x1), y: Int(moveData.y1))

            let event = PlayerEvents.Moved(startPosition: startPosition, endPosition: endPosition)
            self.postEvent(event)
        }

        // See `clif_initialstatus`
        subscription.subscribe(to: PACKET_ZC_STATUS.self) { [unowned self] packet in
            self.status.update(with: packet)
            let event = PlayerEvents.StatusChanged(status: self.status)
            self.postEvent(event)
        }

        // See `clif_par_change`
        subscription.subscribe(to: PACKET_ZC_PAR_CHANGE.self) { [unowned self] packet in
            guard let sp = StatusProperty(rawValue: Int(packet.varID)) else {
                return
            }

            self.status.update(property: sp, value: Int(packet.count))
            let event = PlayerEvents.StatusChanged(status: self.status)
            self.postEvent(event)
        }

        // See `clif_longpar_change`
        subscription.subscribe(to: PACKET_ZC_LONGPAR_CHANGE.self) { [unowned self] packet in
            guard let sp = StatusProperty(rawValue: Int(packet.varID)) else {
                return
            }

            self.status.update(property: sp, value: Int(packet.amount))
            let event = PlayerEvents.StatusChanged(status: self.status)
            self.postEvent(event)
        }

        // See `clif_longlongpar_change`
        subscription.subscribe(to: PACKET_ZC_LONGLONGPAR_CHANGE.self) { [unowned self] packet in
            guard let sp = StatusProperty(rawValue: Int(packet.varID)) else {
                return
            }

            self.status.update(property: sp, value: Int(packet.amount))
            let event = PlayerEvents.StatusChanged(status: self.status)
            self.postEvent(event)
        }

        // See `clif_zc_status_change`
        subscription.subscribe(to: PACKET_ZC_STATUS_CHANGE.self) { [unowned self] packet in
            guard let sp = StatusProperty(rawValue: Int(packet.statusID)) else {
                return
            }

            self.status.update(property: sp, value: Int(packet.value))
            let event = PlayerEvents.StatusChanged(status: self.status)
            self.postEvent(event)
        }

        // See `clif_couplestatus`
        subscription.subscribe(to: PACKET_ZC_COUPLESTATUS.self) { [unowned self] packet in
            guard let sp = StatusProperty(rawValue: Int(packet.statusType)) else {
                return
            }

            self.status.update(property: sp, value: Int(packet.defaultStatus), value2: Int(packet.plusStatus))
            let event = PlayerEvents.StatusChanged(status: self.status)
            self.postEvent(event)
        }

        // See `clif_statusupack`
        subscription.subscribe(to: PACKET_ZC_STATUS_CHANGE_ACK.self) { packet in
        }

        // See `clif_attackrange`
        subscription.subscribe(to: PACKET_ZC_ATTACK_RANGE.self) { [unowned self] packet in
            let event = PlayerEvents.AttackRangeChanged(value: Int(packet.currentAttRange))
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
        var packet = PACKET_CZ_REQUEST_MOVE()
        packet.x = Int16(position.x)
        packet.y = Int16(position.y)

        client.sendPacket(packet)
    }

    /// Request action on target.
    ///
    /// Send ``PACKET_CZ_REQUEST_ACT``
    public func requestAction(_ actionType: DamageType, onTarget targetID: UInt32 = 0) {
        var packet = PACKET_CZ_REQUEST_ACT()
        packet.targetID = targetID
        packet.action = UInt8(actionType.rawValue)

        client.sendPacket(packet)
    }

    /// Change direction.
    ///
    /// Send ``PACKET_CZ_CHANGE_DIRECTION``
    ///
    /// Receive ``PACKET_ZC_CHANGE_DIRECTION``
    public func changeDirection(headDirection: UInt16, direction: UInt8) {
        var packet = PACKET_CZ_CHANGE_DIRECTION()
        packet.headDirection = headDirection
        packet.direction = direction

        client.sendPacket(packet)
    }

    public func incrementStatusProperty(_ sp: StatusProperty, by amount: Int) {
        switch sp {
        case .str, .agi, .vit, .int, .dex, .luk:
            var packet = PACKET_CZ_STATUS_CHANGE()
            packet.statusID = Int16(sp.rawValue)
            packet.amount = Int8(amount)

            client.sendPacket(packet)
        case .pow, .sta, .wis, .spl, .con, .crt:
            var packet = PACKET_CZ_ADVANCED_STATUS_CHANGE()
            packet.packetType = HEADER_CZ_ADVANCED_STATUS_CHANGE
            packet.type = Int16(sp.rawValue)
            packet.amount = Int16(amount)

            client.sendPacket(packet)
        default:
            break
        }
    }
}
