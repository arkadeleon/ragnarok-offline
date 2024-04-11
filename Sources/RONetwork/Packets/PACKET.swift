//
//  PACKET.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/7/6.
//

public enum PACKET {

    /// Client -> Login Server
    public enum CA {
    }

    /// Login Server -> Client
    public enum AC {
    }

    /// Client -> Char Server
    public enum CH {
    }

    /// Char Server -> Client
    public enum HC {
    }

    /// Client -> Map Server
    public enum CZ {
    }

    /// Map Server -> Client
    public enum ZC {
    }

    /// Client -> All Servers
    public enum CS {
    }

    /// All Servers -> Client
    public enum SC {
    }
}
