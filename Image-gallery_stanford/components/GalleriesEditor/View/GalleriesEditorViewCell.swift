//
//  ImageGalleryTableViewCell.swift
//  Image-gallery_stanford
//
//  Created by Олег Черных on 21/03/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit

protocol EditedTitleSubmitting: class {
    func submit(sender: GalleriesEditorViewCell)
}

class GalleriesEditorViewCell: UITableViewCell, UITextFieldDelegate, UITextInputTraits {
    @IBOutlet var titleEditor: UITextField! {
        didSet {
            self.titleEditor.delegate = self
            let item = self.titleEditor.inputAssistantItem
            let barButtonGroup = UIBarButtonItemGroup(barButtonItems: [cancelButton, clearTextFieldButton, submitChangesButton], representativeItem: nil)
            item.trailingBarButtonGroups = [barButtonGroup]
        }
    }
    @IBOutlet var title: UILabel!
    
    private lazy var submitChangesButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "Save"
        button.target = self
        button.action = #selector(onSubmitChanges)
        return button
    }()
    
    private lazy var clearTextFieldButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "Reset"
        button.target = self
        button.action = #selector(onResetTitleEditor)
        return button
    }()
    
    private lazy var cancelButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "Cancel"
        button.target = self
        button.action = #selector(onCancel)
        return button
    }()
    
    weak var editedTitleSubmittingDelegate: EditedTitleSubmitting?
    
    var editingEnable = false {
        didSet {
            updateSubviews()
        }
    }
    
    @objc
    func onSubmitChanges() {
        editedTitleSubmittingDelegate?.submit(sender: self)
    }
    
    @objc
    func onCancel() {
        editingEnable = false
    }
    
    @objc
    func onResetTitleEditor() {
        titleEditor.text = nil
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        editingEnable = false
    }
    
    private func updateSubviews() {
        titleEditor.isHidden = !editingEnable
        if !titleEditor.isHidden {
            titleEditor.text = title.text
            titleEditor.becomeFirstResponder()
        } else {
            titleEditor.resignFirstResponder()
        }
        title.isHidden = editingEnable
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateSubviews()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onEdit(_:)))
        tapGesture.numberOfTapsRequired = 2
        self.addGestureRecognizer(tapGesture)
        titleEditor.font = title.font
    }

    @objc
    func onEdit(_ gesture: UITapGestureRecognizer) {
        editingEnable = true
    }
}
