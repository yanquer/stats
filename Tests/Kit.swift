//
//  Kit.swift
//  Tests
//
//  Created by Serhiy Mytrovtsiy on 04/07/2026.
//  Using Swift 6.0.
//  Running on macOS 26.5.
//
//  Copyright © 2026 Serhiy Mytrovtsiy. All rights reserved.
//

import XCTest
@testable import Kit

class KitTests: XCTestCase {
    func testIsNewestVersion_release() throws {
        XCTAssertFalse(isNewestVersion(currentVersion: "v2.11.0", latestVersion: "v2.11.0"))
        XCTAssertTrue(isNewestVersion(currentVersion: "v2.11.0", latestVersion: "v2.11.1"))
        XCTAssertFalse(isNewestVersion(currentVersion: "v2.11.1", latestVersion: "v2.11.0"))
        XCTAssertTrue(isNewestVersion(currentVersion: "v2.11.0", latestVersion: "v2.12.0"))
        XCTAssertFalse(isNewestVersion(currentVersion: "v2.12.0", latestVersion: "v2.11.5"))
        XCTAssertTrue(isNewestVersion(currentVersion: "v2.11.0", latestVersion: "v3.0.0"))
        XCTAssertFalse(isNewestVersion(currentVersion: "v3.0.0", latestVersion: "v2.99.99"))
    }
    
    func testIsNewestVersion_beta() throws {
        XCTAssertFalse(isNewestVersion(currentVersion: "v2.11.0-beta1", latestVersion: "v2.11.0-beta1"))
        XCTAssertFalse(isNewestVersion(currentVersion: "v2.11.0-beta2", latestVersion: "v2.11.0-beta1"))
        XCTAssertTrue(isNewestVersion(currentVersion: "v2.11.0-beta1", latestVersion: "v2.11.0-beta2"))
        XCTAssertTrue(isNewestVersion(currentVersion: "v2.11.0-beta1", latestVersion: "v2.11.0"))
        XCTAssertFalse(isNewestVersion(currentVersion: "v2.11.0-beta1", latestVersion: "v2.10.9"))
        XCTAssertFalse(isNewestVersion(currentVersion: "v2.11.0", latestVersion: "v2.11.1-beta1"))
        XCTAssertTrue(isNewestVersion(currentVersion: "v2.11.0-beta1", latestVersion: "v2.11.1-beta1"))
    }
    
    func testIsNewestVersion_malformed() throws {
        XCTAssertFalse(isNewestVersion(currentVersion: "v3", latestVersion: "v3.0.0"))
        XCTAssertTrue(isNewestVersion(currentVersion: "v3", latestVersion: "v3.0.1"))
        XCTAssertFalse(isNewestVersion(currentVersion: "v3.0", latestVersion: "v3.0.0"))
        XCTAssertFalse(isNewestVersion(currentVersion: "", latestVersion: ""))
    }
    
    func testUnitsGetReadableSpeed_byte() throws {
        XCTAssertEqual(Units(bytes: 0).getReadableSpeed(base: .byte), "0 KB/s")
        XCTAssertEqual(Units(bytes: 999).getReadableSpeed(base: .byte), "0 KB/s")
        XCTAssertEqual(Units(bytes: 1_000).getReadableSpeed(base: .byte), "1 KB/s")
        XCTAssertEqual(Units(bytes: 500_000).getReadableSpeed(base: .byte), "500 KB/s")
        XCTAssertEqual(Units(bytes: 2_500_000).getReadableSpeed(base: .byte), "2.5 MB/s")
        XCTAssertEqual(Units(bytes: 150_000_000).getReadableSpeed(base: .byte), "150 MB/s")
        XCTAssertEqual(Units(bytes: 2_000_000_000).getReadableSpeed(base: .byte), "2.0 GB/s")
        XCTAssertEqual(Units(bytes: 2_000_000_000_000).getReadableSpeed(base: .byte), "2.0 TB/s")
        XCTAssertEqual(Units(bytes: -5).getReadableSpeed(base: .byte), "0 KB/s")
    }
    
    func testUnitsGetReadableSpeed_bit() throws {
        XCTAssertEqual(Units(bytes: 100).getReadableSpeed(base: .bit), "0 Kb/s")
        XCTAssertEqual(Units(bytes: 50_000).getReadableSpeed(base: .bit), "400 Kb/s")
        XCTAssertEqual(Units(bytes: 500_000).getReadableSpeed(base: .bit), "4.0 Mb/s")
        XCTAssertEqual(Units(bytes: 200_000_000).getReadableSpeed(base: .bit), "1.6 Gb/s")
        XCTAssertEqual(Units(bytes: 200_000_000_000).getReadableSpeed(base: .bit), "1.6 Tb/s")
    }
    
