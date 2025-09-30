import SwiftUI

struct WalletView: View {
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Image(systemName: "arrow.left")
                    .font(.title2)
                    .foregroundColor(.black)
                Spacer()
                Text("ofsp_ce")
                    .font(.headline)
                Spacer()
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 28, height: 28)
            }
            .padding(.horizontal)
            
            // Balance
            VStack(spacing: 8) {
                Text("Total Balance")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("$127.89")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                
                HStack {
                    Image(systemName: "creditcard.fill")
                        .foregroundColor(.black)
                    Text("**** 8901 3901")
                        .font(.callout)
                        .fontWeight(.medium)
                }
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .clipShape(Capsule())
            }
            
            // Action buttons
            HStack(spacing: 30) {
                ActionButton(icon: "arrow.up.right", label: "Send", color: .green.opacity(0.3))
                ActionButton(icon: "arrow.down", label: "Receive", color: .blue.opacity(0.3))
                ActionButton(icon: "plus", label: "Add", color: .purple.opacity(0.3))
            }
            .padding(.top, 10)
            
            // Transactions (avatars)
            VStack(alignment: .leading, spacing: 12) {
                Text("Transaction")
                    .font(.headline)
                HStack(spacing: 24) {
                    AvatarView(name: "Ronald R.", imageName: "person.crop.circle.fill", color: .yellow)
                    AvatarView(name: "Ralph E.", imageName: "person.crop.circle.fill", color: .green)
                    AvatarView(name: "Marvin M.", imageName: "person.crop.circle.fill", color: .blue)
                    AvatarView(name: "Kristin W.", imageName: "person.crop.circle.fill", color: .purple)
                }
            }
            .padding(.horizontal)
            
            // Recent Activities
            VStack(alignment: .leading, spacing: 12) {
                Text("Recent activites")
                    .font(.headline)
                VStack(spacing: 16) {
                    ActivityRow(icon: "arrow.up.right", color: .orange, title: "Car Parking", date: "February 9 · 02:45 pm", amount: "$293.01")
                    ActivityRow(icon: "arrow.down", color: .purple, title: "Game purchase", date: "February 9 · 02:45 pm", amount: "$778.35")
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.3), lineWidth: 1))
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top)
    }
}

// MARK: - Components

struct ActionButton: View {
    let icon: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 60, height: 60)
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.black)
            }
            Text(label)
                .font(.footnote)
        }
    }
}

struct AvatarView: View {
    let name: String
    let imageName: String
    let color: Color
    
    var body: some View {
        VStack {
            Circle()
                .fill(color.opacity(0.3))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: imageName)
                        .resizable()
                        .scaledToFit()
                        .padding(12)
                        .foregroundColor(.black)
                )
            Text(name)
                .font(.caption)
                .lineLimit(1)
        }
    }
}

struct ActivityRow: View {
    let icon: String
    let color: Color
    let title: String
    let date: String
    let amount: String
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(color.opacity(0.3))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundColor(.black)
            }
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text(amount)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
}

// MARK: - Preview
struct WalletView_Previews: PreviewProvider {
    static var previews: some View {
        WalletView()
    }
}
