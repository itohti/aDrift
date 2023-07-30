//
//  Logs.swift
//  aDrift
//
//  Created by Izdar Tohti on 7/30/23.
//

import SwiftUI

struct Logs: View {
    var logs : [String]
    var body: some View {
        ZStack{
            List{
                ForEach(logs.reversed(), id: \.self) { message in
                    Text(message)
                }
            }
            .scrollContentBackground(.hidden)
        }
    }
}
