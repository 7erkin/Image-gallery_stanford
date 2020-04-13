//
//  GalleryFooterView.swift
//  Image-gallery_stanford
//
//  Created by Олег Черных on 12/04/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit

protocol SortImageDelegate: class {}

@IBDesignable
class SortImageView: UISegmentedControl {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    weak var delegate: SortImageDelegate?
    
    private func setup() {
        insertSegment(withTitle: "By rating", at: 0, animated: false)
        selectedSegmentIndex = 0
        insertSegment(withTitle: "By date", at: 1, animated: false)
    }
}

protocol ButtonPanelDelegate: class {
    func onCancelButtonTapped()
    func onDeleteButtonTapped()
}

@IBDesignable
class ButtonPanelView: UIStackView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    weak var delegate: ButtonPanelDelegate?
    
    private var deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle("Delete", for: .normal)
        button.backgroundColor = .systemRed
        button.addTarget(self, action: #selector(onDeleteButtonTapped), for: UIControl.Event.touchUpInside)
        return button
    }()
    
    @objc
    private func onDeleteButtonTapped() {
        delegate?.onDeleteButtonTapped()
    }
    
    @objc
    private func onCancelButtonTapped() {
        delegate?.onCancelButtonTapped()
    }

    private var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(onCancelButtonTapped), for: UIControl.Event.touchUpInside)
        return button
    }()

    private func setup() {
        axis = .horizontal
        distribution = .fillEqually
        addArrangedSubview(deleteButton)
        addArrangedSubview(cancelButton)
        spacing = 5.0
    }
}

protocol GalleryFooterDelegate: SortImageDelegate, ButtonPanelDelegate {}

@IBDesignable
class GalleryFooterView: UICollectionReusableView {
    static let reuseIdentifier = "\(GalleryFooterView.self)"
    
    weak var delegate: GalleryFooterDelegate? { didSet { self.setupDelegate() } }
    
    private lazy var sortImageView: SortImageView = {
        let view = SortImageView(frame: bounds)
        return view
    }()
    
    private lazy var buttonPanelView: ButtonPanelView = {
        let view = ButtonPanelView(frame: frame)
        return view
    }()
    
    @IBInspectable
    var isImageManipulationModeOn: Bool = false {
        didSet {
            UIView.transition(
                from: self.isImageManipulationModeOn ? self.buttonPanelView : self.sortImageView,
                to: self.isImageManipulationModeOn ? self.sortImageView : self.buttonPanelView,
                duration: 0.3,
                options: [.transitionFlipFromTop],
                completion: nil
            )
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        setupDelegate()
        sortImageView.frame = bounds
        buttonPanelView.frame = bounds
        addSubview(sortImageView)
    }
    
    private func setupDelegate() {
        if superview == nil { return }
        sortImageView.delegate = delegate
        buttonPanelView.delegate = delegate
    }
}
