//
//  Connectivity.swift
//  FoodPlay
//
//  Created by Walter Mitchell on 8/21/18.
//  Copyright © 2018 Walter Mitchell. All rights reserved.
//

import Foundation
import Alamofire

class Connectivity {
    
    class func isConnectedToInternet() ->Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
