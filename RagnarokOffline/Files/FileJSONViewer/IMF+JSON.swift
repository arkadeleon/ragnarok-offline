//
//  IMF+JSON.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/14.
//

import ROFileFormats

extension IMF {
    var json: String {
        """
        {
          "version": \(version),
          "checksum": \(checksum),
          "layers": \(layers.map(\.json).json)
        }
        """
    }
}

extension IMF.Layer {
    var json: String {
        """
        {
          "actions": \(actions.map(\.json).json)
        }
        """
    }
}

extension IMF.Action {
    var json: String {
        """
        {
          "frames": \(frames.map(\.json).json)
        }
        """
    }
}

extension IMF.Frame {
    var json: String {
        """
        {
          "priority": \(priority)
        }
        """
    }
}
