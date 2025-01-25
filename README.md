# NewsApp

An iOS application written in **Swift** (UIKit), using **MVVM** + **Combine**, which fetches news articles from the [NewsAPI.org](https://newsapi.org/) service.

The app supports:
- **Pagination** (infinite scrolling)
- **Pull-to-refresh**
- **Offline detection** (via [Reachability](https://github.com/ashleymills/Reachability.swift))
- **Skeleton loading** (placeholder shimmer for loading states)
- **Cached images** (via [Kingfisher](https://github.com/onevcat/Kingfisher))
- **Programmatic AutoLayout** (via [SnapKit](https://github.com/SnapKit/SnapKit))

---

## Features

1. **News Listing Screen**
   - Displays a paginated list of news articles (20 per page).
   - **Pull-to-refresh** gesture to reload from the first page.
   - Shows offline/online status and current date in the header.
   - Allows user to **search** custom topics via an alert with a text field.

2. **Article Cell**
   - Displays **title**, **source**, publish date, and **thumbnail** image.
   - Shows **view count** (the number of times a user opened the detail view for that article).

3. **Infinite Scrolling**
   - Loads 20 articles at a time.
   - Automatically fetches more when scrolling near the bottom.
   - Shows **skeleton placeholder cells** while loading new data.

4. **Detail View**
   - Shows **title**, **source**, **publish date**, **description**, and an **image** (if available).
   - Includes a “Read Full Article” button and clickable link to open in an in-app **WebView**.
   - A **share** button (top-right) lets you share the article URL.

5. **Offline Handling**
   - Detects changes in reachability (online/offline).
   - Blocks new fetches if offline and can show a one-time alert.

6. **Caching**
   - Uses **Kingfisher** for image caching.
   - Maintains a local dictionary (and `UserDefaults`) for **view counts**.

---

## Requirements

- **Xcode 14+**
- **Swift 5**
- **iOS 15.0+** deployment target
- Uses **Swift Package Manager** (SPM) for dependencies (SnapKit, Kingfisher, Reachability)

---

## Getting Started

1. **Clone the repository**:

       git clone https://github.com/your-username/NewsApp.git
       cd NewsApp

2. **Open the Xcode project**:
   - Double-click on `NewsApp.xcodeproj` or open it directly via Xcode.
   - Xcode will automatically resolve Swift Package Manager dependencies (SnapKit, Kingfisher, Reachability).

3. **Add your NewsAPI key**:
   - In `NewsAPIService.swift`, there's an `apiKey` string you must provide:

         init(apiKey: String, apiClient: APIClient = DefaultAPIClient()) {
             self.apiKey = apiKey
             self.apiClient = apiClient
         }

   - Pass your API key when creating the `NewsAPIService` instance, for example:

         let newsService = NewsAPIService(apiKey: "YOUR_NEWS_API_KEY")
         let viewModel = NewsViewModel(newsService: newsService)

   - Make sure you have a valid [NewsAPI.org](https://newsapi.org/) key.

4. **Build and run** on an iOS simulator or device (iOS 15+).

---

## Customizing

- **Default Query**: Currently “politics.” You can adjust or store it in the ViewModel.
- **Search**: Tapping the magnifying glass presents an alert for a custom query.
- **Skeleton Cell Count**: Determined by `skeletonCountForThisLoad` in the ViewModel.


