//
//  ViewController.swift
//  Prototype
//
//  Created by Andrew Aquino on 8/8/16.
//  Copyright © 2016 Andrew Aquino. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import ObjectMapper
import Pantry
import SwiftyTimer

public class ViewController: UIViewController {

  public override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
//    serverCall()
    
    NSTimer.after(3.0) {
      for i in 0...1 {
        if let object = Pantry.unpack(i.description) as TestObject? {
          log.debug(object.toJSONString(true))
        }
      }
    }
  }

  public override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  public func serverCall() {
    Alamofire.request(.GET, "http://localhost:3000/posts")
    .response { req, res, data, error in
      if let error = error {
        log.error(error)
      } else if let data = data, jsonArray = JSON(data: data).array {
        
        (jsonArray.map { TestObject(json: $0) }).enumerate().forEach { index, item in
          Pantry.pack(item, key: index.description, expires: .Seconds(120))
        }
      }
    }
  }
}


public class BasicObject: Mappable, Storable {
  public var id: Int?
  public init() {}
  public required init?(_ map: Map) {}
  public func mapping(map: Map) {
    id <- map["id"]
  }
  public convenience init(json: JSON?) {
    self.init()
    if let dictionary = json?.dictionaryObject {
      mapping(Map(mappingType: .FromJSON, JSONDictionary: dictionary))
    }
  }
  public required init(warehouse: JSONWarehouse) {
    self.id = warehouse.get("id") ?? 0
  }
  public func toDictionary() -> [String: AnyObject] {
    var dictionary: [String: AnyObject] = [:]
    dictionary["id"] = self.id
    return dictionary
  }
}

public class TestObject: BasicObject {
  
  public var title: String?
  public var author: String?
  
  public override init() { super.init() }
  public required init?(_ map: Map) { super.init(map) }
  
  public required init(warehouse: JSONWarehouse) {
    super.init(warehouse: warehouse)
    
    self.title = warehouse.get("title")
    self.author = warehouse.get("author")
  }
  
  public override func toDictionary() -> [String : AnyObject] {
    var dictionary = super.toDictionary()
    dictionary["title"] = self.title
    dictionary["author"] = self.author
    return dictionary
  }
  
  public override func mapping(map: Map) {
    super.mapping(map)
    
    title               <- map["title"]
    author              <- map["author"]
  }
}



















