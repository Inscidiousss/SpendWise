# 💰 ExpenseIQ — Smart Daily Expense Tracker

A full-featured Flutter expense tracking app with AI-powered savings & investment advice.

---

## ✨ Features

| Feature | Description |
|---|---|
| 📊 Dashboard | Balance overview, income vs expenses, savings rate |
| 💸 Transactions | Add, search, filter, swipe-to-delete transactions |
| 📈 Analytics | Pie chart + bar chart breakdowns by category & day |
| 🎯 Budget | Set category budgets, track progress, get alerts |
| 🧠 AI Advice | Personalized savings & investment guidance |
| 📤 Export | Export to CSV or PDF and share |
| 🌙 Dark Mode | Full dark/light theme toggle |
| 🗂️ Categories | 12 preset categories with emoji icons |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- Android Studio or VS Code with Flutter extension

### Installation

```bash
# 1. Clone or unzip the project
cd expense_tracker

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
```

### Build for release
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

---

## 🏗️ Project Structure

```
lib/
├── main.dart                        # App entry point
├── core/
│   ├── constants/
│   │   └── hive_constants.dart      # Hive box names & app constants
│   └── theme/
│       └── app_theme.dart           # Light & dark theme config
├── data/
│   ├── models/
│   │   ├── expense_model.dart       # Expense Hive model
│   │   ├── budget_model.dart        # Budget Hive model
│   │   └── category_model.dart      # Category Hive model
│   └── repositories/
│       └── expense_repository.dart  # Hive CRUD operations
├── providers/
│   ├── expense_provider.dart        # Expense state + AI advice logic
│   ├── budget_provider.dart         # Budget state management
│   └── theme_provider.dart          # Theme toggle
├── screens/
│   ├── splash/                      # Animated splash screen
│   ├── home/                        # Bottom nav shell
│   ├── dashboard/                   # Main overview
│   ├── add_expense/                 # Add income/expense form
│   ├── transactions/                # Full list + search + filter
│   ├── analytics/                   # Charts & category breakdown
│   ├── budget/                      # Budget manager
│   └── advice/                      # AI savings & investment screen
└── widgets/
    ├── expense_card.dart
    ├── summary_card.dart
    ├── month_selector.dart
    └── export_dialog.dart           # CSV & PDF export
```

---

## 📦 Key Dependencies

| Package | Purpose |
|---|---|
| `provider` | State management |
| `hive` + `hive_flutter` | Local NoSQL storage |
| `fl_chart` | Pie chart & bar chart |
| `pdf` + `csv` | Export functionality |
| `share_plus` | Native share sheet |
| `flutter_slidable` | Swipe-to-delete |
| `google_fonts` | Poppins typography |
| `iconsax` | Beautiful icons |

---

## 🧠 AI Savings Logic

The savings advice engine in `ExpenseProvider.getSavingsAdvice()` analyzes:
- **Savings Rate** = (Income − Expenses) / Income
- Provides tier-based advice: Excellent (≥30%), Good (≥20%), Fair (≥10%), Needs Work (<10%)
- Investment suggestions scale with available balance
- 50/30/20 rule breakdown personalized to user income

---

## 🎨 Design System

- **Primary**: `#6C63FF` (Purple)
- **Success**: `#4CAF50` (Green)
- **Error**: `#EF5350` (Red)
- **Warning**: `#FF9800` (Amber)
- **Font**: Poppins (Google Fonts)

---

## 📱 Screenshots

> Run the app to see:
> - Animated splash screen
> - Gradient dashboard with balance card
> - Category picker with emoji icons
> - Interactive pie & bar charts
> - Budget progress bars with alerts
> - AI advice with financial health score

---

## 🔒 Privacy

All data is stored **locally** on-device using Hive. No data is sent to any server.

---

Made with ❤️ using Flutter & Dart
