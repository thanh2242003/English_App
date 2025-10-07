# App Navigation Logic

## Tổng quan
App sử dụng `AppNavigator` để quản lý logic điều hướng thông minh dựa trên trạng thái người dùng.

## Luồng Navigation

### Lần đầu tiên mở app:
1. **SplashScreen** (2 giây) → **WelcomeScreen** → **OnboardingScreen** → **LoginScreen**

### Lần thứ 2 trở đi (chưa đăng nhập):
1. **SplashScreen** (2 giây) → **LoginScreen** (bỏ qua Welcome và Onboarding)

### Đã đăng nhập:
1. **SplashScreen** (2 giây) → **HomeScreen** (bỏ qua tất cả màn hình khác)

## Cách hoạt động

### AppNavigator
- Kiểm tra trạng thái đăng nhập của Firebase Auth
- Kiểm tra SharedPreferences để xác định màn hình nào đã được hiển thị
- Quyết định màn hình tiếp theo dựa trên:
  - `welcome_shown`: Đã hiển thị WelcomeScreen chưa
  - `onboarding_completed`: Đã hoàn thành OnboardingScreen chưa
  - Firebase Auth currentUser: Đã đăng nhập chưa

### SharedPreferences Keys
- `welcome_shown`: Boolean - Đã hiển thị WelcomeScreen
- `onboarding_completed`: Boolean - Đã hoàn thành OnboardingScreen

## Các trường hợp đặc biệt
- Nếu user nhấn "Tôi đã có tài khoản" trong WelcomeScreen → Bỏ qua Onboarding và đi thẳng LoginScreen
- Nếu có lỗi trong quá trình kiểm tra → Mặc định đi đến LoginScreen
- SplashScreen luôn hiển thị ít nhất 2 giây để tạo trải nghiệm mượt mà
