//
//  ImageGalleryTableViewController.swift
//  Image-gallery_stanford
//
//  Created by Олег Черных on 15/03/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit

class GalleriesEditorViewController: UITableViewController, EditedTitleSubmitting, GalleriesEditorObserver {
    private lazy var editor: GalleriesEditor = { [unowned self] in
        let editor = GalleriesEditor()
        editor.subscribe(self)
        return editor
    }()
    
    private weak var currentPresenter: GalleryPresenter!
    
    @IBAction func onAddNewImageGallery(_ sender: Any) {
        editor.createGallery(withName: "New gallery \(editor.galleries.count)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editor.fetchGalleries()
    }
    
    func submitEditedTitle(sender: GalleriesEditorViewCell) {
        if let indexPath = tableView.indexPath(for: sender) {
            let galleries = indexPath.section == 0 ? editor.galleries : editor.recentlyDeletedGalleries
            editor.renameGallery(byGalleryId: galleries[indexPath.row].id, withName: sender.titleEditor.text ?? "")
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
        return section == 0 ? editor.galleries.count : editor.recentlyDeletedGalleries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let source = indexPath.section == 0 ? editor.galleries : editor.recentlyDeletedGalleries
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageGalleryCell", for: indexPath) as! GalleriesEditorViewCell
        cell.title.text = source[indexPath.row].data.name
        cell.editedTitleSubmittingDelegate = self
        return cell
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
        case "ShowImageGallery":
            if
                let cell = sender as? GalleriesEditorViewCell,
                let section = tableView.indexPath(for: cell)?.section {
                return section == 0
            }
        default:
            return false
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if shouldPerformSegue(withIdentifier: "ShowImageGallery", sender: tableView.cellForRow(at: indexPath)) {
            performSegue(withIdentifier: "ShowImageGallery", sender: tableView.cellForRow(at: indexPath))
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section != 1 { return nil }
        let action = UIContextualAction(
            style: UIContextualAction.Style.normal,
            title: "Recover image gallery") { [unowned self] (action, view, completion) in
                self.editor.restoreGallery(byGalleryId: self.editor.recentlyDeletedGalleries[indexPath.row].id)
            }
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch indexPath.section {
            case 0:
                if editingStyle == .delete {
                    editor.deleteGallery(byGalleryId: editor.galleries[indexPath.row].id)
                }
            case 1:
                if editingStyle == .delete {
                    editor.deleteGalleryPermanently(byGalleryId: editor.recentlyDeletedGalleries[indexPath.row].id)
                }
            default:
                break
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
            case "ShowImageGallery":
                let galleryPresenterVC = (segue.destination as? UINavigationController)?.viewControllers.first as! GalleryPresenterViewController
                let indexCell = (view as! UITableView).indexPath(for: sender as! UITableViewCell)!.row
                let presenter = GalleryPresenter()
                presenter.galleryId = editor.galleries[indexCell].id
                currentPresenter = presenter
                galleryPresenterVC.presenter = presenter
            default:
                break
        }
    }
    
    func notify(with events: [GalleriesEditor.Event]) {
        self.tableView.performBatchUpdates({
            for event in events {
                switch event {
                case .galleriesFetched:
                    tableView.reloadData()
                case .galleryCreated(let index):
                    tableView.insertRows(at: [.init(row: index, section: 0)], with: .fade)
                case .galleryDeleted(let fromIndex, let toIndex):
                    tableView.deleteRows(at: [.init(row: fromIndex, section: 0)], with: .fade)
                    tableView.insertRows(at: [.init(row: toIndex, section: 1)], with: .fade)
                    let deletedGalleryId = editor.recentlyDeletedGalleries[toIndex].id
                    if currentPresenter.galleryId == deletedGalleryId {
                    //    do smth to hide image gallery
                    }
                case .galleryDeletedPermanently(let index):
                    tableView.deleteRows(at: [.init(row: index, section: 1)], with: .fade)
                case .galleryRenamed(let galleryKind, let index):
                    let section = galleryKind == .actualImageGallery ? 0 : 1
                    let cell = tableView.cellForRow(at: .init(row: index, section: section)) as! GalleriesEditorViewCell
                    tableView.reloadRows(at: [.init(row: index, section: section)], with: .fade)
                    cell.isEditingActive = false
                case .galleryRestored(let byIndex, let fromIndex):
                    tableView.insertRows(at: [.init(row: byIndex, section: 0)], with: .fade)
                    tableView.deleteRows(at: [.init(row: fromIndex, section: 1)], with: .fade)
                default:
                    fatalError("Unexpected event in function: \(#function) at line: \(#line)")
                }
            }
        })
    }
}