    func testUnitsGetReadableSpeed_fixedUnit() throws {
        XCTAssertEqual(Units(bytes: 500_000).getReadableSpeed(base: .byte, unit: "KB"), "500 KB/s")
        XCTAssertEqual(Units(bytes: 500_000).getReadableSpeed(base: .byte, unit: "MB"), "0.5 MB/s")
        XCTAssertEqual(Units(bytes: 500_000).getReadableSpeed(base: .bit, unit: "MB"), "4 Mb/s")
    }
}

/// 验证合并模块的紧凑间距、即时刷新和普通模块布局之间的隔离。
class CombinedModulesSpacingTests: XCTestCase {
    private let moduleName: String = "CombinedSpacingTest"
    private var originalCombined: Bool = false
    private var originalSpacing: String = "none"
    private var hadCombined: Bool = false
    private var hadSpacing: Bool = false

    /// 保存测试涉及的偏好，避免运行测试改变已有设置。
    override func setUp() {
        super.setUp()
        self.hadCombined = Store.shared.exist(key: "CombinedModules")
        self.hadSpacing = Store.shared.exist(key: "CombinedModules_spacing")
        self.originalCombined = Store.shared.bool(key: "CombinedModules", defaultValue: false)
        self.originalSpacing = Store.shared.string(key: "CombinedModules_spacing", defaultValue: "none")
        Store.shared.set(key: "CombinedModules", value: true)
    }

    /// 恢复测试前的偏好并清理测试组件的配置。
    override func tearDown() {
        if self.hadCombined {
            Store.shared.set(key: "CombinedModules", value: self.originalCombined)
        } else {
            Store.shared.remove("CombinedModules")
        }
        if self.hadSpacing {
            Store.shared.set(key: "CombinedModules_spacing", value: self.originalSpacing)
        } else {
            Store.shared.remove("CombinedModules_spacing")
        }
        Store.shared.remove("\(self.moduleName)_widget")
        super.tearDown()
    }

    /// 构造实际菜单栏容器和不同宽度的组件，不创建系统状态栏项目。
    private func makeMenuBar(widths: [CGFloat]) -> MenuBar {
        let menuBar = MenuBar(moduleName: self.moduleName)
        let types: [widget_t] = [.mini, .lineChart]
        Store.shared.set(key: "\(self.moduleName)_widget", value: types.prefix(widths.count).map { $0.rawValue }.joined(separator: ","))
        for (index, width) in widths.enumerated() {
            let type = types[index]
            let view = WidgetWrapper(type, title: self.moduleName, frame: NSRect(x: 0, y: 0, width: width, height: 22))
            let widget = SWidget(type, defaultWidget: type, module: self.moduleName, item: view, image: NSImage())
            menuBar.append(widget)
            menuBar.view.addWidget(view)
        }
        menuBar.active = true
        return menuBar
    }

    /// 验证每个负值实时减少实际容器宽度，且组件仍在容器内、彼此不重叠。
    func testNegativeSpacingUpdatesWidthAndPositions() {
        let menuBar = self.makeMenuBar(widths: [30, 40])
        let cases: [(String, CGFloat, CGFloat)] = [("none", 76, 2), ("-1", 75, 1.5), ("-2", 74, 1), ("-3", 73, 0.5), ("-4", 72, 0)]
        for (value, width, padding) in cases {
            Store.shared.set(key: "CombinedModules_spacing", value: value)
            NotificationCenter.default.post(name: .moduleRearrange, object: nil)
            XCTAssertEqual(menuBar.view.frame.width, width, value)
            let frames = menuBar.view.subviews.map { $0.frame }.sorted { $0.minX < $1.minX }
            XCTAssertEqual(frames[0].minX, padding, value)
            XCTAssertEqual(frames[1].minX - frames[0].maxX, 2, value)
            XCTAssertEqual(frames[1].maxX + padding, width, value)
        }
    }

    /// 验证恢复默认、正值和非法设置都恢复原始留白，极小负值不会裁切组件。
    func testSpacingFallbackAndRestoration() {
        let menuBar = self.makeMenuBar(widths: [30])
        for (value, width) in [("-4", CGFloat(30)), ("none", 34), ("8", 34), ("invalid", 34), ("-999", 30)] {
            Store.shared.set(key: "CombinedModules_spacing", value: value)
            NotificationCenter.default.post(name: .moduleRearrange, object: nil)
            XCTAssertEqual(menuBar.view.frame.width, width, value)
            XCTAssertGreaterThanOrEqual(menuBar.view.subviews[0].frame.minX, 0)
            XCTAssertLessThanOrEqual(menuBar.view.subviews[0].frame.maxX, width)
        }
    }

