//
//  VerSnapViewController.swift
//  Snapchat
//
//  Created by MAC10 on 28/05/18.
//  Copyright © 2018 tecsup. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase
import AVFoundation

class VerSnapViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    var snap = Snap()
    var audioPlayer:AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text? = snap.descrip
        imageView.sd_setImage(with: URL(string: snap.imagenURL))
        if snap.audioURL != nil {
            print(snap.audioURL)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(string: snap.audioURL)!, fileTypeHint: "aac")
                audioPlayer?.play()
            }catch{}
        } else {
            print("No hay audio")
        }
        print("AudioPlayer")
        print(audioPlayer)
        
       
    }
    override func viewWillDisappear(_ animated: Bool) {
        Database.database().reference().child("usuarios").child((Auth.auth().currentUser?.uid)!).child("snaps").child(snap.id).removeValue()
        
        Storage.storage().reference().child("imagenes").child("\(snap.imagenID).jpg").delete{ (error) in
            print("Se elimino la imagen correctamente")
        }
        Storage.storage().reference().child("audios").child("\(snap.audioID).m4a").delete{ (error) in
            print("Se elimino la imagen correctamente")
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
