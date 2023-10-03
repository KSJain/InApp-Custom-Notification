//
//  UIApplication+Ext.swift
//  InApp Custom Notification
//
//  Created by Kartikeya Saxena Jain on 10/3/23.
//

import SwiftUI

extension UIApplication {
    func inAppNotification<Content: View>(
        adaptForDynamicIsland: Bool = false,
        timeout: CGFloat = 5,
        swpipeToClose: Bool = true,
        @ViewBuilder content: @escaping () -> Content) {
            
            if let activeWindow = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow }) {
                
                let frame = activeWindow.frame
                let safeArea = activeWindow.safeAreaInsets
                
                var tag: Int = 1009
                let isDynamicIsland = adaptForDynamicIsland && safeArea.top >= 51
                
                if let previousTag = UserDefaults.standard.value(forKey: "in_app_notification_tag") as? Int {
                    tag = previousTag + 1
                }
                
                UserDefaults.standard.setValue(tag, forKey: "in_app_notification_tag")
                
                let config = UIHostingConfiguration {
                    AnimatedNotificationView(
                        content: content(),
                        safeAreaInsets: safeArea,
                        tag: tag,
                        adaptForDynamicIsland: isDynamicIsland,
                        timeout: timeout,
                        swipeToClose: swpipeToClose
                    )
                    .frame(width: (frame.width - (isDynamicIsland ? 20 : 30)), height: 120, alignment: .top)
                    .containerShape(.rect)
                }
                
                let view = config.makeContentView()
                view.tag = tag
                view.backgroundColor = .clear
                view.translatesAutoresizingMaskIntoConstraints = false
                
                activeWindow.addSubview(view)
                
                view.centerXAnchor.constraint(equalTo: activeWindow.centerXAnchor).isActive = true
                view.centerYAnchor.constraint(equalTo: activeWindow.centerYAnchor, constant: (-(frame.height - safeArea.top)/2) + (isDynamicIsland ? 11 : safeArea.top)).isActive = true
            }
        }
}


fileprivate struct AnimatedNotificationView<Content: View>: View {
    var content: Content
    var safeAreaInsets: UIEdgeInsets
    var tag: Int
    var adaptForDynamicIsland: Bool
    var timeout: CGFloat
    var swipeToClose: Bool
    
    @State private var animateNotification:Bool = false
    
    var body: some View {
        content
            .blur(radius: animateNotification ? 0 : 10)
            .disabled(!animateNotification)
            .mask {
                if adaptForDynamicIsland {
                    RoundedRectangle(cornerRadius: 50, style: .continuous)
                } else{
                    Rectangle()
                }
            }
            .scaleEffect(adaptForDynamicIsland ? (animateNotification ? 1 : 0.01) : 1,
                         anchor: .init(x: 0.5, y: 0.01))
            .offset(y: offsetY)
            .gesture(DragGesture()
                .onEnded({ value in
                    if -value.translation.height > 50 && swipeToClose {
                        withAnimation(.smooth, completionCriteria: .logicallyComplete, {
                            animateNotification = false
                        }, completion: {
                            removeNotificationViewFromWindow()
                        })
                    }
                }))
            .onAppear(perform: {
                Task {
                    guard !animateNotification else { return }
                    withAnimation(.smooth) {
                        animateNotification = true
                    }
                    
                    try await Task.sleep(for: .seconds(timeout > 1 ? 1 : timeout))
                    
                    guard animateNotification else { return }
                    
                    withAnimation(.smooth, completionCriteria: .logicallyComplete, {
                        animateNotification = false
                    }, completion: {
                        removeNotificationViewFromWindow()
                    })
                }
            })
    }
    
    var offsetY: CGFloat {
        if adaptForDynamicIsland {
            return 0
        }
        
        return animateNotification ? 10 : -(safeAreaInsets.top + 130)
    }
    
    func removeNotificationViewFromWindow(){
        if let activeWindow = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow }) {
            if let view = activeWindow.viewWithTag(tag) {
                view.removeFromSuperview()
                print("Removed view with tag \(tag)")
            }
        }
    }
}


#Preview {
    ContentView()
}
