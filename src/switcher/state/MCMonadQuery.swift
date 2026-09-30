import Cocoa

/// Talks to MCMonad's query socket to fetch the exact window IDs on the
/// workspace shown on a given screen — a live request/response, not a
/// cached file, so it can never go stale or answer for the wrong screen.
enum MCMonadQuery {
    enum Outcome {
        case notRunning
        case transientFailure
        case success(Set<CGWindowID>)
    }

    private static let socketPath = NSHomeDirectory() + "/.config/mcmonad/query.sock"
    /// This runs on the switcher's synchronous show path, so a stuck or
    /// unresponsive MCMonad must not be able to hang it.
    private static let timeoutMicroseconds: Int32 = 100_000

    static func currentWorkspaceWindowIds(forScreen screen: NSScreen) -> Outcome {
        let fd = socket(AF_UNIX, SOCK_STREAM, 0)
        guard fd >= 0 else { return .notRunning }
        defer { close(fd) }

        var addr = sockaddr_un()
        addr.sun_family = sa_family_t(AF_UNIX)
        addr.sun_len = UInt8(MemoryLayout<sockaddr_un>.size)
        withUnsafeMutablePointer(to: &addr.sun_path) { ptr in
            ptr.withMemoryRebound(to: CChar.self, capacity: 104) { buf in
                _ = strncpy(buf, socketPath, 103)
            }
        }
        let connectResult = withUnsafePointer(to: &addr) { ptr in
            ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockPtr in
                connect(fd, sockPtr, socklen_t(MemoryLayout<sockaddr_un>.size))
            }
        }
        guard connectResult == 0 else { return .notRunning }

        var timeout = timeval(tv_sec: 0, tv_usec: timeoutMicroseconds)
        setsockopt(fd, SOL_SOCKET, SO_SNDTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
        setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))

        guard var payload = try? JSONSerialization.data(withJSONObject: requestBody(for: screen)) else {
            return .transientFailure
        }
        payload.append(0x0A)

        let written = payload.withUnsafeBytes { buf -> Int in
            guard let base = buf.baseAddress else { return -1 }
            return Darwin.write(fd, base, buf.count)
        }
        guard written == payload.count else { return .transientFailure }

        var responseBuf = [UInt8](repeating: 0, count: 65536)
        let n = Darwin.read(fd, &responseBuf, responseBuf.count)
        guard n > 0 else { return .transientFailure }

        guard let obj = try? JSONSerialization.jsonObject(with: Data(responseBuf[0..<n])) as? [String: Any],
              let ids = obj["windowIds"] as? [Int] else {
            return .transientFailure
        }
        return .success(Set(ids.map { CGWindowID($0) }))
    }

    /// MCMonad's screen frames use a top-left origin (AppKit's is
    /// bottom-left), flipped against the primary screen's height, and cover
    /// each screen's `visibleFrame` (usable area, menu bar/Dock excluded).
    private static func requestBody(for screen: NSScreen) -> [String: Any] {
        let primaryHeight = NSScreen.screens.first?.frame.height ?? 0
        let visible = screen.visibleFrame
        let flippedY = primaryHeight - visible.origin.y - visible.height
        return ["screenFrame": ["x": visible.origin.x, "y": flippedY,
                                 "w": visible.width, "h": visible.height]]
    }
}
