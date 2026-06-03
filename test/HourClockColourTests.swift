import XCTest
@testable import HourlyAudioPlayer

final class HourClockColourTests: XCTestCase {

    private var plistURL: URL!

    override func setUp() {
        super.setUp()
        plistURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("HourClockColourTests-\(UUID().uuidString).plist")
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: plistURL)
        super.tearDown()
    }

    func test_givenHourAheadOfCurrent_whenSignedOffset_thenPositive() {
        XCTAssertEqual(HourClockColourGrading.signedHourOffset(hour: 15, currentHour: 14), 1)
    }

    func test_givenHourBehindCurrent_whenSignedOffset_thenNegative() {
        XCTAssertEqual(HourClockColourGrading.signedHourOffset(hour: 13, currentHour: 14), -1)
    }

    func test_givenHourAcrossMidnight_whenSignedOffset_thenUsesShortestPath() {
        XCTAssertEqual(HourClockColourGrading.signedHourOffset(hour: 23, currentHour: 1), -2)
        XCTAssertEqual(HourClockColourGrading.signedHourOffset(hour: 1, currentHour: 23), 2)
    }

    func test_givenCurrentHour_whenColour_thenUsesCurrentRGB() {
        let current = HourRGBColour(red: 0.1, green: 0.2, blue: 0.3)
        let result = HourClockColourGrading.colour(
            forHour: 9,
            currentHour: 9,
            past: HourRGBColour(red: 1, green: 0, blue: 0),
            current: current,
            future: HourRGBColour(red: 0, green: 0, blue: 1)
        )
        XCTAssertEqual(result, current)
    }

    func test_givenFarPastHour_whenColour_thenMatchesPast() {
        let past = HourRGBColour(red: 0.9, green: 0.1, blue: 0.1)
        let result = HourClockColourGrading.colour(
            forHour: 2,
            currentHour: 14,
            past: past,
            current: HourRGBColour(red: 0.5, green: 0.5, blue: 0.5),
            future: HourRGBColour(red: 0.1, green: 0.1, blue: 0.9)
        )
        XCTAssertEqual(result, past)
    }

    func test_givenSavedPlist_whenReloadStore_thenRestoresRGB() {
        let store = HourClockColourStore(plistURL: plistURL)
        store.isEnabled = true
        store.pastColour = HourRGBColour(red: 0.11, green: 0.22, blue: 0.33)
        store.currentHourColour = HourRGBColour(red: 0.44, green: 0.55, blue: 0.66)
        store.futureColour = HourRGBColour(red: 0.77, green: 0.88, blue: 0.99)
        store.save()

        let reloaded = HourClockColourStore(plistURL: plistURL)
        XCTAssertTrue(reloaded.isEnabled)
        XCTAssertEqual(reloaded.pastColour, store.pastColour)
        XCTAssertEqual(reloaded.currentHourColour, store.currentHourColour)
        XCTAssertEqual(reloaded.futureColour, store.futureColour)
    }

    func test_givenDisabledGrading_whenColourForHour_thenNil() {
        let store = HourClockColourStore(plistURL: plistURL)
        store.isEnabled = false
        XCTAssertNil(store.colour(forHour: 0))
    }
}
