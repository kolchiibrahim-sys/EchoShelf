//
//  AuthorDetailViewModel.swift
//  EchoShelf
//
import Foundation

final class AuthorDetailViewModel {

    private let service: AuthorService
    private(set) var author: Author
    private(set) var authorDetail: AuthorDetail?
    private(set) var books: [Audiobook] = []
    private(set) var state: ViewState<Void> = .idle {
        didSet { onStateChanged?(state) }
    }

    var onStateChanged: ((ViewState<Void>) -> Void)?

    init(author: Author, service: AuthorService = .shared) {
        self.author = author
        self.service = service
    }

    func fetchData() {
        state = .loading
        let group = DispatchGroup()

        group.enter()
        service.fetchAuthorDetail(firstName: author.firstName, lastName: author.lastName) { [weak self] detail in
            self?.authorDetail = detail
            group.leave()
        }

        group.enter()
        service.fetchAuthorBooks(firstName: author.firstName, lastName: author.lastName) { [weak self] books in
            self?.books = books
            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            self?.state = .success(())
        }
    }

    var fullName: String {
        let full = "\(author.firstName ?? "") \(author.lastName ?? "")".trimmingCharacters(in: .whitespaces)
        return full.isEmpty ? "Unknown Author" : full
    }
}
