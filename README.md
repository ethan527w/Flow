# 🌊 Flow: The Frictionless Quantified-Self Journal
![iOS 17+](https://img.shields.io/badge/iOS-17.0+-blue.svg)
![Swift 5.9](https://img.shields.io/badge/Swift-5.9-orange.svg)
![Architecture](https://img.shields.io/badge/Architecture-MVVM-green.svg)
![AI](https://img.shields.io/badge/AI-OpenAI_GPT--4o-black.svg)


> **Record at the speed of thought. Understand your days through AI.**
Flow is a minimalist, modern iOS journaling application built with SwiftUI. It breaks down the barrier between feeling and recording by offering an instant-input interface, timeline-based tracking, and deep AI insights that compare your planned schedule with your actual inferred activities.

## ✨ Core Features

* **⚡️ Frictionless Capture:** The keyboard is ready the moment you open the app. Quickly log thoughts, or use the Toolbox to drop a quick Emoji or a 1-10 mood score without typing a single word.
* **🎨 Dynamic Color-Coded Timeline:** Your journal entries are elegantly connected on a vertical timeline. The timeline automatically changes color based on your planned schedule for that specific time block.
* **📅 Notion-Style Time Blocking:** Easily plan your day with a clean, list-based schedule interface. Swipe left and right to navigate through different days effortlessly.
* **🧠 AI-Powered Day Review:** At the end of the day, generate a personalized "Daily Insight". Flow's AI engine analyzes your entries to:
    * Extract 3 defining keywords for your day.
    * Infer your *actual* schedule to compare against your *planned* schedule.
* **📊 Beautiful Visualizations:** Built with native Swift Charts to plot your Energy vs. Mood fluctuations throughout the day in a gorgeous, smoothed line graph.

## 🛠 Tech Stack

* **UI Framework:** SwiftUI
* **Local Storage:** SwiftData (iOS 17 native)
* **Data Visualization:** Swift Charts
* **AI Integration:** URLSession + Custom JSON Parsing (OpenAI API)
* **Architecture:** MVVM (Model-View-ViewModel)
# 🌊 Flow: The Frictionless Journal & Quantified Self App

## 🚀 Getting Started

Follow these instructions to get the project up and running on your local machine for development and testing.

### Prerequisites
* macOS running Xcode 15 or later.
* iOS 17.0+ Simulator or physical device.
* An active OpenAI API Key.

### Installation & Setup

1. **Configure the AI Secrets:**
   For security, the API key is not included in the repository. You must create a `Secrets.plist` file.
   * Open the project in Xcode.
   * Right-click the root folder -> **New File...** -> **Property List**.
   * Name it `Secrets.plist`.
   * Add a new key-value pair:
     * **Key:** `OPENAI_API_KEY`
     * **Type:** `String`
     * **Value:** `your_actual_openai_api_key_here`
   * *Note: Ensure `Secrets.plist` is in your `.gitignore` file before making any new commits.*

2. **Build and Run:**
   Select your target simulator or device in Xcode and press `Cmd + R`.

---

## 🗺 Roadmap / Future Work

- [x] Core Data/SwiftData models & Timeline UI
- [x] Custom Schedule Management
- [x] OpenAI API integration & JSON parsing
- [x] Swift Charts for Energy/Mood visualization
- [ ] **Dynamic Island & Live Activities:** Every 10-minute prompt for instant mood rating.
- [ ] **Settings Menu:** Custom theme colors and configurable metrics.
- [ ] **Weekly/Monthly Insights:** Aggregating DailySummaries into longer-term trends.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---
*Designed & Developed by Ethan ｜ Bilibili @氘氚新能源*
