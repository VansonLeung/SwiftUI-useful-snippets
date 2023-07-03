import SwiftUI
import Introspect

private struct PullToRefresh: UIViewRepresentable {
    
    @Binding var isShowing: Bool
    let onRefresh: () -> Bool
    
    public init(
        isShowing: Binding<Bool>,
        onRefresh: @escaping () -> Bool
    ) {
        _isShowing = isShowing
        self.onRefresh = onRefresh
    }
    
    public class Coordinator : NSObject, UITableViewDelegate, UIScrollViewDelegate {
        let onRefresh: () -> Bool
        let isShowing: Binding<Bool>
        
        init(
            onRefresh: @escaping () -> Bool,
            isShowing: Binding<Bool>
        ) {
            self.onRefresh = onRefresh
            self.isShowing = isShowing
        }
        
        @objc
        func onValueChanged(sender: UIRefreshControl?) {
            if !onRefresh() {
                if let sender = sender {
                    sender.endRefreshing()
                }
            }
//            if onRefresh() {
//                isShowing.wrappedValue = true
//            } else {
//                isShowing.wrappedValue = isShowing.wrappedValue
//            }
        }
        
        func scrollViewDidEndDecelerating(_ scrollView : UIScrollView)
        {
//            print("ASDASDAS")
        }
        
    }
    
    public func makeUIView(context: UIViewRepresentableContext<PullToRefresh>) -> UIView {
        let view = UIView(frame: .zero)
        view.isHidden = true
        view.isUserInteractionEnabled = false
        return view
    }
    
    private func tableView(entry: UIView) -> UITableView? {
        
        // Search in ancestors
        if let tableView = Introspect.findAncestor(ofType: UITableView.self, from: entry) {
            return tableView
        }

        guard let viewHost = Introspect.findViewHost(from: entry) else {
            return nil
        }

        // Search in siblings
        return Introspect.previousSibling(containing: UITableView.self, from: viewHost)
    }

    public func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PullToRefresh>) {
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            
            guard let tableView = self.tableView(entry: uiView) else {
                return
            }
            
            if let refreshControl = tableView.refreshControl {
                if self.isShowing {
                    if !refreshControl.isRefreshing {
                        refreshControl.beginRefreshing()
                    }
                } else {
                    if refreshControl.isRefreshing {
                        refreshControl.endRefreshing()
                    }
                }
                return
            }
            
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(context.coordinator, action: #selector(Coordinator.onValueChanged(sender:)), for: .valueChanged)
            tableView.refreshControl = refreshControl
            tableView.delegate = context.coordinator
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(onRefresh: onRefresh, isShowing: $isShowing)
    }
}

extension View {
    public func pullToRefresh(isShowing: Binding<Bool>, onRefresh: @escaping () -> Bool) -> some View {
        return overlay(
            PullToRefresh(isShowing: isShowing, onRefresh: onRefresh)
                .frame(width: 0, height: 0)
        )
    }
}
