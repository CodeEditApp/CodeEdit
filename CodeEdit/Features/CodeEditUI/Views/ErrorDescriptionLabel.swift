//
//  ErrorDescriptionLabel.swift
//  CodeEdit
//
//  Created by Khan Winter on 8/14/25.
//

import SwiftUI

struct ErrorDescriptionLabel: View {
    let error: Error

    var body: some View {
        VStack(alignment: .leading) {
            if let error = error as? LocalizedError {
                if let description = error.errorDescription {
                    Text(description)
                }

                if let reason = error.failureReason {
                    Text(reason)
                }

                if let recoverySuggestion = error.recoverySuggestion {
                    Text(recoverySuggestion)
                }
            } else {
                Text(error.localizedDescription)
            }
        }
    }
}

#Preview {
    ErrorDescriptionLabel(error: CancellationError())
}
