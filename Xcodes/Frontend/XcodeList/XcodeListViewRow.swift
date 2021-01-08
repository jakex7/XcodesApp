import SwiftUI
import Version

struct XcodeListViewRow: View {
    @EnvironmentObject var appState: AppState
    let xcode: Xcode
    let selected: Bool
    
    var body: some View {
        HStack {
            appIconView(for: xcode)
            
            VStack(alignment: .leading) {    
                Text(xcode.description)
                    .font(.body)
                
                Text(verbatim: xcode.path ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            selectControl(for: xcode)
                .padding(.trailing, 16)
            installControl(for: xcode)
        }
        .contextMenu {
            switch xcode.installState {
            case .notInstalled:
                InstallButton(xcode: xcode)
            case .installing:
                CancelInstallButton(xcode: xcode)
            case .installed:
                SelectButton(xcode: xcode)
                OpenButton(xcode: xcode)
                RevealButton(xcode: xcode)
                CopyPathButton(xcode: xcode)
                Divider()
                UninstallButton(xcode: xcode)
            }
        }
    }

    @ViewBuilder
    func appIconView(for xcode: Xcode) -> some View {
        if let icon = xcode.icon {
            Image(nsImage: icon)
        } else {
            Color.clear
                .frame(width: 32, height: 32)
                .foregroundColor(.secondary)
        }
    }
    
    @ViewBuilder
    private func selectControl(for xcode: Xcode) -> some View {
        if xcode.installed {
            if xcode.selected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .help("This is the active version")
            } else {
                Button(action: { appState.select(id: xcode.id) }) {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
                .help("Make this the active version")
            }
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func installControl(for xcode: Xcode) -> some View {
        switch xcode.installState {
        case .installed:
            Button("OPEN") { appState.open(id: xcode.id) }
                .buttonStyle(AppStoreButtonStyle(primary: true, highlighted: selected))
                .help("Open this version")
        case .notInstalled:
            Button("INSTALL") { appState.install(id: xcode.id) }
                .buttonStyle(AppStoreButtonStyle(primary: false, highlighted: selected))
                .help("Install this version")
        case let .installing(installationStep):
            InstallationStepView(installationStep: installationStep, highlighted: selected, cancel: { appState.cancelInstall(id: xcode.id) })
        }
    }
}

struct XcodeListViewRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            XcodeListViewRow(
                xcode: Xcode(version: Version("12.3.0")!, installState: .installed, selected: true, path: "/Applications/Xcode-12.3.0.app", icon: nil),
                selected: false
            )
            
            XcodeListViewRow(
                xcode: Xcode(version: Version("12.2.0")!, installState: .notInstalled, selected: false, path: nil, icon: nil),
                selected: false
            )
            
            XcodeListViewRow(
                xcode: Xcode(version: Version("12.1.0")!, installState: .installing(.downloading(progress: configure(Progress(totalUnitCount: 100)) { $0.completedUnitCount = 40 })), selected: false, path: nil, icon: nil),
                selected: false
            )
            
            XcodeListViewRow(
                xcode: Xcode(version: Version("12.0.0")!, installState: .installed, selected: false, path: "/Applications/Xcode-12.3.0.app", icon: nil),
                selected: false
            )
        }
        .environmentObject(AppState())
    }
}