    /// 验证动态组件宽度和空模块会沿用紧凑间距重新计算，避免留下过时宽度。
    func testDynamicWidthAndEmptyModule() {
        let menuBar = self.makeMenuBar(widths: [30])
        Store.shared.set(key: "CombinedModules_spacing", value: "-2")
        NotificationCenter.default.post(name: .moduleRearrange, object: nil)
        menuBar.widgets[0].item.setFrameSize(NSSize(width: 55, height: 22))
        menuBar.widgets[0].sizeCallback?()
        XCTAssertEqual(menuBar.view.frame.width, 57)
        menuBar.widgets[0].isActive = false
        menuBar.view.removeWidget(type: .mini)
        NotificationCenter.default.post(name: .moduleRearrange, object: nil)
        XCTAssertEqual(menuBar.view.frame.width, 0)
    }

    /// 复现网速紧邻 CPU 的实际组件组合，确保最紧凑档仍有可辨识的文字间隔。
    func testCompactNetworkAndCPURemainSeparated() {
        let network = MenuBar(moduleName: "SpacingNetworkTest")
        let cpu = MenuBar(moduleName: "SpacingCPUTest")
        let speed = SpeedWidget(title: "SpacingNetworkTest", config: nil, preview: true)
        let mini = Mini(title: "CPU", config: nil, preview: true)
        let items: [(MenuBar, WidgetWrapper, widget_t, String)] = [
            (network, speed, .speed, "SpacingNetworkTest"),
            (cpu, mini, .mini, "SpacingCPUTest")
        ]
        for (menuBar, view, type, name) in items {
            menuBar.append(SWidget(type, defaultWidget: type, module: name, item: view, image: NSImage()))
            menuBar.view.addWidget(view)
            menuBar.active = true
        }
        for value in ["-1", "-2", "-3", "-4", "-999"] {
            Store.shared.set(key: "CombinedModules_spacing", value: value)
            NotificationCenter.default.post(name: .moduleRearrange, object: nil)
            cpu.view.setFrameOrigin(NSPoint(x: network.view.frame.width, y: 0))
            let speedRight = network.view.frame.minX + speed.frame.maxX
            let cpuLeft = cpu.view.frame.minX + mini.frame.minX
            XCTAssertGreaterThanOrEqual(cpuLeft - speedRight, 2, value)
            XCTAssertLessThan(network.view.frame.width, speed.frame.width + 4, value)
            XCTAssertLessThan(cpu.view.frame.width, mini.frame.width + 4, value)
            if value == "-4" {
                XCTAssertEqual(network.view.frame.width, speed.frame.width + 2)
                XCTAssertEqual(cpu.view.frame.width, mini.frame.width)
                XCTAssertEqual(mini.frame.minX, 0)
            }
        }
    }

    /// 速率组件移到模块中间时使用已有组件间距，移到末尾时才增加右侧保护。
    func testReorderingSpeedWidgetUpdatesTrailingPadding() {
        let name = "SpacingReorderTest"
        Store.shared.set(key: "\(name)_widget", value: "mini,speed")
        defer {
            Store.shared.remove("\(name)_widget")
            Store.shared.remove("\(name)_mini_position")
            Store.shared.remove("\(name)_speed_position")
        }
        let menuBar = MenuBar(moduleName: name)
        let mini = SWidget(.mini, defaultWidget: .mini, module: name,
                           item: Mini(title: "CPU", config: nil, preview: true), image: NSImage())
        let speed = SWidget(.speed, defaultWidget: .speed, module: name,
                            item: SpeedWidget(title: name, config: nil, preview: true), image: NSImage())
        for widget in [mini, speed] {
            menuBar.append(widget)
            menuBar.view.addWidget(widget.item)
        }
        menuBar.active = true
        Store.shared.set(key: "CombinedModules_spacing", value: "-4")
        mini.position = 0
        speed.position = 1
        NotificationCenter.default.post(name: .moduleRearrange, object: nil)
        let contentWidth = mini.item.frame.width + speed.item.frame.width
        XCTAssertEqual(menuBar.view.frame.width, contentWidth + 4)
        mini.position = 1
        speed.position = 0
        NotificationCenter.default.post(name: .widgetRearrange, object: nil, userInfo: ["module": name])
        XCTAssertEqual(menuBar.view.frame.width, contentWidth + 2)
        XCTAssertEqual(mini.item.frame.minX - speed.item.frame.maxX, 2)
    }

    /// 验证关闭合并后恢复普通布局，保留的负值不会改变独立模块留白。
    func testStandaloneLayoutIgnoresCompactSpacing() {
        let menuBar = self.makeMenuBar(widths: [30])
        Store.shared.set(key: "CombinedModules_spacing", value: "-4")
        NotificationCenter.default.post(name: .moduleRearrange, object: nil)
        XCTAssertEqual(menuBar.view.frame.width, 30)
        Store.shared.set(key: "CombinedModules", value: false)
        menuBar.widgets[0].sizeCallback?()
        XCTAssertEqual(menuBar.view.frame.width, 34)
        XCTAssertEqual(menuBar.view.subviews[0].frame.minX, 2)
    }
}
