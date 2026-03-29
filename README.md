# 🌊 Flow: The Frictionless Quantified-Self Journal

![iOS 17+](https://img.shields.io/badge/iOS-17.0+-blue.svg)
![Swift 5.9](https://img.shields.io/badge/Swift-5.9-orange.svg)
![Architecture](https://img.shields.io/badge/Architecture-MVVM-green.svg)
![AI](https://img.shields.io/badge/AI-OpenAI_GPT--4o-black.svg)

Flow is a minimalist, frictionless journaling and time-blocking app designed to help you capture your thoughts, track your mood, and analyze your day with the power of AI. 

More than just a diary, Flow acts as a mirror to your daily life—comparing your planned schedule with your actual activities, and visualizing your energy and mood trends.

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

## 🚀 Getting Started

To run this project locally on your Mac using Xcode:

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/YOUR-USERNAME/Flow.git](https://github.com/YOUR-USERNAME/Flow.git)
   cd Flow
Configure the AI API Key (Crucial Step):
For security reasons, the API key is not included in this repository. You must create a local secrets file.

Open the project in Xcode.

Right-click the root folder and select New File...

Choose Property List and name it Secrets.plist.

Add a new row:

Key: OPENAI_API_KEY

Type: String

Value: your-actual-openai-api-key-here

Note: Secrets.plist is already included in the .gitignore to prevent accidental uploads.

Build and Run:
Select an iOS 17+ simulator or your physical device, and hit Cmd + R.

🗺 Roadmap
[x] Core Timeline & SwiftData Models

[x] Schedule Management & Color Syncing

[x] Toolbox (Emoji & Score Tracking)

[x] AI Day Review & Data Visualization (Charts)

[ ] Live Activities & Dynamic Island: Implement ActivityKit for seamless 10-minute check-ins without opening the app.

[ ] Settings Module: Custom theme colors and personalized metrics.

Designed and built with ❤️ by [Your Name/Handle]
