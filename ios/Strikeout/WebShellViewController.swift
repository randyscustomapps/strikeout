import UIKit
import WebKit
import UniformTypeIdentifiers

/// Offline shell. The calculator is the bundled page. This controller adds the
/// pieces a website cannot do on its own: the system share sheet, the Files
/// picker, keep-awake, haptics, and a status bar that follows day and night.
final class WebShellViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler, UIDocumentPickerDelegate {
    private var webView: WKWebView?
    private var statusStyle: UIStatusBarStyle = .darkContent
    private var pageReady = false
    private var queuedURL: URL?
    private var pickId: Int?
    private let day = UIColor(red: 0xF2 / 255, green: 0xDF / 255, blue: 0xA7 / 255, alpha: 1)

    override var preferredStatusBarStyle: UIStatusBarStyle { statusStyle }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        [.portrait, .landscapeLeft, .landscapeRight]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = day
        guard let root = Bundle.main.resourceURL?.appendingPathComponent("Web", isDirectory: true),
              FileManager.default.fileExists(atPath: root.appendingPathComponent("index.html").path)
        else {
            showMessage("Strikeout Harvest is missing its pages.")
            return
        }
        let config = WKWebViewConfiguration()
        config.setURLSchemeHandler(BundleSchemeHandler(root: root), forURLScheme: BundleSchemeHandler.scheme)
        config.websiteDataStore = .default()
        let pagePrefs = WKWebpagePreferences()
        pagePrefs.allowsContentJavaScript = true
        config.defaultWebpagePreferences = pagePrefs
        config.allowsInlineMediaPlayback = true
        config.dataDetectorTypes = WKDataDetectorTypes()
        let proxy = WeakScriptProxy(self)
        config.userContentController.add(proxy, name: "strikeout")

        let web = WKWebView(frame: view.bounds, configuration: config)
        web.navigationDelegate = self
        web.uiDelegate = self
        web.translatesAutoresizingMaskIntoConstraints = false
        web.isOpaque = false
        web.backgroundColor = day
        web.scrollView.backgroundColor = day
        web.scrollView.contentInsetAdjustmentBehavior = .never
        web.scrollView.automaticallyAdjustsScrollIndicatorInsets = false
        web.allowsBackForwardNavigationGestures = false
        web.allowsLinkPreview = false
        #if DEBUG
        if #available(iOS 16.4, *) { web.isInspectable = true }
        #endif
        view.addSubview(web)
        NSLayoutConstraint.activate([
            web.topAnchor.constraint(equalTo: view.topAnchor),
            web.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            web.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            web.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        webView = web
        guard let start = URL(string: BundleSchemeHandler.origin + "index.html") else { return }
        web.load(URLRequest(url: start))
    }

    func queueImport(_ url: URL) {
        if pageReady { importOpened(url) }
        else { queuedURL = url }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        pageReady = true
        if let url = queuedURL {
            queuedURL = nil
            importOpened(url)
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showMessage("Strikeout Harvest could not open its pages.")
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showMessage("Strikeout Harvest could not open its pages.")
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        let scheme = url.scheme?.lowercased() ?? ""
        if scheme == BundleSchemeHandler.scheme {
            decisionHandler(.allow)
            return
        }
        if scheme == "mailto" || scheme == "tel" {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
            return
        }
        // Not a browser. External pages stay outside the app.
        decisionHandler(.cancel)
    }

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url {
            let scheme = url.scheme?.lowercased() ?? ""
            if scheme == "mailto" || scheme == "tel" {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        return nil
    }

    func webView(_ webView: WKWebView, requestDeviceOrientationAndMotionPermissionFor origin: WKSecurityOrigin, initiatedByFrame frame: WKFrameInfo, decisionHandler: @escaping (WKPermissionDecision) -> Void) {
        // The calculator uses GPS heading. It does not ask for motion.
        decisionHandler(.deny)
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let body = message.body
        DispatchQueue.main.async { [weak self] in
            self?.handle(body)
        }
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            finish(id: pickId, ok: false, text: nil)
            pickId = nil
            return
        }
        let id = pickId
        pickId = nil
        switch readHeaderFile(at: url) {
        case .success(let text):
            finish(id: id, ok: true, text: text)
        case .failure:
            finish(id: id, ok: false, text: nil)
            alert("That file is not a Strikeout header file.")
        }
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        finish(id: pickId, ok: false, text: nil)
        pickId = nil
    }

    private func handle(_ body: Any) {
        guard let msg = body as? [String: Any], let action = msg["action"] as? String else { return }
        let id = (msg["id"] as? NSNumber)?.intValue
        switch action {
        case "haptic":
            let style: UIImpactFeedbackGenerator.FeedbackStyle = (msg["style"] as? String) == "medium" ? .medium : .light
            UIImpactFeedbackGenerator(style: style).impactOccurred()
        case "keepAwake":
            let on = (msg["on"] as? Bool) ?? (msg["on"] as? NSNumber)?.boolValue ?? false
            UIApplication.shared.isIdleTimerDisabled = on
        case "statusBar":
            if let color = msg["color"] as? String { applyChrome(color) }
        case "shareLink":
            guard let id, let urlString = msg["url"] as? String else {
                finish(id: id, ok: false, text: nil)
                return
            }
            if let url = URL(string: urlString) {
                presentShare(items: [url], id: id, cleanup: nil)
            } else {
                presentShare(items: [urlString], id: id, cleanup: nil)
            }
        case "shareFile":
            guard let id, let text = msg["text"] as? String else {
                finish(id: id, ok: false, text: nil)
                return
            }
            shareHeaderFile(text, id: id)
        case "pickHeaderFile":
            pickId = id
            let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.json], asCopy: true)
            picker.delegate = self
            picker.allowsMultipleSelection = false
            present(picker, animated: true)
        default:
            break
        }
    }

