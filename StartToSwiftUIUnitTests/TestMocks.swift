//
//  TestMocks.swift
//  StartToSwiftUIUnitTests
//
//  Created by Andrey Efimov on 13.03.2026.
//
import XCTest
import Combine
@testable import StartToSwiftUI

// MARK: - Mock: CloudChangeObserver
/// Событие "хранилище изменилось" отправляется вручную и приходит сразу,
/// без debounce.
final class MockCloudChangeObserver: CloudChangeObserving {
    private let subject = PassthroughSubject<Set<StoreEntity>, Never>()
    var changes: AnyPublisher<Set<StoreEntity>, Never> { subject.eraseToAnyPublisher() }

    func sendChange(_ entities: Set<StoreEntity>) { subject.send(entities) }
}

// MARK: - Mock: StoreHistoryReader
final class MockStoreHistoryReader: StoreHistoryReading {
    var externalChanges: Set<StoreEntity> = []
    func fetchExternalChanges() -> Set<StoreEntity> { externalChanges }
}

// MARK: - Mock: AppSyncStateManager
final class MockAppSyncStateManager: AppSyncStateManagerProtocol {
    var stubbedLastNoticeDate: Date?
    var stubbedFirstLaunchDate: Date?
    var savedLatestNoticeDate: Date?
    var stubbedLastDateOfPostsLoaded: Date?
    var savedLastDateOfPostsLoaded: Date?
    var resetLatestNoticeDateCallCount = 0
    var resetLastDateOfPostsLoadedCallCount = 0
    var cleanupDuplicateAppStatesCallCount = 0

    func getLastNoticeDate() -> Date? { stubbedLastNoticeDate }
    func getAppFirstLaunchDate() -> Date? { stubbedFirstLaunchDate }
    func updateLatestNoticeDate(_ date: Date) { savedLatestNoticeDate = date }
    func resetLatestNoticeDate() {
        resetLatestNoticeDateCallCount += 1
        savedLatestNoticeDate = nil
    }

    func getLastDateOfPostsLoaded() -> Date? { stubbedLastDateOfPostsLoaded }
    func setLastDateOfPostsLoaded(_ date: Date) { savedLastDateOfPostsLoaded = date }
    func resetLastDateOfPostsLoaded() {
        resetLastDateOfPostsLoadedCallCount += 1
        savedLastDateOfPostsLoaded = Date(timeIntervalSince1970: 0)
    }

    func cleanupDuplicateAppStates() {
        cleanupDuplicateAppStatesCallCount += 1
    }
}

// MARK: - Mock: SnippetFavoritesStore
final class MockSnippetFavoritesStore: SnippetFavoritesStoreProtocol {
    var favoriteIDs: Set<String> = []
    var toggledIDs: [String] = []

    func getSnippetFavoriteIDs() -> Set<String> { favoriteIDs }
    func toggleSnippetFavorite(_ id: String) {
        toggledIDs.append(id)
        if favoriteIDs.contains(id) {
            favoriteIDs.remove(id)
        } else {
            favoriteIDs.insert(id)
        }
    }
}
