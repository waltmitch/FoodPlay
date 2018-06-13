//
//  ViewController.swift
//  FoodPlay
//
//  Created by Walter Mitchell on 6/6/18.
//  Copyright © 2018 Walter Mitchell. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType:  NSAttributedString.DocumentType.html], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

class ViewController: UIViewController {
    
    let XMASHAPEHOST = "spoonacular-recipe-food-nutrition-v1.p.mashape.com"
    lazy var XMASHAPEKEY = valueForAPIKey(keyname: "XMASHAPEKEY")
    
    var headers: HTTPHeaders = ["": ""]
    
    let recipeData = RecipeDataModel()
    
    @IBOutlet weak var userInput: UIButton!
    @IBOutlet weak var foodInput: UITextField!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var recipeBodyField: UITextView!
    @IBOutlet weak var recipeServingsLabel: UILabel!
    @IBOutlet weak var recipeCookTimeLabel: UILabel!
    @IBOutlet weak var recipeTitleField: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        headers = [
            "X-Mashape-Host": XMASHAPEHOST,
            "X-Mashape-Key": XMASHAPEKEY
        ]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getRecipeId(params: String){
        //Alamofire.request(url: String, method: .get, parameters: params).responseJSON
        Alamofire.request("https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/search?query=\(params)", headers: headers).responseJSON { response in
            if response.result.isSuccess {
                print("Sucess! Got the recipe id")
                let json : JSON = JSON(response.result.value!)
                let recipeId = json["results"][0]["id"].intValue
                print(recipeId)
                
                if(recipeId != 0){
                    self.recipeData.id = recipeId
                    self.getRecipeData(id: self.recipeData.id)
                }
                else{
                    self.recipeTitleField.text = nil
                    self.recipeImageView.image = nil
                    self.recipeCookTimeLabel.text = nil
                    self.recipeServingsLabel.text = nil
                    self.recipeBodyField.text = nil
                    
                    let alert = UIAlertController(title: "Sorry! We can't find a recipe for that", message: "Ensure there's no typos, numbers, or special characters entered", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Try again", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                }
            }
            else {
                print("Error \(response.result.error)")
                print("Connection Issues")
            }
            
        }
    }
    @IBAction func searchButtonPressed(_ sender: Any) {
        let food = foodInput.text
        getRecipeId(params: food!)
    }
    
    func getRecipeData(id: Int){
        Alamofire.request("https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/\(id)/information", headers: headers).responseJSON { response in
            if response.result.isSuccess {
                print("Sucess! Got the recipe data")
                let recipeJSON : JSON = JSON(response.result.value!)
                print(recipeJSON)
                self.recipeData.body = recipeJSON["instructions"].stringValue
                self.recipeData.cookTime = recipeJSON["readyInMinutes"].intValue
                self.recipeData.servings = recipeJSON["servings"].intValue
                self.recipeData.title = recipeJSON["title"].stringValue
                self.recipeData.imageUrl = recipeJSON["image"].stringValue
                
                
                self.updateUI()
            }
            else {
                print("Error \(response.result.error)")
                print("Connection Issues")
            }
            
        }
        
    }
    func updateUI(){
        let imageUrlString = recipeData.imageUrl
        let imageUrl: URL = URL(string: imageUrlString)!
        
        recipeTitleField.text = recipeData.title
        recipeImageView.load(url: imageUrl)
        recipeCookTimeLabel.text = ("Cook Time:  \(recipeData.cookTime)")
        recipeServingsLabel.text = ("Servings: \(recipeData.servings)")
        recipeBodyField.text = recipeData.body.htmlToString
    }
    
    func valueForAPIKey(keyname: String) -> String {
        // Get the file path for keys.plist
        let filePath = Bundle.main.path(forResource: "keys", ofType: "plist")
        
        // Put the keys in a dictionary
        let plist = NSDictionary(contentsOfFile: filePath!)
        
        // Pull the value for the key
        let value: String = plist?.object(forKey: (keyname)) as! String
        
        return value
    }
    
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
