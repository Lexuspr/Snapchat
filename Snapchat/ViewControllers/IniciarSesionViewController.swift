//
//  IniciarSesionViewController.swift
//  Snapchat
//
//  Created by MAC10 on 14/05/18.
//  Copyright © 2018 tecsup. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class IniciarSesionViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func iniciarSesionTapped(_ sender: UIButton) {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            print("Intentando Iniciar Sesión")
            if error != nil {
                print("Se presento el siguiente error: \(error)")
                Auth.auth().createUser(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!, completion: { (user, error)  in
                        print("Intentando crear un usuario")
                        if error != nil {
                            print("Se presento el siguiente error al crear el usuario: \(error) ")
                        } else {
                            print("El usuario fue creado exitosamente")
                            Database.database().reference().child("usuarios").child(user!.user.uid).child("email").setValue(user!.user.email)
                            self.performSegue(withIdentifier: "iniciarsesionsegue", sender: nil)
                        }
                })
            } else {
                print("Inicio de Sesion Exitoso")
                self.performSegue(withIdentifier: "iniciarsesionsegue", sender: nil)
            }
        }
    }
    


}

