//
//  FNNewsfeedVC.swift
//  Football News
//
//  Created by Mahnoor Khan on 16/07/2019.
//  Copyright © 2019 Mahnoor Khan. All rights reserved.
//

import UIKit

class FNNewsfeedVC: UIViewController {

    // MARK: Properties and Outlets
    @IBOutlet weak var tableView    :   UITableView!
    var newsfeedVM                  :   FNNewsfeedVM?
    let constants                   :   FNConstants     =   FNConstants()
    
    // MARK: Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        registerNibs()
        initViewModel()
        registerProtocols()
    }
}

// MARK: Registration Functions Extension
extension FNNewsfeedVC {
    /// Function to set the delegate and data source for table view
    func registerProtocols () {
        tableView.delegate      =   self
        tableView.dataSource    =   self
    }
    
    /// Function to register nib files for table view
    func registerNibs() {
        let videoCellNib    =   UINib(nibName: constants.VIDEO_NIB, bundle: nil)
        let factCellNib     =   UINib(nibName: constants.FACT_NIB, bundle: nil)
        let newsCellNib     =   UINib(nibName: constants.NEWS_NIB, bundle: nil)
        
        tableView.register(videoCellNib, forCellReuseIdentifier: constants.VIDEO_IDENTIFIER)
        tableView.register(factCellNib, forCellReuseIdentifier: constants.FACT_IDENTIFIER)
        tableView.register(newsCellNib, forCellReuseIdentifier: constants.NEWS_IDENTIFIER)
    }
    
    /// Function to initialize viewModel
    func initViewModel() {
        newsfeedVM = FNNewsfeedVM()
    }
}

// MARK: Table View Functions Extension
extension FNNewsfeedVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsfeedVM?.itemCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let modelCount = newsfeedVM?.itemCount {
             if indexPath.row == modelCount - 1 {
                insertNewData(indexPath: indexPath)
            }
        }
        guard let feedObject = newsfeedVM?.itemAt(indexPath) else { return UITableViewCell() }
        let cell = getTableCell(feedObject: feedObject, indexPath: indexPath)
        return cell
    }
}

extension FNNewsfeedVC {
    /// Function to return custom/specific cell for  table view
    ///
    /// - Parameters:
    ///   - feedObject: the newsfeed object for the type of cell to return
    ///   - indexPath: index path of the cell
    /// - Returns: table view cell
    func getTableCell(feedObject: NewsFeedObject, indexPath: IndexPath) -> UITableViewCell {
        switch feedObject.type {
        case 0:
            guard let cell  =   tableView.dequeueReusableCell(withIdentifier: constants.VIDEO_IDENTIFIER) as? FNVideoCell else { return UITableViewCell() }
            cell.delegate   =   self
            cell.setTag(buttonTag:  indexPath.row)
            cell.loadVideo(videoID: feedObject.getVideoID())
            return cell
        case 1:
            guard let cell  =   tableView.dequeueReusableCell(withIdentifier: constants.FACT_IDENTIFIER) as? FNFactCell else { return UITableViewCell() }
            cell.delegate   =   self
            cell.setTag(buttonTag:  indexPath.row)
            cell.loadFact(fact: feedObject)
            return cell
        case 2:
            guard let cell  =   tableView.dequeueReusableCell(withIdentifier: constants.NEWS_IDENTIFIER) as? FNNewsCell else { return UITableViewCell() }
            cell.delegate   =    self
            cell.setTag(buttonTag:  indexPath.row)
            cell.loadNews(news: feedObject)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    /// Function to insert new rows in the table view (Pagination)
    ///
    /// - Parameter indexPath: indexPath of the last inflated row
    func insertNewData(indexPath: IndexPath) {
        newsfeedVM?.getMoreItems(onSuccess: { objects in
            guard let fetchedObjects : [NewsFeedObject] = objects else { return }
            self.newsfeedVM?.model?.append(contentsOf: fetchedObjects)
            self.tableView.beginUpdates()
            var currentIndexPath : IndexPath = IndexPath(row: indexPath.row + 1 , section: 0)
            for _ in fetchedObjects {
                self.tableView.insertRows(at: [currentIndexPath], with: .none)
                currentIndexPath = IndexPath(row: currentIndexPath.row + 1 , section: 0)
            }
            self.tableView.endUpdates()
        }, onFailure: { message in
            print(message as Any)
        })
    }
}


// MARK: Share/Watch/Read button Function
extension FNNewsfeedVC: FNButtonAction {
    func onClickWatch(_ tag: Int) {
        guard let item = newsfeedVM?.itemThroughIndex(tag) else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        switch item.type {
        case 0:
            let vc = storyboard.instantiateViewController(withIdentifier: constants.VIDEO_DETAILS) as! FNVideoDetailsVC
            vc.initViewModel(feedObject: item)
            self.navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = storyboard.instantiateViewController(withIdentifier: constants.FACT_DETAILS) as! FNFactDetailsVC
            vc.initViewModel(feedObject: item)
            self.navigationController?.pushViewController(vc, animated: true)
        case 2:
            let vc = storyboard.instantiateViewController(withIdentifier: constants.NEWS_DETAILS) as! FNNewsDetailsVC
            vc.initViewModel(feedObject: item)
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            return
        }
    }
    
    func onClickShare(_ tag: Int) {
        let item        = newsfeedVM?.itemThroughIndex(tag)
        let itemToShare = [item?.url]
        let activityViewController = UIActivityViewController(activityItems: itemToShare as [Any], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
}
