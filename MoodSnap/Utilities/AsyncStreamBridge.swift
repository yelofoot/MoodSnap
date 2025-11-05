import Foundation

final class AsyncStreamBridge<Element> {
    private var continuation: AsyncStream<Element>.Continuation?
    let stream: AsyncStream<Element>

    init() {
        var cont: AsyncStream<Element>.Continuation!
        self.stream = AsyncStream<Element> { c in cont = c }
        self.continuation = cont
    }

    func yield(_ value: Element) { continuation?.yield(value) }
    func finish() { continuation?.finish() }
}
