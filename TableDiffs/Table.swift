//
//  Table.swift
//  TableDiffs
//
//  Created by Alexander Ignatenko on 26/05/15.
//  Copyright (c) 2015 Alexander Ignatenko. All rights reserved.
//

import Foundation
import UIKit

extension NSIndexSet {
    static func from(#array: [Int]) -> NSIndexSet {
        var set = NSMutableIndexSet()
        for index in array {
            set.addIndex(index)
        }
        return set.copy() as! NSIndexSet
    }
}

extension NSIndexPath {
    static func from(#rowIndex: TableMarkup.RowIndex) -> NSIndexPath {
        return NSIndexPath(forRow: rowIndex.row, inSection: rowIndex.section)
    }

    static func from(#rowIndices: [TableMarkup.RowIndex]) -> [NSIndexPath] {
        return rowIndices.map { NSIndexPath.from(rowIndex: $0) }
    }
}

func ==(lhs: TableMarkup.Section, rhs: TableMarkup.Section) -> Bool {
    return lhs.rows == rhs.rows
}

func ==(lhs: TableMarkup.Row, rhs: TableMarkup.Row) -> Bool {
    return (lhs.id == rhs.id) && (lhs.height == rhs.height)
}

struct TableMarkup {

    typealias RowIndex = (row: Int, section: Int)

    struct Row: Equatable {
        let id: String
        let height: CGFloat
    }

    struct Section: Equatable {
        let rows: [Row]

        init(_ rows: [Row]) {
            self.rows = rows
        }
    }

    struct Table {
        let sections: [Section]

        init(_ sections: [Section]) {
            self.sections = sections
        }

        func apply(#diff: TableDiff) -> Table {
            // TODO:
            var newSections = sections
            if let deleted = diff.sections?.deleted {
                for index in deleted {
                    let section = sections[index]
                    if let newIndex = find(newSections, section) {
                        newSections.removeAtIndex(newIndex)
                    }
                }
            }
            return Table(newSections)
        }

        func diff(table: Table) -> TableDiff? {
            return nil
        }
    }

    struct TableDiff {
        struct Sections {
            let added: [Int]?
            let updated: [Int]?
            let deleted: [Int]?
        }
        struct Rows {
            let added: [RowIndex]?
            let updated: [RowIndex]?
            let deleted: [RowIndex]?
        }
        let sections: Sections?
        let rows: Rows?
    }

    class Source: NSObject,
        UITableViewDataSource,
        UITableViewDelegate
    {
        var table: Table

        init(table: Table) {
            self.table = table
        }

        func apply(#diff: TableDiff, toTableView view: UITableView) {
            view.beginUpdates()

            if let added = diff.sections?.added {
                view.insertSections(
                    NSIndexSet.from(array: added),
                    withRowAnimation: .Automatic
                )
            }
            if let updated = diff.sections?.updated {
                view.reloadSections(
                    NSIndexSet.from(array: updated),
                    withRowAnimation: .Automatic
                )
            }
            if let deleted = diff.sections?.deleted {
                view.deleteSections(
                    NSIndexSet.from(array: deleted),
                    withRowAnimation: .Automatic
                )
            }

            if let added = diff.rows?.added {
                view.insertRowsAtIndexPaths(
                    NSIndexPath.from(rowIndices: added),
                    withRowAnimation: .Automatic
                )
            }
            if let updated = diff.rows?.updated {
                view.reloadRowsAtIndexPaths(
                    NSIndexPath.from(rowIndices: updated),
                    withRowAnimation: .Automatic
                )
            }
            if let deleted = diff.rows?.deleted {
                view.deleteRowsAtIndexPaths(
                    NSIndexPath.from(rowIndices: deleted),
                    withRowAnimation: .Automatic
                )
            }

            table = table.apply(diff: diff)
            view.endUpdates()
        }

        @objc func tableView(tableView: UITableView,
            cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
        {
            let row = table.sections[indexPath.section].rows[indexPath.row]
            return UITableViewCell(style: .Default, reuseIdentifier: row.id)
        }

        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            return table.sections.count
        }

        @objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return table.sections[section].rows.count
        }
    }

    static let table = Table([
        Section([
            Row(id: "1", height: 44),
            Row(id: "2", height: 44)]
        ),
        Section([
            Row(id: "3", height: 44),
            Row(id: "4", height: 44),
            Row(id: "5", height: 44)]
        ),
        Section([
            Row(id: "6", height: 44),
            Row(id: "7", height: 44)]
        )]
    )
}