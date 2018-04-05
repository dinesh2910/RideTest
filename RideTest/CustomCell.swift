//
//  CustomCell.swift
//  RideTest
//
//  Created by dinesh danda on 4/4/18.
//  Copyright © 2018 dinesh danda. All rights reserved.
//

import UIKit
import CoreData
class CustomCell: UITableViewCell {

    @IBOutlet var distanceLbl: UILabel!
    @IBOutlet var calariesLbl: UILabel!
    @IBOutlet var dateLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func updateUI(obj : NSManagedObject) {
        self.dateLbl.text = obj.value(forKey: "date") as? String
        self.distanceLbl.text = String(format: "%.2f Miles",(obj.value(forKey: "distance") as? Double)! )

        self.calariesLbl.text = String(format: "%.2f Calaries",(obj.value(forKey: "calaries") as? Double)! )


    }
}
