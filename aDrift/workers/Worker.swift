//
//  Worker.swift
//  aDrift
//
//  Created by Izdar Tohti on 7/31/23.
//

import Foundation

protocol Worker{
    func getName() -> String
    func getCosts() -> [String: Int]
    func getGains() -> [String: Int]
}
