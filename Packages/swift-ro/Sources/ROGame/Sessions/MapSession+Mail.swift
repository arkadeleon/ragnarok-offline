//
//  MapSession+Mail.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/4/3.
//

import RONetwork

extension MapSession {
    func subscribeToMailPackets(with subscription: inout ClientSubscription) {
        // See `clif_Mail_window`
//        subscription.subscribe(to: ZC_MAIL_WINDOWS) { packet in
//        }

        // See `clif_Mail_refreshinbox`
//        subscription.subscribe(to: ZC_MAIL_REQ_GET_LIST) { packet in
//        }

        // See `clif_Mail_read`
//        subscription.subscribe(to: ZC_MAIL_REQ_OPEN) { packet in
//        }

        // See `clif_mail_getattachment`
//        subscription.subscribe(to: ZC_MAIL_REQ_GET_ITEM) { packet in
//        }

        // See `clif_Mail_send`
//        subscription.subscribe(to: ZC_MAIL_REQ_SEND) { packet in
//        }

        // See `clif_Mail_new`
        subscription.subscribe(to: PACKET_ZC_MAIL_RECEIVE.self) { packet in
        }

        // See `clif_Mail_setattachment`
//        subscription.subscribe(to: ZC_ACK_MAIL_ADD_ITEM) { packet in
//        }

        // See `clif_mail_delete`
//        subscription.subscribe(to: ZC_ACK_MAIL_DELETE) { packet in
//        }

        // See `clif_Mail_return`
//        subscription.subscribe(to: ZC_ACK_MAIL_RETURN) { packet in
//        }
    }

    func subscribeToRodexPackets(with subscription: inout ClientSubscription) {
        // See `clif_Mail_refreshinbox`
//        subscription.subscribe(to: ZC_ACK_MAIL_LIST) { packet in
//        }

        // See `clif_Mail_read`
        subscription.subscribe(to: PACKET_ZC_ACK_READ_RODEX.self) { packet in
        }

        // See `clif_mail_getattachment`
        subscription.subscribe(to: PACKET_ZC_ACK_ITEM_FROM_MAIL.self) { packet in
        }

        // See `clif_Mail_send`
        subscription.subscribe(to: PACKET_ZC_WRITE_MAIL_RESULT.self) { packet in
        }

        // See `clif_Mail_new`
        subscription.subscribe(to: PACKET_ZC_NOTIFY_UNREADMAIL.self) { packet in
        }

        // See `clif_Mail_setattachment`
        subscription.subscribe(to: PACKET_ZC_ACK_ADD_ITEM_RODEX.self) { packet in
        }

        // See `clif_mail_delete`
        subscription.subscribe(to: PACKET_ZC_ACK_DELETE_MAIL.self) { packet in
        }
    }
}
