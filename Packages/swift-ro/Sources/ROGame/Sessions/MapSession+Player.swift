//
//  MapSession+Player.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/12/18.
//

import ROConstants
import RONetwork

extension MapSession {
    func subscribeToPlayerPackets(with subscription: inout ClientSubscription) {
        // See `clif_walkok`
        subscription.subscribe(to: PACKET_ZC_NOTIFY_PLAYERMOVE.self) { [unowned self] packet in
            let moveData = MoveData(data: packet.moveData)
            let fromPosition = SIMD2(moveData.x0, moveData.y0)
            let toPosition = SIMD2(moveData.x1, moveData.y1)

            self.player.position = toPosition

            let event = PlayerEvents.Moved(fromPosition: fromPosition, toPosition: toPosition)
            self.postEvent(event)
        }

        // See `clif_displaymessage`
        subscription.subscribe(to: PACKET_ZC_NOTIFY_PLAYERCHAT.self) { [unowned self] packet in
            let event = PlayerEvents.MessageReceived(packet: packet)
            self.postEvent(event)
        }

        // See `clif_initialstatus`
        subscription.subscribe(to: PACKET_ZC_STATUS.self) { [unowned self] packet in
            self.player.status.update(with: packet)
            let event = PlayerEvents.StatusChanged(status: self.player.status)
            self.postEvent(event)
        }

        // See `clif_par_change`
        subscription.subscribe(to: PACKET_ZC_PAR_CHANGE.self) { [unowned self] packet in
            guard let sp = StatusProperty(rawValue: Int(packet.varID)) else {
                return
            }

            self.player.status.update(property: sp, value: Int(packet.count))
            let event = PlayerEvents.StatusChanged(status: self.player.status)
            self.postEvent(event)
        }

        // See `clif_longpar_change`
        subscription.subscribe(to: PACKET_ZC_LONGPAR_CHANGE.self) { [unowned self] packet in
            guard let sp = StatusProperty(rawValue: Int(packet.varID)) else {
                return
            }

            self.player.status.update(property: sp, value: Int(packet.amount))
            let event = PlayerEvents.StatusChanged(status: self.player.status)
            self.postEvent(event)
        }

        // See `clif_longlongpar_change`
        subscription.subscribe(to: PACKET_ZC_LONGLONGPAR_CHANGE.self) { [unowned self] packet in
            guard let sp = StatusProperty(rawValue: Int(packet.varID)) else {
                return
            }

            self.player.status.update(property: sp, value: Int(packet.amount))
            let event = PlayerEvents.StatusChanged(status: self.player.status)
            self.postEvent(event)
        }

        // See `clif_zc_status_change`
        subscription.subscribe(to: PACKET_ZC_STATUS_CHANGE.self) { [unowned self] packet in
            guard let sp = StatusProperty(rawValue: Int(packet.statusID)) else {
                return
            }

            self.player.status.update(property: sp, value: Int(packet.value))
            let event = PlayerEvents.StatusChanged(status: self.player.status)
            self.postEvent(event)
        }

        // See `clif_couplestatus`
        subscription.subscribe(to: PACKET_ZC_COUPLESTATUS.self) { [unowned self] packet in
            guard let sp = StatusProperty(rawValue: Int(packet.statusType)) else {
                return
            }

            self.player.status.update(property: sp, value: Int(packet.defaultStatus), value2: Int(packet.plusStatus))
            let event = PlayerEvents.StatusChanged(status: self.player.status)
            self.postEvent(event)
        }

        // See `clif_attackrange`
        subscription.subscribe(to: PACKET_ZC_ATTACK_RANGE.self) { [unowned self] packet in
            let event = PlayerEvents.AttackRangeChanged(packet: packet)
            self.postEvent(event)
        }

        // See `clif_cartcount`
        subscription.subscribe(to: PACKET_ZC_NOTIFY_CARTITEM_COUNTINFO.self) { packet in
        }
    }

    /// Request move.
    ///
    /// Send ``PACKET_CZ_REQUEST_MOVE``
    public func requestMove(x: Int16, y: Int16) {
        var packet = PACKET_CZ_REQUEST_MOVE()
        packet.x = x
        packet.y = y

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

    /// Request action.
    ///
    /// Send ``PACKET_CZ_REQUEST_ACT``
    public func requestAction(action: UInt8) {
        var packet = PACKET_CZ_REQUEST_ACT()
        packet.action = action

        client.sendPacket(packet)
    }

    public func attackOnTarget(targetID: UInt32) {
        var packet = PACKET_CZ_REQUEST_ACT()
        packet.targetID = targetID
        packet.action = 7

        client.sendPacket(packet)
    }
}
