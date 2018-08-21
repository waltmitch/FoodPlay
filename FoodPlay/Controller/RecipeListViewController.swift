//
//  RecipeListTableViewController.swift
//  FoodPlay
//
//  Created by Walter Mitchell on 8/14/18.
//  Copyright © 2018 Walter Mitchell. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class RecipeListViewController: UITableViewController {
   
    var searchInputFromUser: String = ""
    var headers: HTTPHeaders = ["": ""]
    var recipeList: [RecipeResultModel] = [RecipeResultModel]()
    
    let BASE_URL: String = "https://spoonacular.com/recipeImages/"
    
    @IBOutlet var recipeListTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //delegate and datasource here:
        recipeListTableView.delegate = self
        recipeListTableView.dataSource = self

        //register .xib for custom cell
        recipeListTableView.register(UINib(nibName: "RecipeListCell", bundle: nil), forCellReuseIdentifier: "customRecipeListCell")
        
        //table view configs
        configureTableView()

        //removing default separator lines
        recipeListTableView.separatorStyle = .none
        
        getRecipeIds(userInput: searchInputFromUser)
    }
    
    //TableView methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        toSearchView(recipeIdToSend: self.recipeList[indexPath.row].id)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipeList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customRecipeListCell", for: indexPath) as! CustomRecipeListCell
        let recipe = recipeList[indexPath.row]
        
        cell.id = recipe.id
        cell.title.text = String(recipe.title)
        cell.readyInMinutes.text = ("Time: \(recipe.readyInMinutes)")
        cell.servings.text = ("SV: \(recipe.servings)")
        
        let imageUrlString = ("\(BASE_URL)\(recipe.imageUrl)")
        let imageUrl: URL = URL(string: imageUrlString)!
        cell.recipeImage.load(url: imageUrl)
       // cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func setRecipeList(input: JSON){
        
        for (index, item) in input["results"].arrayValue.enumerated() {
            //Temp RecipeResultModel to capture data during iteration
            let recipeModel = RecipeResultModel()
            
            recipeModel.id = item["id"].intValue
            recipeModel.imageUrl = item["image"].stringValue
            recipeModel.readyInMinutes = item["readyInMinutes"].intValue
            recipeModel.servings = item["servings"].intValue
            recipeModel.title = item["title"].stringValue
        
            //inserting new rows of RecipeResultModel with captured data
            recipeList.append(recipeModel)
        }
        recipeListTableView.reloadData()
    }
    
    func getRecipeIds(userInput: String){
        let input = cleanInput(userInput: userInput)
        print(input)
        Alamofire.request("https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/search?query=\(input)", headers: headers).responseJSON { response in
            
            if response.result.isSuccess {
                print("Sucess! Got recipe data!")
                let json: JSON = JSON(response.result.value!)
                
                if(json.isEmpty || json["totalResults"].intValue == 0){
                    let alert = UIAlertController(title: "Sorry! We can't find a recipe for that", message: "Ensure there's no typos, numbers, or special characters entered", preferredStyle: .alert)

                    alert.addAction(UIAlertAction(title: "Try again", style: .cancel, handler: { action in
                        self.toSearchView(recipeIdToSend: 0) }))
                    self.present(alert, animated: true)
                }
                else{
                    self.setRecipeList(input: json)
                }
            }
            else {
                print("Error \(response.result.error!)")
                print("Connection Issues")
            }
        }
    }
    
    func configureTableView() {
        self.tableView.rowHeight = 90
        self.tableView.backgroundColor = UIColor.lightGray
    }
    
    func toSearchView(recipeIdToSend: Int){
        let destVC = storyboard?.instantiateInitialViewController() as! SearchViewController
        destVC.userSelectionId = recipeIdToSend
        present(destVC, animated: true, completion: nil)
    }
    
    func cleanInput(userInput: String) -> String{
        var finalResult = userInput
        let whiteSpace = " "
        let hasWhiteSpace = userInput.contains(whiteSpace)
        
        if (hasWhiteSpace){
            finalResult = userInput.replacingOccurrences(of: whiteSpace, with: "+")
        }
        
        return finalResult
    }
    
}
