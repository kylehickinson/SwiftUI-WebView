import SwiftUI
import Combine
import WebKit

public class WebViewStore: BindableObject {
  public let webView: WKWebView
  public let didChange = PassthroughSubject<Void, Never>()
  
  public init(webView: WKWebView = WKWebView()) {
    self.webView = webView
    
    func subscriber<Value>(for keyPath: KeyPath<WKWebView, Value>) -> AnyCancellable {
      return AnyCancellable(webView.publisher(for: keyPath).sink { _ in self.didChange.send() })
    }
    // Setup observers for all KVO compliant properties
    observers = [
      subscriber(for: \.title),
      subscriber(for: \.url),
      subscriber(for: \.isLoading),
      subscriber(for: \.estimatedProgress),
      subscriber(for: \.hasOnlySecureContent),
      subscriber(for: \.serverTrust),
      subscriber(for: \.canGoBack),
      subscriber(for: \.canGoForward)
    ]
  }
  
  private var observers: [AnyCancellable] = []
  
  deinit {
    observers.forEach {
      // Not even sure if this is required?
      // Probably wont be needed in future betas?
      $0.cancel()
    }
  }
}

/// A container for using a WKWebView in SwiftUI
public struct WebView: View, UIViewRepresentable {
  /// The WKWebView to display
  public let webView: WKWebView
  
  public typealias UIViewType = UIViewContainerView<WKWebView>
  
  public init(webView: WKWebView) {
    self.webView = webView
  }
  
  public func makeUIView(context: UIViewRepresentableContext<WebView>) -> WebView.UIViewType {
    return UIViewContainerView()
  }
  
  public func updateUIView(_ uiView: WebView.UIViewType, context: UIViewRepresentableContext<WebView>) {
    // If its the same content view we don't need to update.
    if uiView.contentView !== webView {
      uiView.contentView = webView
    }
  }
}

/// A UIView which simply adds some view to its view hierarchy
public class UIViewContainerView<ContentView: UIView>: UIView {
  var contentView: ContentView? {
    willSet {
      contentView?.removeFromSuperview()
    }
    didSet {
      if let contentView = contentView {
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
          contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
          contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
          contentView.topAnchor.constraint(equalTo: topAnchor),
          contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
      }
    }
  }
}
