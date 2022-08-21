//
//  AppSettingsView.swift
//  PlayCover
//
//  Created by Isaac Marovitz on 14/08/2022.
//

import SwiftUI

struct AppSettingsView: View {
    @Environment(\.dismiss) var dismiss

    @ObservedObject var viewModel: AppSettingsVM

    @State var resetCompletedAlert: Bool = false

    var body: some View {
        VStack {
            HStack {
                if let img = viewModel.app.icon {
                    Image(nsImage: img).resizable()
                        .frame(width: 33, height: 33)
                        .cornerRadius(10)
                        .shadow(radius: 1)
                }
                Text("\(viewModel.app.name) " + NSLocalizedString("settings.title", comment: ""))
                    .font(.title2).bold()
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            TabView {
                KeymappingView(settings: $viewModel.settings)
                    .tabItem {
                        Text("settings.tab.km")
                    }
                GraphicsView(settings: $viewModel.settings)
                    .tabItem {
                        Text("settings.tab.graphics")
                    }
                JBBypassView(settings: $viewModel.settings)
                    .tabItem {
                        Text("settings.tab.jbBypass")
                    }
                InfoView(info: viewModel.app.info)
                    .tabItem {
                        Text("settings.tab.info")
                    }
            }
            .frame(minWidth: 450, minHeight: 200)
            HStack {
                Spacer()
                Button("settings.reset") {
                    resetCompletedAlert.toggle()
                    viewModel.app.settings.reset()
                    dismiss()
                }
                Button("button.OK") {
                    dismiss()
                }
                .tint(.accentColor)
                .keyboardShortcut(.defaultAction)
            }
        }
        .onChange(of: resetCompletedAlert) { _ in
            ToastVM.shared.showToast(toastType: .notice,
                toastDetails: NSLocalizedString("settings.resetCompleted", comment: ""))
        }
        .padding()
    }
}

struct KeymappingView: View {
    @Binding var settings: AppSettings

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Toggle("settings.toggle.km", isOn: $settings.keymapping)
                        .help("settings.toggle.km.help")
                    Toggle("settings.toggle.mm", isOn: $settings.mouseMapping)
                    Spacer()
                }
                HStack {
                    Slider(value: $settings.sensitivity, in: 0...100, label: {
                        Text(NSLocalizedString("settings.slider.mouseSensitivity", comment: "")
                             + String(format: "%.f", settings.sensitivity))
                    })
                    .frame(maxWidth: 400)
                    Spacer()
                }
                Spacer()
            }
            .padding()
        }
    }
}

struct GraphicsView: View {
    @Binding var settings: AppSettings

    // Default resolution at 1920x1080
    @State var resolution: Int = 2

    // Default aspect ratio at 16:9
    @State var aspectRatio: Int = 1
    
