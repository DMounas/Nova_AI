# Nova AI - Voice-First Conversational Assistant

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Google_Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white" alt="Google Cloud" />
  <img src="https://img.shields.io/badge/Gemini_API-8E44AD?style=for-the-badge&logo=google-gemini&logoColor=white" alt="Gemini API" />
</p>

A sophisticated, cross-platform conversational AI assistant built with Flutter, leveraging Google's Gemini and Vertex AI APIs for real-time chat and generative image creation.

---

<p align="center">
  <img src="Nova_ai.gif" width="400" alt="Nova AI App Demo">
</p>

## About The Project

Nova AI is a voice-first mobile assistant designed to provide a seamless and intuitive user experience. The application features a dual-AI backend, intelligently routing user prompts to the appropriate service. For conversational queries, it utilizes the powerful Google Gemini API to deliver fluid, context-aware responses, which are then vocalized using a native text-to-speech engine.

For creative requests, the app identifies the user's intent to generate art and calls the Google Vertex AI (Imagen) API to create stunning images from text prompts. The architecture is built to handle asynchronous operations gracefully, providing users with immediate visual feedback (loading states) to ensure a smooth, non-blocking UI.

## Features

- ✅ **Voice-First Interface:** Start conversations and give commands entirely through voice.
- ✅ **Dual AI Backend:** Intelligently routes prompts to either Gemini for chat or Vertex AI for image generation.
- ✅ **Text-to-Image Generation:** Create high-quality images from text descriptions.
- ✅ **Conversational Experience:** The AI's responses are spoken aloud using a native TTS engine.
- ✅ **Responsive & Performant UI:** Asynchronous architecture with loading indicators prevents UI freezing ("jank") during API calls.
- ✅ **Intuitive Controls:** Users can interrupt the assistant's speech by tapping the microphone, and a dedicated button allows for easy conversation resets.

## Tech Stack & Architecture

- **Core Framework:** Flutter & Dart
- **State Management:** `setState` for managing UI state including loading, listening, and result states.
- **AI & Cloud Services:**
    - **Google Gemini API:** For advanced conversational text generation.
    - **Google Vertex AI (Imagen Model):** For text-to-image generation.
    - **Google Cloud Platform (GCP):** For API management, billing, and service enablement.
- **Key Flutter Packages:**
    - `speech_to_text`: For native speech recognition.
    - `flutter_tts`: For native text-to-speech synthesis.
    - `http`: For handling advanced API requests to Vertex AI.
    - `google_generative_ai`: For streamlined interaction with the Gemini API.
- **Development Tools:** VS Code, Android Studio, Android Debug Bridge (ADB), Google Cloud CLI.

## Key Challenges & Learnings

This project was a deep dive into building a production-quality application and involved overcoming several real-world challenges:

1.  **Complex Cloud Authentication:** The biggest challenge was integrating with Vertex AI, which requires OAuth 2.0 access tokens, unlike the simpler API Key used by the Gemini API. This required learning to use the `gcloud` CLI to generate temporary development credentials, providing a deep understanding of Google Cloud's multi-layered security and authentication systems.

2.  **Cloud Service Configuration:** Successfully navigated the Google Cloud Console to debug `PERMISSION_DENIED` errors by enabling the correct APIs (Vertex AI) and linking a billing account, which are critical, non-code-related skills for any cloud developer.

3.  **UI Performance Optimization:** Encountered and solved the "Skipped Frames" issue by re-architecting the API call logic. By implementing a loading state (`_isLoading`) that updates the UI *before* the asynchronous network call, the main thread was kept free, resulting in a smooth, responsive user experience without any freezing.

## Setup and Installation

To run this project locally, follow these steps:

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/[YOUR_GITHUB_USERNAME]/nova_ai.git
    cd nova_ai
    ```

2.  **Install Flutter dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Configure Credentials (Crucial Step):**
    This project requires credentials for Google Cloud services.
    
    - **Gemini API Key:**
      - In the `lib/` folder, create a file named `secrets.dart`.
      - Add your Gemini API key to this file:
        ```dart
        // lib/secrets.dart
        const geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';
        ```

    - **Vertex AI Access Token (For Development):**
      - Make sure you have the [Google Cloud CLI](https://cloud.google.com/sdk/docs/install) installed.
      - Authenticate with your Google account and provide all the access:
        ```bash
        gcloud auth application-default login
        ```
      - Print your temporary access token:
        ```bash
        gcloud auth application-default print-access-token
        ```
      - Copy the entire token string.
      - In `lib/service.dart`, paste this token into the `tempAccessToken` variable.
      - **NOTE:** This token expires after about an hour and needs to be regenerated for development.

4.  **Update Project ID:**
    - In `lib/service.dart`, find the `_projectId` variable and replace the placeholder with your actual Google Cloud Project ID.

5.  **Run the application:**
    ```bash
    flutter run
    ```

## License

This project is licensed under the MIT License - see the `LICENSE` file for details.

## Contact

Debangshu Mounas - debangshumounas.dev@gmail.com

Project Link: https://github.com/DMounas/nova_ai