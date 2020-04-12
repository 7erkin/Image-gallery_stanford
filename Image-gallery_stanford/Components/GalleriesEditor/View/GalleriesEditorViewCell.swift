//
//  ImageGalleryTableViewCell.swift
//  Image-gallery_stanford
//
//  Created by Олег Черных on 21/03/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit

protocol EditedTitleSubmitting: class {
    func submitEditedTitle(sender: GalleriesEditorViewCell)
}

class GalleriesEditorViewCell: UITableViewCell, UITextFieldDelegate, UITextInputTraits {
    @IBOutlet var titleEditor: UITextField!
    @IBOutlet var title: UILabel!
    @IBOutlet var editButton: UIButton!
    @IBOutlet var applyChangesButton: UIButton! {
        didSet {
            self.applyChangesButton.addTarget(self, action: #selector(onSubmitChanges), for: UIControl.Event.touchUpInside)
        }
    }
    
    private var editImageConfiguration: UIImage.Configuration = UIImage.SymbolConfiguration(pointSize: 21, weight: UIImage.SymbolWeight.regular, scale: UIImage.SymbolScale.large)
    
    private lazy var beginEditImage: UIImage = { [unowned self] in
        return UIImage(systemName: "pencil.circle", withConfiguration: self.editImageConfiguration)!
    }()
    
    private lazy var cancelEditImage: UIImage = { [unowned self] in
        return UIImage(systemName: "clear", withConfiguration: self.editImageConfiguration)!
    }()
    
    @IBAction func onEditButtonTapped(_ sender: Any) {
        isEditingActive = !isEditingActive
    }
    
    weak var editedTitleSubmittingDelegate: EditedTitleSubmitting?
    
    var isEditingActive: Bool! {
        didSet {
            update()
        }
    }
    
    @objc
    func onSubmitChanges() {
        editedTitleSubmittingDelegate?.submitEditedTitle(sender: self)
    }
    
    @objc
    func onCancel() {
        isEditingActive = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        isEditingActive = false
    }
    
    private func setup() {
        titleEditor.font = title.font
        isEditingActive = false
    }
    
    private func update() {
        titleEditor.isHidden = !isEditingActive
        if !titleEditor.isHidden {
            titleEditor.text = title.text
            titleEditor.becomeFirstResponder()
        } else {
            titleEditor.resignFirstResponder()
        }
        title.isHidden = isEditingActive
        let editingButtonImage = self.isEditingActive ? cancelEditImage : beginEditImage
        self.editButton.setImage(editingButtonImage, for: UIControl.State.normal)
        applyChangesButton.isHidden = !isEditingActive
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
}
