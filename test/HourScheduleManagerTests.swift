import XCTest
@testable import HourlyAudioPlayer

final class MockWorkspaceLauncher: WorkspaceLaunching {
    var lastOpenedURL: URL?
    var shouldSucceed = true
    var openCallCount = 0

    func open(_ url: URL) -> Bool {
        openCallCount += 1
        lastOpenedURL = url
        return shouldSucceed
    }
}

final class HourScheduleManagerTests: XCTestCase {

    private var userDefaults: UserDefaults!
    private var suiteName: String!
    private var previousLaunchLimit: Int!

    override func setUp() {
        super.setUp()
        previousLaunchLimit = LaunchScheduleSettings.shared.maxItemsPerHour
        LaunchScheduleSettings.shared.setMaxItemsPerHour(LaunchScheduleSettings.maximumLimit)
        suiteName = "HourScheduleManagerTests.\(UUID().uuidString)"
        userDefaults = UserDefaults(suiteName: suiteName)!
        userDefaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        LaunchScheduleSettings.shared.setMaxItemsPerHour(previousLaunchLimit)
        userDefaults.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    private func makeManager(workspace: WorkspaceLaunching = MockWorkspaceLauncher()) -> HourScheduleManager {
        HourScheduleManager(userDefaults: userDefaults, workspace: workspace)
    }

    func test_givenNoItems_whenExecute_thenReturnsZero() {
        let launcher = MockWorkspaceLauncher()
        let manager = makeManager(workspace: launcher)

        let result = manager.executeScheduledLaunches(for: 9)

        XCTAssertEqual(result.openedCount, 0)
        XCTAssertEqual(launcher.openCallCount, 0)
    }

    func test_givenMultipleItems_whenExecute_thenOpensEachEnabledItem() {
        let launcher = MockWorkspaceLauncher()
        let manager = makeManager(workspace: launcher)
        let fileA = FileManager.default.temporaryDirectory.appendingPathComponent("launch-a.txt")
        let fileB = FileManager.default.temporaryDirectory.appendingPathComponent("launch-b.txt")
        FileManager.default.createFile(atPath: fileA.path, contents: Data("a".utf8))
        FileManager.default.createFile(atPath: fileB.path, contents: Data("b".utf8))

        manager.importScheduledLaunch(from: fileA, for: 3)
        manager.importScheduledLaunch(from: fileB, for: 3)

        let result = manager.executeScheduledLaunches(for: 3)

        XCTAssertEqual(result.openedCount, 2)
        XCTAssertEqual(launcher.openCallCount, 2)
        try? FileManager.default.removeItem(at: fileA)
        try? FileManager.default.removeItem(at: fileB)
    }

    func test_whenClearAllLaunchItems_thenHourIsEmpty() {
        let manager = makeManager()
        let tempFile = FileManager.default.temporaryDirectory.appendingPathComponent("launch-clear.txt")
        FileManager.default.createFile(atPath: tempFile.path, contents: Data())
        manager.importScheduledLaunch(from: tempFile, for: 7)

        manager.clearAllLaunchItems(for: 7)

        XCTAssertTrue(manager.launchItems(for: 7).isEmpty)
        XCTAssertEqual(manager.scheduledLaunchSummary(for: 7), "None")
        try? FileManager.default.removeItem(at: tempFile)
    }

    func test_whenRemoveSingleItem_thenOthersRemain() {
        let manager = makeManager()
        let fileA = FileManager.default.temporaryDirectory.appendingPathComponent("launch-keep.txt")
        let fileB = FileManager.default.temporaryDirectory.appendingPathComponent("launch-drop.txt")
        FileManager.default.createFile(atPath: fileA.path, contents: Data())
        FileManager.default.createFile(atPath: fileB.path, contents: Data())
        manager.importScheduledLaunch(from: fileA, for: 5)
        manager.importScheduledLaunch(from: fileB, for: 5)

        let dropID = manager.launchItems(for: 5).first { $0.displayName.contains("drop") }!.id
        manager.removeLaunchItem(for: 5, itemID: dropID)

        XCTAssertEqual(manager.launchItems(for: 5).count, 1)
        XCTAssertEqual(manager.launchItems(for: 5).first?.displayName, "launch-keep.txt")
        try? FileManager.default.removeItem(at: fileA)
        try? FileManager.default.removeItem(at: fileB)
    }

    func test_givenTestFixtureNames_whenManagerLoads_thenPrunesFromStandardDefaults() {
        let suite = "HourScheduleManagerTests.prune.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)

        let fileA = FileManager.default.temporaryDirectory.appendingPathComponent("launch-a.txt")
        FileManager.default.createFile(atPath: fileA.path, contents: Data("a".utf8))
        let polluter = HourScheduleManager(userDefaults: defaults, workspace: MockWorkspaceLauncher())
        polluter.importScheduledLaunch(from: fileA, for: 3)
        XCTAssertEqual(polluter.launchItems(for: 3).count, 1)

        let cleaned = HourScheduleManager(userDefaults: defaults, workspace: MockWorkspaceLauncher())
        XCTAssertTrue(cleaned.launchItems(for: 3).isEmpty)
        try? FileManager.default.removeItem(at: fileA)
    }

    func test_givenIsolatedDefaults_whenImport_thenDoesNotMutateSharedSchedule() {
        let sharedBefore = HourScheduleManager.shared.launchItems(for: 99).count
        let manager = makeManager()
        let temp = FileManager.default.temporaryDirectory.appendingPathComponent("isolated-\(UUID().uuidString).txt")
        FileManager.default.createFile(atPath: temp.path, contents: Data())
        manager.importScheduledLaunch(from: temp, for: 99)
        XCTAssertEqual(manager.launchItems(for: 99).count, 1)
        XCTAssertEqual(HourScheduleManager.shared.launchItems(for: 99).count, sharedBefore)
        try? FileManager.default.removeItem(at: temp)
    }

    func test_boundaryHourVolumeClamping() {
        XCTAssertEqual(AudioFile.clampVolume(-0.5), 0)
        XCTAssertEqual(AudioFile.clampVolume(1.5), 1)
        XCTAssertEqual(AudioFile.clampVolume(0.5), 0.5, accuracy: 0.001)
    }
}
