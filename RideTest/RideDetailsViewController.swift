//
//  RideDetailsViewController.swift
//  RideTest
//
//  Created by dinesh danda on 4/4/18.
//  Copyright © 2018 dinesh danda. All rights reserved.
//

import UIKit
import CoreData
class RideDetailsViewController: UIViewController , UITableViewDelegate,UITableViewDataSource {
var ridesArr = [NSManagedObject]()
    
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    // MARK: TableView Datasource  Methods

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return ridesArr.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
      let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell") as! CustomCell
        cell.updateUI(obj: ridesArr[indexPath.row])
        return cell
    }
    // MARK: TableView Delegate Methods

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let dv = self.storyboard?.instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
        dv.dataModel = ridesArr[indexPath.row];
        self.navigationController?.pushViewController(dv, animated: true)
    }
}
