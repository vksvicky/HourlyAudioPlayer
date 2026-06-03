import XCTest
@testable import HourlyAudioPlayer

final class LaunchScheduleSettingsTests: XCTestCase {

    private var suiteName: String!
    private var userDefaults: UserDefaults!
    private var previousLimit: Int!
    override func setUp() {
        super.setUp()
        previousLimit = LaunchScheduleSettings.shared.maxItemsPerHour
        suiteName = "LaunchScheduleSettingsTests.\(UUID().uuidString)"
        userDefaults = UserDefaults(suiteName: suiteName)!
        userDefaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        LaunchScheduleSettings.shared.setMaxItemsPerHour(previousLimit)
        userDefaults.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    func test_givenNoStoredValue_whenInit_thenDefaultsToOne() {
        let settings = LaunchScheduleSettings(userDefaults: userDefaults)
        XCTAssertEqual(settings.maxItemsPerHour, 1)
    }

    func test_givenMissingPlistKey_whenReadShowLaunchTestUI_thenFalse() {
        let bundle = Bundle(for: LaunchScheduleSettingsTests.self)
        XCTAssertFalse(LaunchScheduleSettings.showLaunchTestControls(from: bundle))
    }

    func test_givenMainBundlePlist_whenReadShowLaunchTestUI_thenMatchesPlistEntry() {
        let controls = LaunchScheduleSettings.showLaunchTestControls(from: .main)
        let raw = Bundle.main.object(forInfoDictionaryKey: LaunchScheduleSettings.showLaunchTestUIInfoKey)
        XCTAssertEqual(controls, LaunchScheduleSettings.parseShowLaunchTestFlag(raw))
    }

    func test_givenStringYES_whenParseShowLaunchTestFlag_thenTrue() {
        XCTAssertTrue(LaunchScheduleSettings.parseShowLaunchTestFlag("YES"))
    }

    func test_givenStringNo_whenParseShowLaunchTestFlag_thenFalse() {
        XCTAssertFalse(LaunchScheduleSettings.parseShowLaunchTestFlag("no"))
    }

    func test_givenValueAboveFive_whenClamp_thenReturnsFive() {
        XCTAssertEqual(LaunchScheduleSettings.clamp(9), 5)
    }

    func test_givenValueBelowZero_whenClamp_thenReturnsZero() {
        XCTAssertEqual(LaunchScheduleSettings.clamp(-2), 0)
    }

    func test_givenTwoItems_whenLimitLoweredToOne_thenTrimsHour() {
        LaunchScheduleSettings.shared.setMaxItemsPerHour(5)
        let manager = HourScheduleManager(userDefaults: userDefaults, workspace: MockWorkspaceLauncher())
        let fileA = FileManager.default.temporaryDirectory.appendingPathComponent("limit-a.txt")
        let fileB = FileManager.default.temporaryDirectory.appendingPathComponent("limit-b.txt")
        FileManager.default.createFile(atPath: fileA.path, contents: Data())
        FileManager.default.createFile(atPath: fileB.path, contents: Data())
        manager.importScheduledLaunch(from: fileA, for: 2)
        manager.importScheduledLaunch(from: fileB, for: 2)
        XCTAssertEqual(manager.launchItems(for: 2).count, 2)

        LaunchScheduleSettings.shared.setMaxItemsPerHour(1)
        manager.applyPerHourLimit()

        XCTAssertEqual(manager.launchItems(for: 2).count, 1)
        try? FileManager.default.removeItem(at: fileA)
        try? FileManager.default.removeItem(at: fileB)
    }

    func test_givenLimitOne_whenImportSecondNewItem_thenRejected() {
        LaunchScheduleSettings.shared.setMaxItemsPerHour(1)
        let manager = HourScheduleManager(userDefaults: userDefaults, workspace: MockWorkspaceLauncher())
        let fileA = FileManager.default.temporaryDirectory.appendingPathComponent("one-a.txt")
        let fileB = FileManager.default.temporaryDirectory.appendingPathComponent("one-b.txt")
        FileManager.default.createFile(atPath: fileA.path, contents: Data())
        FileManager.default.createFile(atPath: fileB.path, contents: Data())
        manager.importScheduledLaunch(from: fileA, for: 8)
        manager.importScheduledLaunch(from: fileB, for: 8)

        XCTAssertEqual(manager.launchItems(for: 8).count, 1)
        XCTAssertEqual(manager.launchItems(for: 8).first?.displayName, "one-a.txt")
        try? FileManager.default.removeItem(at: fileA)
        try? FileManager.default.removeItem(at: fileB)
    }

    func test_givenLimitZero_whenApplyPerHourLimit_thenClearsAllHours() {
        LaunchScheduleSettings.shared.setMaxItemsPerHour(5)
        let manager = HourScheduleManager(userDefaults: userDefaults, workspace: MockWorkspaceLauncher())
        let file = FileManager.default.temporaryDirectory.appendingPathComponent("zero-clear.txt")
        FileManager.default.createFile(atPath: file.path, contents: Data())
        manager.importScheduledLaunch(from: file, for: 6)
        XCTAssertEqual(manager.launchItems(for: 6).count, 1)

        LaunchScheduleSettings.shared.setMaxItemsPerHour(0)
        manager.applyPerHourLimit()

        XCTAssertTrue(manager.launchItems(for: 6).isEmpty)
        XCTAssertFalse(LaunchScheduleSettings.shared.launchesEnabled)
        try? FileManager.default.removeItem(at: file)
    }

    func test_givenOneItemAndLimitOne_whenRemainingSlots_thenZero() {
        LaunchScheduleSettings.shared.setMaxItemsPerHour(1)
        let manager = HourScheduleManager(userDefaults: userDefaults, workspace: MockWorkspaceLauncher())
        let file = FileManager.default.temporaryDirectory.appendingPathComponent("slots.txt")
        FileManager.default.createFile(atPath: file.path, contents: Data())
        manager.importScheduledLaunch(from: file, for: 10)

        XCTAssertEqual(manager.remainingLaunchSlots(for: 10), 0)
        XCTAssertFalse(manager.canAddLaunchItems(for: 10))
        try? FileManager.default.removeItem(at: file)
    }

    func test_givenEmptyHourAndLimitThree_whenRemainingSlots_thenThree() {
        LaunchScheduleSettings.shared.setMaxItemsPerHour(3)
        let manager = HourScheduleManager(userDefaults: userDefaults, workspace: MockWorkspaceLauncher())

        XCTAssertEqual(manager.remainingLaunchSlots(for: 4), 3)
        XCTAssertTrue(manager.canAddLaunchItems(for: 4))
    }
}
