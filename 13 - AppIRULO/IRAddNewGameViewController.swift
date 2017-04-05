//
//  IRAddNewGameViewController.swift
//  13 - AppIRULO
//
//  Created by cice on 3/4/17.
//  Copyright © 2017 JC. All rights reserved.
//

import UIKit
import CoreData


protocol IRAddNewGameViewControllerDelegate {
    func didAddGame()
}




class IRAddNewGameViewController: UIViewController {

    //MARK: - vbles locales globales
    
    var manageContext : NSManagedObjectContext!
    var iRuDelegate : IRAddNewGameViewControllerDelegate?
    var game : Game?
    var datePicker : UIDatePicker!
    var dateFormatter = DateFormatter()
    
    // MARK: IB-Outlets
    
    
    @IBOutlet weak var miImageGame: UIImageView!
    
    
    @IBOutlet weak var miSwitchBorrowed: UISwitch!
    
    @IBOutlet weak var miTituloGame: UITextField!
    
    @IBOutlet weak var miPrestadoQuienGame: UITextField!
    @IBOutlet weak var miCuandoPrestadoGame: UITextField!
    
    @IBOutlet weak var miEliminarVideojuegoBoton: UIButton!
    
    
   // MARK: - IBActions
    
    
    @IBAction func miSwtichChangedValue(_ sender: UISwitch) {
        if sender.isOn{
            miPrestadoQuienGame.isEnabled = true
            miCuandoPrestadoGame.isEnabled = true
            miCuandoPrestadoGame.text = dateFormatter.string(from: Date())
            
        } else {
            miPrestadoQuienGame.isEnabled = false
            miCuandoPrestadoGame.isEnabled = false
            miPrestadoQuienGame.text = ""
            miCuandoPrestadoGame.text = ""
        }
    }
    
    
    
    @IBAction func eliminarVideoJuegoACTION(_ sender: Any) {
        if let context = manageContext{
            context.delete(game!)
            game = nil
            iRuDelegate?.didAddGame()
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Formato de fecha
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        
        // Imagen
        
        miImageGame.isUserInteractionEnabled = true
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(pickPhoto))
        miImageGame.addGestureRecognizer(tapGR)
        
        // Teclado
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)

        // Esconder teclado
        
        
        
        let tapGRhidekeyboard = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.view.addGestureRecognizer(tapGRhidekeyboard)
        
        
        //DatePicker
        
        datePicker = UIDatePicker(frame: CGRect(x: 0, y: 210, width: 320, height: 216))
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        miCuandoPrestadoGame.inputView = datePicker
        
        
        //DOS logicas en el mismo VC
        
        // 1. add / 2 edit
        
        if game == nil {
            self.title = "Añadir Videojuego"
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonAction))
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonAction))
            miEliminarVideojuegoBoton.isHidden = true
            miSwitchBorrowed.isOn = false
        } else {
            self.title = "Editar Videojuego"
            miTituloGame.text = game?.title
            if let borrowed = game?.borrowed{
                miSwitchBorrowed.isOn = borrowed
            }
            miPrestadoQuienGame.text = game?.borrowedTo
            if let borrowedDate = game?.borrowedDate as Date?{
                miCuandoPrestadoGame.text = dateFormatter.string(from: borrowedDate)
            }
            
            if let imageData = game?.image as Data?{
                miImageGame.image = UIImage(data: imageData)
            }
            miEliminarVideojuegoBoton.isHidden = false
        }
        
        if !miSwitchBorrowed.isOn{
            miPrestadoQuienGame.isEnabled = false
            miCuandoPrestadoGame.isEnabled = false
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if game != nil {
            saveGame()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
    //MARK: - UTILS
    
    
    func keyboardWillShow(_ notification : Notification){
        let info = notification.userInfo!
        let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey]as! NSValue).cgRectValue
        let keyboardTime = (info[UIKeyboardAnimationDurationUserInfoKey]as! NSNumber).doubleValue
        UIView.animate(withDuration: keyboardTime) { 
            self.view.frame.origin.y = -(keyboardFrame.height)
        }
    }
    
    func keyboardWillHide(_ notification : Notification) {
        let info = notification.userInfo!
        let keyboardTime = (info[UIKeyboardAnimationDurationUserInfoKey]as! NSNumber).doubleValue
        UIView.animate(withDuration: keyboardTime) {
            self.view.frame.origin.y = 0        }
    }
    
    func  hideKeyboard(){
        for c_view in self.view.subviews{
            if let textField = c_view as? UITextField{
                textField.resignFirstResponder()
            }
        }
    }
    
    func datePickerValueChanged(_ picker : UIDatePicker){
        miCuandoPrestadoGame.text = dateFormatter.string(from: picker.date)
    }
    
    func cancelButtonAction(){
        dismiss(animated: true, completion: nil)
    }
    
    func saveButtonAction(){
        saveGame()
        dismiss(animated: true, completion: nil)
    }
    func saveGame(){
        // inyectamos el contexto
        
        if let context = manageContext{
            //1 -> 
            var editedGame : Game?
            if game == nil {
                editedGame = Game(context: context)
            } else {
                editedGame = game
            }
            
            editedGame?.title = self.miTituloGame.text
            editedGame?.borrowed = self.miSwitchBorrowed.isOn
            
            let imageData = UIImageJPEGRepresentation(miImageGame.image!, 0.3)
            editedGame?.image = imageData as NSData?
            
            if (editedGame?.borrowed)!{
                editedGame?.borrowedTo = miPrestadoQuienGame.text?.uppercased()
                editedGame?.borrowedDate = dateFormatter.date(from: miCuandoPrestadoGame.text!) as NSDate?
                
            }
            
            do{
                try context.save()
                self.iRuDelegate?.didAddGame()
            }catch{
                print("Error al guardar los datos en coredata")
            }
            
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

extension IRAddNewGameViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func pickPhoto(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            muestraMenu()
        } else {
            muestraLibreriaFotos()
        }
    }
    
    func muestraMenu(){
        let alertVC = UIAlertController(title: nil, message: nil , preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        let tomaFotoAction = UIAlertAction(title: "Toma foto", style: .default) { _ in
            self.muestraCamara()
        }
        
        let seleccionaLibreria = UIAlertAction(title: "Selecciona de la libreria", style: .default) {
            _ in
            self.muestraLibreriaFotos()
            
        }
        alertVC.addAction(cancelAction)
        alertVC.addAction(tomaFotoAction)
        alertVC.addAction(seleccionaLibreria)
        present(alertVC, animated: true, completion: nil)
    }
    
    func muestraCamara(){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func muestraLibreriaFotos(){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let imageData = info[UIImagePickerControllerOriginalImage] as? UIImage{
            miImageGame.image = imageData
            
        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

