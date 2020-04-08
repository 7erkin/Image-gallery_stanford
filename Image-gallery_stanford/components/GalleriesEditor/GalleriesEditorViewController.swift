//
//  ImageGalleryTableViewController.swift
//  Image-gallery_stanford
//
//  Created by Олег Черных on 15/03/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit

class GalleriesEditorViewController: UITableViewController, EditedTitleSubmitting, GalleriesEditorObserver {
    func notify(with events: [GalleriesEditor.Event]) {
        self.tableView.performBatchUpdates({
            for event in events {
                switch event {
                case .added(let gallerySection, let index):
                    if gallerySection == .actualImageGallery {
                        self.tableView.insertRows(at: [.init(row: index, section: 0)], with: .fade)
                    } else {
                        self.tableView.insertRows(at: [.init(row: index, section: 1)], with: .fade)
                    }
                case .removed(let gallerySection, let index):
                    if gallerySection == .actualImageGallery {
                        self.tableView.deleteRows(at: [.init(row: index, section: 0)], with: .fade)
                    } else {
                        self.tableView.deleteRows(at: [.init(row: index, section: 1)], with: .fade)
                    }
                case .renamed(let gallerySection, let index):
                    let section = gallerySection == GalleriesEditor.GalleryKind.actualImageGallery ? 0 : 1
                    self.tableView.reloadRows(at: [.init(row: index, section: section)], with: .none)
                default: break
                }
            }
        })
    }
    
    private lazy var galleriesEditor: GalleriesEditor = { [unowned self] in
        let editor = GalleriesEditor()
        editor.subscribe(self)
        return editor
    }()
    
    @IBAction func onAddNewImageGallery(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func submit(sender: GalleriesEditorViewCell) {
        let index = tableView.indexPath(for: sender)!
        let gallerySection = index.section == 0 ? GalleriesEditor.GalleryKind.actualImageGallery : .recentlyDeletedImageGallery
        if let title = sender.titleEditor.text {
            //storage.renameGallery(gallerySection: gallerySection, at: index.row, name: title)
            sender.editingEnable = false
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 1 ? "Recently deleted" : nil
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? galleriesEditor.galleries.count : galleriesEditor.recentlyDeletedGalleries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let source = indexPath.section == 0 ? galleriesEditor.galleries : galleriesEditor.recentlyDeletedGalleries
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageGalleryCell", for: indexPath) as! GalleriesEditorViewCell
        cell.title.text = source[indexPath.row].name
        cell.editedTitleSubmittingDelegate = self
        return cell
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        let indexPath = tableView.indexPath(for: sender as! UITableViewCell)
        /* Q: if nil so.. false? */
        return indexPath?.section == 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowImageGallery", sender: tableView.cellForRow(at: indexPath))
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section != 1 { return nil }
        let action = UIContextualAction(
            style: UIContextualAction.Style.normal,
            title: "Recover image gallery") { [weak self] (action, view, completion) in
                self?.galleriesEditor.restoreGallery(at: indexPath.row)
            }
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch indexPath.section {
            case 0:
                if editingStyle == .delete {
                    galleriesEditor.moveToRecentlyDeleted(galleryByIndex: indexPath.row)
                }
            case 1:
                if editingStyle == .delete {
                    galleriesEditor.removeGalleryPermanently(at: indexPath.row)
                }
            default:
                break
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
            case "ShowImageGallery":
                let imageGalleryVC = (segue.destination as? UINavigationController)?.viewControllers.first as! GalleryPresenterViewController
                let indexCell = (view as! UITableView).indexPath(for: sender as! UITableViewCell)!.row
                imageGalleryVC.imageGallery = galleriesEditor.galleries[indexCell]
            default:
                break
        }
    }
}
