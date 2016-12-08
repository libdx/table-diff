//
//  Table.swift
//  TableDiffs
//
//  Created by Alexander Ignatenko on 26/05/15.
//  Copyright (c) 2015 Alexander Ignatenko. All rights reserved.
//

import Foundation
import UIKit

extension IndexSet {
    static func from(array: [Int]) -> IndexSet {
        let set = NSMutableIndexSet()
        for index in array {
            set.add(index)
        }
        return set.copy() as! IndexSet
    }
}

extension IndexPath {
    static func from(rowIndex: TableMarkup.RowIndex) -> IndexPath {
        return IndexPath(row: rowIndex.row, section: rowIndex.section)
    }

    static func from(rowIndices: [TableMarkup.RowIndex]) -> [IndexPath] {
        return rowIndices.map { IndexPath.from(rowIndex: $0) }
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

        func apply(diff: TableDiff) -> Table {
            // TODO:
            var newSections = sections
            if let deleted = diff.sections?.deleted {
                for index in deleted {
                    let section = sections[index]
                    if let newIndex = newSections.index(of: section) {
                        newSections.remove(at: newIndex)
                    }
                }
            }
            return Table(newSections)
        }

        func diff(_ table: Table) -> TableDiff? {
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

        func apply(diff: TableDiff, toTableView view: UITableView) {
            view.beginUpdates()

            if let added = diff.sections?.added {
                view.insertSections(
                    IndexSet.from(array: added),
                    with: .automatic
                )
            }
            if let updated = diff.sections?.updated {
                view.reloadSections(
                    IndexSet.from(array: updated),
                    with: .automatic
                )
            }
            if let deleted = diff.sections?.deleted {
                view.deleteSections(
                    IndexSet.from(array: deleted),
                    with: .automatic
                )
            }

            if let added = diff.rows?.added {
                view.insertRows(
                    at: IndexPath.from(rowIndices: added),
                    with: .automatic
                )
            }
            if let updated = diff.rows?.updated {
                view.reloadRows(
                    at: IndexPath.from(rowIndices: updated),
                    with: .automatic
                )
            }
            if let deleted = diff.rows?.deleted {
                view.deleteRows(
                    at: IndexPath.from(rowIndices: deleted),
                    with: .automatic
                )
            }

            table = table.apply(diff: diff)
            view.endUpdates()
        }

        @objc func tableView(_ tableView: UITableView,
            cellForRowAt indexPath: IndexPath) -> UITableViewCell
        {
            let row = table.sections[indexPath.section].rows[indexPath.row]
            return UITableViewCell(style: .default, reuseIdentifier: row.id)
        }

        func numberOfSections(in tableView: UITableView) -> Int {
            return table.sections.count
        }

        @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
