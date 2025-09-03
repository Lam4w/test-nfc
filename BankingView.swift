import SwiftUI

struct BankingHomeView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // MARK: - Header
                HStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 40, height: 40)
                        .overlay(Text("TC").font(.caption).bold())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Xin chào,")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("Nguyễn Văn A")
                            .font(.headline)
                            .bold()
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        Image(systemName: "bell")
                        Image(systemName: "qrcode.viewfinder")
                    }
                    .font(.title3)
                    .foregroundColor(.white)
                }
                .padding(.horizontal)
                .padding(.top)
                
                // MARK: - Balance Card
                VStack(alignment: .leading, spacing: 8) {
                    Text("Số dư khả dụng")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.subheadline)
                    
                    Text("1,234,567,890 VND")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Số tài khoản **** 1234")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(LinearGradient(colors: [Color.blue, Color.blue.opacity(0.8)],
                                             startPoint: .topLeading,
                                             endPoint: .bottomTrailing))
                )
                .padding(.horizontal)
                
                // MARK: - Quick Actions
                HStack(spacing: 30) {
                    QuickActionItem(icon: "arrow.up.right", title: "Chuyển tiền")
                    QuickActionItem(icon: "qrcode", title: "QR Code")
                    QuickActionItem(icon: "wifi", title: "VietTap")
                    QuickActionItem(icon: "ellipsis", title: "Thêm")
                }
                .padding(.horizontal)
                
                // MARK: - Promo Card
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ưu đãi đặc biệt")
                        .font(.headline)
                        .foregroundColor(.black)
                    Text("Miễn phí chuyển tiền liên ngân hàng\ntrong tháng 12")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Button(action: {}) {
                        Text("Tìm hiểu thêm")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.top, 8)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 3)
                .padding(.horizontal)
                
                // MARK: - News & Notifications
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Tin tức & Thông báo")
                            .font(.headline)
                        Spacer()
                        Button("Xem tất cả") {}
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    
                    NotificationItem(title: "Cập nhật bảo mật mới",
                                     subtitle: "Tính năng xác thực sinh trắc học được nâng cấp",
                                     time: "2 giờ trước")
                    
                    NotificationItem(title: "Khuyến mãi thẻ tín dụng",
                                     subtitle: "Nhận ưu đãi hấp dẫn khi mở thẻ mới",
                                     time: "1 ngày trước")
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 20)
        }
        .background(Color(.systemGray6).ignoresSafeArea())
    }
}

// MARK: - Components
struct QuickActionItem: View {
    let icon: String
    let title: String
    
    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(Image(systemName: icon).foregroundColor(.blue))
            Text(title)
                .font(.footnote)
                .foregroundColor(.black)
        }
    }
}

struct NotificationItem: View {
    let title: String
    let subtitle: String
    let time: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.subheadline).bold()
            Text(subtitle).font(.footnote).foregroundColor(.gray)
            Text(time).font(.caption).foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 3, x: 0, y: 2)
    }
}

# Preview
struct BankingHomeView_Previews: PreviewProvider {
    static var previews: some View {
        BankingHomeView()
    }
}

            if isSelected {
                // Selected style
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.hex("1E3A8A")) // dark blue background
                    .frame(width: 44, height: 36)
                    .overlay(
                        Image(systemName: icon)
                            .foregroundColor(.white)
                    )
            } else {
                // Unselected style
                Image(systemName: icon)
                    .foregroundColor(.gray)
                    .frame(width: 44, height: 36)
            }