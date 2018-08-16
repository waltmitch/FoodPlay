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
       
        print(self.recipeList[indexPath.row].id)
        tableView.deselectRow(at: indexPath, animated: true)
        
        //logic for segue to searchView
        let destVC = storyboard?.instantiateInitialViewController() as! SearchViewController
        destVC.userSelectionId = self.recipeList[indexPath.row].id
        present(destVC, animated: true, completion: nil)
        
        
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
        Alamofire.request("https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/search?query=\(userInput)", headers: headers).responseJSON { response in
            if response.result.isSuccess {
                print("Sucess! Got the recipe id")
                let json: JSON = JSON(response.result.value!)
                self.setRecipeList(input: json)
                //                let recipeId = json["results"][0]["id"].intValue
                //                print(recipeId)
                //*****
               
                //*****
                
                //                if(recipeId != 0){
                //                    self.recipeData.id = recipeId
                //                    self.getRecipeData(id: self.recipeData.id)
                //                }
                //                else{
                //                    self.recipeTitleField.text = nil
                //                    self.recipeImageView.image = nil
                //                    self.recipeCookTimeLabel.text = nil
                //                    self.recipeServingsLabel.text = nil
                //                    self.recipeBodyField.text = nil
                //
                //                    let alert = UIAlertController(title: "Sorry! We can't find a recipe for that", message: "Ensure there's no typos, numbers, or special characters entered", preferredStyle: .alert)
                //                    alert.addAction(UIAlertAction(title: "Try again", style: .cancel, handler: nil))
                //                    self.present(alert, animated: true)
                //                }
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
    
}
