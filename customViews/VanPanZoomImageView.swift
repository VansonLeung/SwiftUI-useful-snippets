//
//  VanPanZoomImageView.swift
//  hkstp oneapp testing
//
//  Created by van on 18/7/2022.
//
import UIKit
import SDWebImage
import SwiftUI




struct VanPanZoomImageViewSwiftUI : UIViewRepresentable {

    var imageUrl: String
    var onZoomChange: ((_ scrollView : UIScrollView) -> Void)?

    func makeUIView(context: Context) -> VanPanZoomImageView {
        let iv = VanPanZoomImageView(frame: .zero)
        iv.imageName = imageUrl
        return iv
    }

    func updateUIView(_ uiView: VanPanZoomImageView, context: Context) {
        context.coordinator.update(uiView: uiView, onZoomChange: onZoomChange)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject {
        
        func update(
            uiView: VanPanZoomImageView,
            onZoomChange: ((_ scrollView : UIScrollView) -> Void)?
        )
        {
            uiView.onZoomChange = { sc in
                if let onZoomChange = onZoomChange {
                    onZoomChange(sc)
                }
            }
        }
    }
}




class VanPanZoomImageView: UIScrollView {
    
    var onZoomChange: ((_ scrollView : UIScrollView) -> Void)?
    
    var lcs : [NSLayoutConstraint]? = nil
    
    func makeLcs1() {
        if let lcs = lcs {
            NSLayoutConstraint.deactivate(lcs)
        }
        
        lcs = [
//            imageView.widthAnchor.constraint(equalTo: widthAnchor),
//            imageView.heightAnchor.constraint(equalTo: heightAnchor),
//            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
//            imageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]
        
        if let lcs = lcs {
            NSLayoutConstraint.activate(lcs)
        }
    }
    
    func makeLcs2(imageSize: CGSize) {
        var cellWidth = self.frame.width
        var cellHeight = self.frame.height
        var cellImageWidth = imageSize.width
        var cellImageHeight = imageSize.height
        var cellRevisedWidth = self.frame.width
        var cellRevisedHeight = self.frame.height

        let whRatio = cellWidth / cellHeight   // if vertical : 0.X
        let whRatio_img = cellImageWidth / cellImageHeight  // if horizontal :  1.X
        if whRatio_img > whRatio {
            // image is more horizontal than screen
            //
            
            cellRevisedHeight = cellImageHeight / cellImageWidth * cellWidth
        }
        if whRatio_img < whRatio {
            // image is more horizontal than screen
            //
            
            cellRevisedWidth = cellImageWidth / cellImageHeight * cellHeight
        }
        
//        self.imageView.transform = CGAffineTransform.init(translationX: -(cellRevisedWidth - cellWidth) / 2, y: -(cellRevisedHeight - cellHeight) / 2)
//        self.contentSize = CGSize(width: cellRevisedWidth, height: cellRevisedHeight)
//        print(cellRevisedWidth, cellRevisedHeight)
//
        var _lcs = [
            imageView.widthAnchor.constraint(equalToConstant: cellRevisedWidth),
            imageView.heightAnchor.constraint(equalToConstant: cellRevisedHeight)
        ]
            
        NSLayoutConstraint.activate(_lcs)

        imageView.alpha = 0
        self.zoomScale = 0.99
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.zoomScale = 1
            self.updateContentInset()
            self.imageView.alpha = 1
        }
    }

    var imageName: String? {
        didSet {
            guard let imageName = imageName else {
                return
            }
            if imageUrlName != imageName {
                imageUrlName = imageName
                if let url = URL.init(string: imageName.asPercentEncoded())
                {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                        self.imageView.backgroundColor = .yellow
                        self.imageView.sd_setImage(with: url) { image, err, cacheType, url in
                            if let size = image?.size
                            {
                                self.makeLcs2(imageSize: size)
                            }
                        }
                    }
                }
            }
        }
    }
    
    var imageUrlName: String?
    
    private let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    convenience init(named: String) {
        self.init(frame: .zero)
        self.imageName = named
    }

    private func commonInit() {
        // Setup image view
        backgroundColor = .black
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        makeLcs1()

        // Setup scroll view
        minimumZoomScale = 1
        maximumZoomScale = 3
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        delegate = self
        
        
        // Setup tap gesture
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTapRecognizer)
    }

    @objc private func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        if zoomScale == 1 {
            setZoomScale(2, animated: true)
        } else {
            setZoomScale(1, animated: true)
        }
    }
    
    
    
    
    override var bounds: CGRect {
        didSet { updateContentInset() }
    }

    override var contentSize: CGSize {
        didSet { updateContentInset() }
    }

    private func updateContentInset() {
        var top = CGFloat(0)
        var left = CGFloat(0)
        if contentSize.width < bounds.width {
            left = (bounds.width - contentSize.width) / 2
        }
        if contentSize.height < bounds.height {
            top = (bounds.height - contentSize.height) / 2
        }
        contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
        print(contentInset)
    }
    
    
    
}

extension VanPanZoomImageView: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        print(scrollView.zoomScale)
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
        
        if let onZoomChange = onZoomChange {
            onZoomChange(self)
        }
    }
    
}
