import Foundation
import WebKit

/// Serves the bundled web app at strikeout://app/… so the calculator never
/// loads the public site. The host "app" is the localStorage origin.
/// Do not rename the scheme or the host: a saved field setup lives there.
final class BundleSchemeHandler: NSObject, WKURLSchemeHandler {
    static let scheme = "strikeout"
    static let origin = "strikeout://app/"

    private let root: URL
    private let lock = NSLock()
    private var stopped = Set<ObjectIdentifier>()

    init(root: URL) {
        self.root = root.standardizedFileURL
        super.init()
    }

    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        let key = ObjectIdentifier(urlSchemeTask)
        guard let url = urlSchemeTask.request.url else {
            fail(urlSchemeTask, key, URLError(.badURL))
            return
        }
        let file = root.appendingPathComponent(relativePath(url)).standardizedFileURL
        guard file.path.hasPrefix(root.path), FileManager.default.fileExists(atPath: file.path) else {
            send(urlSchemeTask, key, status: 404, mime: "text/plain; charset=utf-8", body: Data("Not found".utf8), url: url)
            return
        }
        do {
            let data = try Data(contentsOf: file)
            send(urlSchemeTask, key, status: 200, mime: Self.mime(for: file), body: data, url: url)
        } catch {
            fail(urlSchemeTask, key, error)
        }
    }

    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        lock.lock()
        stopped.insert(ObjectIdentifier(urlSchemeTask))
        lock.unlock()
    }

    private func relativePath(_ url: URL) -> String {
        var path = url.path
        if path.hasPrefix("/") { path.removeFirst() }
        if path.isEmpty || path.hasSuffix("/") { path += "index.html" }
        return path
    }

    private static func mime(for file: URL) -> String {
        switch file.pathExtension.lowercased() {
        case "html": return "text/html; charset=utf-8"
        case "js": return "text/javascript; charset=utf-8"
        case "json": return "application/json"
        case "webmanifest": return "application/manifest+json"
        case "png": return "image/png"
        case "woff2": return "font/woff2"
        case "txt": return "text/plain; charset=utf-8"
        case "css": return "text/css; charset=utf-8"
        default: return "application/octet-stream"
        }
    }

    private func isStopped(_ key: ObjectIdentifier) -> Bool {
        lock.lock()
        let value = stopped.contains(key)
        lock.unlock()
        return value
    }

    private func send(_ task: WKURLSchemeTask, _ key: ObjectIdentifier, status: Int, mime: String, body: Data, url: URL) {
        if isStopped(key) { return }
        let headers = [
            "Content-Type": mime,
            "Content-Length": String(body.count),
            "Cache-Control": "no-store"
        ]
        guard let response = HTTPURLResponse(url: url, statusCode: status, httpVersion: "HTTP/1.1", headerFields: headers) else {
            fail(task, key, URLError(.badServerResponse))
            return
        }
        if isStopped(key) { return }
        task.didReceive(response)
        if isStopped(key) { return }
        task.didReceive(body)
        if isStopped(key) { return }
        task.didFinish()
    }

    private func fail(_ task: WKURLSchemeTask, _ key: ObjectIdentifier, _ error: Error) {
        if isStopped(key) { return }
        task.didFailWithError(error)
    }
}
