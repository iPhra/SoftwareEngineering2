//
//  RequestCellDelegate.swift
//  Data4Help
//
//  Created by Luca Molteni on 25/12/18.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

protocol RequestCellDelegate: class {
    func saveCSVsingle(reqid: String)
    func saveCSVgroup(reqid: String)
}