    private func shareHeaderFile(_ text: String, id: Int) {
        do {
            let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            let file = dir.appendingPathComponent("strikeout-headers.json")
            try text.write(to: file, atomically: true, encoding: .utf8)
            presentShare(items: [file], id: id, cleanup: dir)
        } catch {
            finish(id: id, ok: false, text: nil)
            alert("Could not prepare the header file.")
        }
    }

    private func presentShare(items: [Any], id: Int, cleanup: URL?) {
        let sheet = UIActivityViewController(activityItems: items, applicationActivities: nil)
        if let pop = sheet.popoverPresentationController {
            pop.sourceView = view
            pop.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY - 20, width: 1, height: 1)
            pop.permittedArrowDirections = []
        }
        sheet.completionWithItemsHandler = { [weak self] _, completed, _, _ in
            DispatchQueue.main.async {
                if let cleanup {
                    try? FileManager.default.removeItem(at: cleanup)
                }
                self?.finish(id: id, ok: completed, text: nil)
            }
        }
        present(sheet, animated: true)
    }

    private func importOpened(_ url: URL) {
        switch readHeaderFile(at: url) {
        case .success(let text):
            guard let literal = jsonStringLiteral(text) else { return }
            webView?.evaluateJavaScript("window.strikeoutNative&&window.strikeoutNative.receiveFile(\(literal))", completionHandler: nil)
        case .failure:
            alert("That file is not a Strikeout header file.")
        }
    }

    private func readHeaderFile(at url: URL) -> Result<String, Error> {
        let scoped = url.startAccessingSecurityScopedResource()
        defer { if scoped { url.stopAccessingSecurityScopedResource() } }
        do {
            let data = try Data(contentsOf: url)
            if data.count > 1_000_000 { return .failure(HeaderFileError.tooBig) }
            guard var text = String(data: data, encoding: .utf8) else { return .failure(HeaderFileError.notHeaders) }
            if text.hasPrefix("\u{FEFF}") { text.removeFirst() }
            guard let raw = text.data(using: .utf8),
                  let obj = try JSONSerialization.jsonObject(with: raw) as? [String: Any],
                  let headers = obj["headers"] as? [Any],
                  !headers.isEmpty
            else { return .failure(HeaderFileError.notHeaders) }
            if let kind = obj["strikeout"] as? String, kind != "headers" {
                return .failure(HeaderFileError.notHeaders)
            }
            return .success(text)
        } catch {
            return .failure(error)
        }
    }

    private func finish(id: Int?, ok: Bool, text: String?) {
        guard let id else { return }
        let value = (ok ? text.flatMap(jsonStringLiteral) : nil) ?? "null"
        let flag = ok ? "true" : "false"
        webView?.evaluateJavaScript("window.strikeoutNative&&window.strikeoutNative._done(\(id), \(flag), \(value))", completionHandler: nil)
    }

    private func jsonStringLiteral(_ text: String) -> String? {
        guard let data = try? JSONEncoder().encode(text) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func applyChrome(_ hex: String) {
        let cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        guard cleaned.count == 6, let value = Int(cleaned, radix: 16) else { return }
        let r = CGFloat((value >> 16) & 0xFF) / 255
        let g = CGFloat((value >> 8) & 0xFF) / 255
        let b = CGFloat(value & 0xFF) / 255
        let color = UIColor(red: r, green: g, blue: b, alpha: 1)
        let luminance = (0.299 * r) + (0.587 * g) + (0.114 * b)
        statusStyle = luminance > 0.6 ? .darkContent : .lightContent
        view.backgroundColor = color
        webView?.backgroundColor = color
        webView?.scrollView.backgroundColor = color
        setNeedsStatusBarAppearanceUpdate()
    }

    private func alert(_ message: String) {
        let alert = UIAlertController(title: "Strikeout Harvest", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func showMessage(_ message: String) {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = message
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = UIColor(red: 0x2A / 255, green: 0x1D / 255, blue: 0x0A / 255, alpha: 1)
        label.font = .preferredFont(forTextStyle: .body)
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

private enum HeaderFileError: Error {
    case notHeaders
    case tooBig
}

final class WeakScriptProxy: NSObject, WKScriptMessageHandler {
    weak var target: WKScriptMessageHandler?
    init(_ target: WKScriptMessageHandler) { self.target = target }
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        target?.userContentController(userContentController, didReceive: message)
    }
}