    @State var customWidth: Int = 1920
    @State var customHeight: Int = 1080

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Toggle("settings.toggle.disableDisplaySleep", isOn: $settings.disableTimeout)
                    Spacer()
                }.padding(.bottom)
                HStack {
                    Picker("settings.picker.iosDevice", selection: $settings.iosDeviceModel) {
                        Text("iPad Pro (12.9-inch) (1st gen) | A9X | 4GB").tag("iPad6,7")
                        Text("iPad Pro (12.9-inch) (3rd gen) | A12Z | 4GB").tag("iPad8,6")
                        Text("iPad Pro (12.9-inch) (5th gen) | M1 | 8GB").tag("iPad13,8")
                    }
                    .frame(maxWidth: 300)
                    Spacer()
                }
                HStack {
                    Picker("settings.picker.adaptiveRes", selection: $resolution) {
                        Text("settings.picker.adaptiveRes.0").tag(0)
                        Text("settings.picker.adaptiveRes.1").tag(1)
                        Text("1080p").tag(2)
                        Text("1440p").tag(3)
                        Text("4K").tag(4)
                        Text("Custom").tag(5)
                    }
                    .fixedSize()
                    .frame(alignment: .leading)
                    .help("settings.picker.adaptiveRes.help")
                    Spacer()
                }
                HStack {
                    if resolution == 5 {
                        Stepper {
                            Text("Width: 1920")
                        } onIncrement: {

                        } onDecrement: {

                        }
                        Stepper {
                            Text("Height: 1080")
                        } onIncrement: {

                        } onDecrement: {

                        }
                    } else if resolution >= 2 && resolution <= 4 {
                        Picker("Aspect Ratio:", selection: $aspectRatio) {
                            Text("4:3").tag(0)
                            Text("16:9").tag(1)
                            Text("16:10").tag(2)
                        }
                        .pickerStyle(.radioGroup)
                        .horizontalRadioGroupLayout()
                    }
                    Spacer()
                }
                HStack {
                    Picker("settings.picker.refreshRate", selection: $settings.refreshRate) {
                        Text("60 Hz").tag(60)
                        Text("120 Hz").tag(120)
                    }
                    .pickerStyle(.segmented)
                    .fixedSize()
                    .frame(alignment: .leading)
                    Spacer()
                }
                Spacer()
            }
            .padding()
            .onChange(of: resolution) { _ in
                setResolution()
            }
            .onChange(of: aspectRatio) { _ in
                setResolution()
            }
        }
    }
    
    func setResolution() -> Void {
        var width: Int
        var height: Int

        switch resolution {
        // Adaptive resolution = Auto
        case 1:
            width = Int(NSScreen.main?.visibleFrame.width ?? 1920)
            height = Int(NSScreen.main?.visibleFrame.width ?? 1080)
        // Adaptive resolution = 1080p
        case 2:
            height = 1080
            width = getWidthFromAspectRatio(height)
        // Adaptive resolution = 1440p
        case 3:
            height = 1440
            width = getWidthFromAspectRatio(height)
        // Adaptive resolution = 4K
        case 4:
            height = 2160
            width = getWidthFromAspectRatio(height)
        // Adaptive resolution = Custom
        case 5:
            width = customWidth
            height = customHeight
        // Adaptive resolution = Off
        default:
            width = 1920
            height = 1080
        }

        settings.windowWidth = width
        settings.windowHeight = height
    }
    
    func getWidthFromAspectRatio(_ height: Int) -> Int {
        var widthRatio: Int
        var heightRatio: Int

        switch aspectRatio {
        case 0:
            widthRatio = 4
            heightRatio = 3
        case 1:
            widthRatio = 16
            heightRatio = 9
        case 2:
            widthRatio = 16
            heightRatio = 10
        default:
            widthRatio = 16
            heightRatio = 9
        }
        return (height / heightRatio) * widthRatio
    }
}

struct JBBypassView: View {
    @Binding var settings: AppSettings

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Toggle("settings.toggle.jbBypass", isOn: $settings.bypass)
                    Spacer()
                }
            }
            .padding()
        }
    }
}

struct InfoView: View {
    @State var info: AppInfo

    var body: some View {
        List {
            HStack {
                Text("Display name:")
                Spacer()
                Text("\(info.displayName)")
            }
            HStack {
                Text("Bundle name:")
                Spacer()
                Text("\(info.bundleName)")
            }
            HStack {
                Text("Bundle identifier:")
                Spacer()
                Text("\(info.bundleIdentifier)")
            }
            HStack {
                Text("Bundle version:")
                Spacer()
                Text("\(info.bundleVersion)")
            }
            HStack {
                Text("Executable name:")
                Spacer()
                Text("\(info.executableName)")
            }
            HStack {
                Text("Minimum OS version:")
                Spacer()
                Text("\(info.minimumOSVersion)")
            }
            HStack {
                Text("URL:")
                Spacer()
                Text("\(info.url)")
            }
            HStack {
                Text("Is Game:")
                Spacer()
                Text("\(info.isGame ? "Yes" : "No")")
            }
        }
        .listStyle(.bordered(alternatesRowBackgrounds: true))
        .padding()
    }
}
