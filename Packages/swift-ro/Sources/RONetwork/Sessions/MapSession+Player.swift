//
//  MapSession+Player.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/12/18.
//

import ROGenerated

extension MapSession {
    func registerPlayerPackets() {
        // See `clif_walkok`
        client.registerPacket(PACKET_ZC_NOTIFY_PLAYERMOVE.self, for: HEADER_ZC_NOTIFY_PLAYERMOVE) { [unowned self] packet in
            let moveData = MoveData(data: packet.moveData)
            let fromPosition = SIMD2(moveData.x0, moveData.y0)
            let toPosition = SIMD2(moveData.x1, moveData.y1)

            await self.storage.updatePlayerPosition(toPosition)

            let event = PlayerEvents.Moved(fromPosition: fromPosition, toPosition: toPosition)
            self.postEvent(event)
        }

        // See `clif_displaymessage`
        client.registerPacket(PACKET_ZC_NOTIFY_PLAYERCHAT.self, for: PACKET_ZC_NOTIFY_PLAYERCHAT.packetType) { [unowned self] packet in
            let event = PlayerEvents.MessageReceived(packet: packet)
            self.postEvent(event)
        }

        // See `clif_initialstatus`
        client.registerPacket(PACKET_ZC_STATUS.self, for: HEADER_ZC_STATUS) { packet in
            await self.storage.updatePlayerStatus(with: packet)

            if let status = await self.storage.player?.status {
                let event = PlayerEvents.StatusChanged(status: status)
                self.postEvent(event)
            }
        }

        // See `clif_par_change`
        client.registerPacket(PACKET_ZC_PAR_CHANGE.self, for: HEADER_ZC_PAR_CHANGE) { [unowned self] packet in
            guard let sp = StatusProperty(rawValue: Int(packet.varID)) else {
                return
            }

            await self.storage.updatePlayerStatusProperty(sp, value: Int(packet.count))

            if let status = await self.storage.player?.status {
                let event = PlayerEvents.StatusChanged(status: status)
                self.postEvent(event)
            }
        }

        // See `clif_longpar_change`
        client.registerPacket(PACKET_ZC_LONGPAR_CHANGE.self, for: HEADER_ZC_LONGPAR_CHANGE) { [unowned self] packet in
            guard let sp = StatusProperty(rawValue: Int(packet.varID)) else {
                return
            }

            await self.storage.updatePlayerStatusProperty(sp, value: Int(packet.amount))

            if let status = await self.storage.player?.status {
                let event = PlayerEvents.StatusChanged(status: status)
                self.postEvent(event)
            }
        }

        // See `clif_longlongpar_change`
        client.registerPacket(PACKET_ZC_LONGLONGPAR_CHANGE.self, for: HEADER_ZC_LONGLONGPAR_CHANGE) { [unowned self] packet in
            guard let sp = StatusProperty(rawValue: Int(packet.varID)) else {
                return
            }

            await self.storage.updatePlayerStatusProperty(sp, value: Int(packet.amount))

            if let status = await self.storage.player?.status {
                let event = PlayerEvents.StatusChanged(status: status)
                self.postEvent(event)
            }
        }

        // See `clif_zc_status_change`
        client.registerPacket(PACKET_ZC_STATUS_CHANGE.self, for: HEADER_ZC_STATUS_CHANGE) { [unowned self] packet in
            guard let sp = StatusProperty(rawValue: Int(packet.statusID)) else {
                return
            }

            await self.storage.updatePlayerStatusProperty(sp, value: Int(packet.value))

            if let status = await self.storage.player?.status {
                let event = PlayerEvents.StatusChanged(status: status)
                self.postEvent(event)
            }
        }

        // See `clif_couplestatus`
        client.registerPacket(PACKET_ZC_COUPLESTATUS.self, for: HEADER_ZC_COUPLESTATUS) { [unowned self] packet in
            guard let sp = StatusProperty(rawValue: Int(packet.statusType)) else {
                return
            }

            await self.storage.updatePlayerStatusProperty(sp, value: Int(packet.defaultStatus), value2: Int(packet.plusStatus))

            if let status = await self.storage.player?.status {
                let event = PlayerEvents.StatusChanged(status: status)
                self.postEvent(event)
            }
        }

        // See `clif_attackrange`
        client.registerPacket(PACKET_ZC_ATTACK_RANGE.self, for: HEADER_ZC_ATTACK_RANGE) { [unowned self] packet in
            let event = PlayerEvents.AttackRangeChanged(packet: packet)
            self.postEvent(event)
        }

        // See `clif_cartcount`
        client.registerPacket(PACKET_ZC_NOTIFY_CARTITEM_COUNTINFO.self, for: HEADER_ZC_NOTIFY_CARTITEM_COUNTINFO) { packet in
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
