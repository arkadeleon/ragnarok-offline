//
//  FileHelpView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/5.
//

import SwiftUI

struct FileHelpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            Text("""
            # Copy Ragnarok Online Client Data to iOS Device
            
            1. Prerequisites:
               - A Windows PC with the latest kRO (Korean Ragnarok Online) client installed
               - An iOS device (iPhone/iPad)
               - Both devices connected to the same local network
            
            2. On Windows PC:
               - Install the latest kRO client
               - Right-click the client folder and select "Properties"
               - Enable file sharing for the folder
               - Note down your Windows PC's IP address
            
            3. On iOS Device:
               - Launch the **Files** app
               - Tap the **More** icon (three dots) in the top-right corner
               - Select **Connect to Server**
               - Enter your Windows PC's IP address
               - Provide your Windows username and password when prompted
               - Tap **Connect**
            
            4. Transfer Files:
               - Navigate to the shared kRO client folder
               - Locate the **data.grf** file
               - Long-press the file and select **Copy**
               - Navigate to **On My iPhone/iPad** > **Ragnarok Offline**
               - Long-press any empty space and select **Paste**
            
            Note: The transfer speed depends on your local network connection.
            """)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationTitle("Help")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}
