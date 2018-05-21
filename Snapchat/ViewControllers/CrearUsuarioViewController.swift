//
//  CrearUsuarioViewController.swift
//  Snapchat
//
//  Created by MAC10 on 21/05/18.
//  Copyright © 2018 tecsup. All rights reserved.
//

import UIKit
import Firebase

class CrearUsuarioViewController: UIViewController {

    @IBOutlet weak var txtUsuario: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnRegistrarse: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func registrarseTapped(_ sender: UIButton) {
        Auth.auth().createUser(withEmail: self.txtUsuario.text!, password: self.txtPassword.text!, completion: { (user, error)  in
            print("Intentando crear un usuario")
            if error != nil {
                print("Se presento el siguiente error al crear el usuario: \(error) ")
                self.mostrarAlerta(title: "Error", message: "Se produjo un error al registrar usuario. Vuelva a intentarlo.", action: "Cancelar")
            } else {
                print("El usuario fue creado exitosamente. usuario \(self.txtUsuario.text!) y password \(self.txtPassword.text!)")
                Database.database().reference().child("usuarios").child(user!.user.uid).child("email").setValue(user!.user.email)
                self.navigationController!.popViewController(animated: true)
            }
        })
            
    }
    
    func mostrarAlerta(title: String, message: String, action:String) {
        let alertaGuia = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelok = UIAlertAction(title: action, style: .default, handler: nil)
        alertaGuia.addAction(cancelok)
        present(alertaGuia, animated: true, completion: nil)
    }
    

    

}
