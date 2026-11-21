import SwiftUI
import UniformTypeIdentifiers

@main
enum Entry {
    static func main() {
        MyApp.main()
    }
}

struct NewApp: App {
    var body: some Scene {
        DocumentGroup { (document: NoteDocument) in
            SplitContent(text: document.text)
        } makeDocument: { _, _ in
            NoteDocument()
        }
    }
}

@Observable
final class NoteDocument: Document {
    static let readableContentTypes: [UTType] = [.plainText]

    var text = "Hello"

    nonisolated func reader(configuration: sending ReadConfiguration) -> sending FileWrapperDocumentReader<String> {
        FileWrapperDocumentReader(configuration) { fileWrapper in
            String(decoding: fileWrapper.regularFileContents ?? Data(), as: UTF8.self)
        }
    }

    @MainActor
    func apply(snapshot: sending String, previous: sending String?) async throws {
        text = snapshot
    }

    nonisolated func writer(configuration: sending WriteConfiguration) -> sending FileWrapperDocumentWriter<String> {
        FileWrapperDocumentWriter(configuration) { snapshot, _ in
            FileWrapper(regularFileWithContents: Data(snapshot.utf8))
        }
    }

    @MainActor
    func snapshot(contentType: UTType) async throws -> sending String {
        text
    }
}

struct MyApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: MyDocument()) { file in
            SplitContent(text: file.document.text)
        }
    }
}

struct MyDocument: FileDocument {
    static let readableContentTypes: [UTType] = [.plainText]

    var text = "Hello"

    init() {}

    init(configuration: ReadConfiguration) throws {
        text = String(decoding: configuration.file.regularFileContents ?? Data(), as: UTF8.self)
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: Data(text.utf8))
    }
}

// MARK: - The document view

struct SplitContent: View {
    let text: String

    var body: some View {
        NavigationSplitView {
            List(["One", "Two", "Three"], id: \.self) { item in
                Text(item)
                    .navigationTitle("Sidebar")
            }
        } detail: {
            Text(text)
        }
    }
}
