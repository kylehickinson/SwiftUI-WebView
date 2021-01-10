# WebView

A SwiftUI component `View` that contains a `WKWebView` 

Since `WKWebView` handles a lot of its own state, navigation stack, etc, it's almost easier to treat it as a mutable data model. You can set it up prior to how you need it, and then simply use its data within your SwiftUI View's.

Simply spin up a `WebViewStore` (optionally with your own `WKWebView`) and use that to access the `WKWebView` itself as if it was a data model.

Example usage:

```swift
import SwiftUI
import WebView

struct ContentView: View {
  @StateObject var webViewStore = WebViewStore()
  
  var body: some View {
    NavigationView {
      WebView(webView: webViewStore.webView)
        .navigationBarTitle(Text(verbatim: webViewStore.title ?? ""), displayMode: .inline)
        .navigationBarItems(trailing: HStack {
          Button(action: goBack) {
            Image(systemName: "chevron.left")
              .imageScale(.large)
              .aspectRatio(contentMode: .fit)
              .frame(width: 32, height: 32)
          }.disabled(!webViewStore.canGoBack)
          Button(action: goForward) {
            Image(systemName: "chevron.right")
              .imageScale(.large)
              .aspectRatio(contentMode: .fit)
              .frame(width: 32, height: 32)
          }.disabled(!webViewStore.canGoForward)
        })
    }.onAppear {
      self.webViewStore.webView.load(URLRequest(url: URL(string: "https://apple.com")!))
    }
  }
  
  func goBack() {
    webViewStore.webView.goBack()
  }
  
  func goForward() {
    webViewStore.webView.goForward()
  }
}
```
