import SwiftUI

struct SettingsView: View {
    @AppStorage("moveToTrash") private var moveToTrash = true
    @AppStorage("truncateLongNames") private var truncateLongNames = true
    @AppStorage("sortingOrder") private var sortingOrder = "Alphabetical"
    
    let sortingOptions = ["Alphabetical", "Date Created", "Date Added"]
    
    var body: some View {
        VStack(spacing: 48) {
            Text("Mossy Clean")
                .font(.industrialLargeTitle)
                .foregroundColor(Theme.textColor)
            
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("SAFETY PROTOCOLS")
                        .font(.industrialMono)
                        .foregroundColor(Theme.accentColor)
                    
                    Toggle("Move to Trash (Recommended)", isOn: $moveToTrash)
                        .toggleStyle(SwitchToggleStyle(tint: Theme.accentColor))
                        .font(.industrialHeadline)
                    
                    Text("Mossy will stage files in the bin for easy recovery.")
                        .font(.industrialBody)
                        .foregroundColor(Theme.subtleTextColor)
                }
                
                Divider().background(Theme.subtleTextColor.opacity(0.1))
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("ORGANIZATION ENGINE")
                        .font(.industrialMono)
                        .foregroundColor(Theme.accentColor)
                    
                    Toggle("Truncate Long Original Names", isOn: $truncateLongNames)
                        .toggleStyle(SwitchToggleStyle(tint: Theme.accentColor))
                        .font(.industrialHeadline)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Sorting Order for Renaming")
                            .font(.industrialHeadline)
                        
                        Picker("", selection: $sortingOrder) {
                            ForEach(sortingOptions, id: \.self) { option in
                                Text(option)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
            }
            .padding(40)
            .modifier(Theme.GlassBackground())
            .padding(.horizontal, 48)
            
            Spacer()
            
            HStack {
                Text("Version 1.0.0 PRO")
                    .font(.industrialMono)
                    .foregroundColor(Theme.subtleTextColor)
                Spacer()
                Image(systemName: "leaf.fill")
                    .foregroundColor(Theme.accentColor)
            }
            .padding(24)
        }
        .padding()
        // MeshGradient handled by MainView
    }
}
