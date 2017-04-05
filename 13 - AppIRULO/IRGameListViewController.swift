//
//  IRGameListViewController.swift
//  13 - AppIRULO
//
//  Created by cice on 3/4/17.
//  Copyright © 2017 JC. All rights reserved.
//

import UIKit
import CoreData

class IRGameListViewController: UIViewController {

     // MARK: - Vbles locales globales
    
    var manageContext : NSManagedObjectContext!
    var listGame = [Game]()
 
    
    
    // MARK: - Outlets
    
    
    @IBOutlet weak var miFilterSegmentControl: UISegmentedControl!
    
    @IBOutlet weak var miCollectionView: UICollectionView!
    
    
    
    @IBAction func filterChangedAction(_ sender: UISegmentedControl) {
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        miCollectionView.delegate = self
        miCollectionView.dataSource = self
        miCollectionView.alwaysBounceVertical = true
        
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "addGameSegue" {
            let navVC = segue.destination as! UINavigationController
            let detalleVC = navVC.topViewController as! IRAddNewGameViewController
            print(detalleVC)
        }
        
        if segue.identifier == "editGameSegue" {
            let detalleVC = segue.destination as! IRAddNewGameViewController
            print(detalleVC)
        }
        
        
        
    }
   

} // TODO: -Fin de la clase

extension IRGameListViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if listGame.count == 0{
            
            let imageBackgroundList = UIImageView(image: #imageLiteral(resourceName: "img_empty_list"))
            imageBackgroundList.contentMode = .scaleAspectFit
            miCollectionView.backgroundView = imageBackgroundList
            
        } else {
            miCollectionView.backgroundView = UIView()
        }
        return listGame.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let customCell = miCollectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        return customCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "editGameSegue", sender: self)
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        if offsetY < -120{
            performSegue(withIdentifier: "addGameSegue", sender: self)
        }
    }
    
    
}
