//
//  ViewController.swift
//  TableDiffs
//
//  Created by Alexander Ignatenko on 26/05/15.
//  Copyright (c) 2015 Alexander Ignatenko. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var tableView: UITableView! {
        return self.view as? UITableView
    }

    let source = TableMarkup.Source(table: TableMarkup.table)

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = source
        tableView.delegate = source

        let diff = TableMarkup.TableDiff(
            sections: TableMarkup.TableDiff.Sections(
                added: nil,
                updated: nil,
                deleted: [0, 2]
            ),
            rows: nil)

        let delay = DispatchTime.now() as DispatchTime + Double(2 * Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delay) { [unowned self] () -> Void in
            self.source.apply(diff: diff, toTableView: self.tableView)
        }
    }
}

