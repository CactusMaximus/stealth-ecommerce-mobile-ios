import SwiftUI

struct GoogleSignInButton: View {
    var action: () -> Void
    var isLoading: Bool
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                        .frame(width: 20, height: 20)
                } else {
                    Image(systemName: "g.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.black)
                }
                
                Text("Sign in with Google")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(50)
            .overlay(
                RoundedRectangle(cornerRadius: 50)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
        }
        .disabled(isLoading)
    }
}

#Preview {
    VStack {
        GoogleSignInButton(action: {}, isLoading: false)
        GoogleSignInButton(action: {}, isLoading: true)
    }
    .padding()
    .background(Color.gray.opacity(0.1))
} 