//
//  ImagenViewController.swift
//  Snapchat
//
//  Created by MAC10 on 21/05/18.
//  Copyright © 2018 tecsup. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class ImagenViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var lblDuracion: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descripcionTextField: UITextField!
    @IBOutlet weak var elegirContactoBoton: UIButton!
    
    var imagePicker = UIImagePickerController()
    var imagenID = NSUUID().uuidString
    
    var audioRecorder:AVAudioRecorder?
    var audioPlayer:AVAudioPlayer?
    var audioURL:URL?
    var audioURLs = ""
    var audioID = NSUUID().uuidString
    
    var timer = Timer()
    var segundos = 0
    var isTimerRunning = false
    var tempo = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        elegirContactoBoton.isEnabled = false
        setupRecorder()
        playBtn.isEnabled = false
        
        // Do any additional setup after loading the view.
    }
    
    func setupRecorder(){
        do{
            //creando sesion de audio
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            //creando direccion para el archivo de audio
            let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let nombre_audio = "\(audioID).m4a"
            let pathComponents = [basePath, nombre_audio]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
            
            print("********Ruta audio********")
            print(audioURL!)
            print("*************************")
            
            //crear opciones para el grabador de audio
            var settings:[String:AnyObject] = [ : ]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?
            
            //crear el objeto de grabacion de audio
            audioRecorder = try AVAudioRecorder(url: audioURL!, settings: settings)
            
            audioRecorder!.prepareToRecord()
        } catch let error as NSError {
            print(error)
        }
    }
    
    func runTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(ImagenViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    @objc func updateTimer() {
        segundos += 1
        lblDuracion.text = timeString(time: TimeInterval(segundos))
    }
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.image = image
        imageView.backgroundColor = UIColor.clear
        elegirContactoBoton.isEnabled = false
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func recordTapped(_ sender: UIButton) {
        if audioRecorder!.isRecording{
            //detener la grabacion
            audioRecorder?.stop()
            //cambiar texto del boton grabar
            recordBtn.setTitle("Grabar", for: .normal)
            playBtn.isEnabled = true
            elegirContactoBoton.isEnabled = true
            timer.invalidate()
            tempo = String(segundos)
        } else {
            //empezar a grabar
            segundos = 0
            lblDuracion.text = timeString(time: TimeInterval(segundos))
            audioRecorder?.record()
            //cambiar texto del boton grabar a detener
            recordBtn.setTitle("Detener", for: .normal)
            playBtn.isEnabled = false
            runTimer()
        }
    }
    
    @IBAction func playTapped(_ sender: UIButton) {
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: audioURL!)
            audioPlayer!.play()
        } catch {}
    }
    @IBAction func camaraTapped(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    @IBAction func mediaTapped(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    @IBAction func elegirContactoTapped(_ sender: UIButton) {
        elegirContactoBoton.isEnabled = false
        let imagenesFolder = Storage.storage().reference().child("imagenes")
        let audiosFolder = Storage.storage().reference().child("audios")
        let imagenData = UIImageJPEGRepresentation(imageView.image!, 0.1)!
        let audioData = NSData(contentsOf: audioURL!)
        let imagen = imagenesFolder.child("\(imagenID).jpg")
        let audio = audiosFolder.child("\(audioID).m4a")
        audio.putData(audioData as! Data, metadata: nil) {(metadata, error) in
            if error != nil {
                self.mostrarAlerta(title: "Error", message: "Se produjo un error al subir el audio. Vuelva a intentarlo.", action: "Cancelar")
                self.elegirContactoBoton.isEnabled = false
                print("Ocurrio un error al subir el audio: \(String(describing: error)) ")
                return
            } else {
                audio.downloadURL(completion: {(url, error) in
                    guard let enlaceURL = url else {
                        self.mostrarAlerta(title: "Error", message: "Se produjo un error al obtener información de audio.", action: "Cancelar")
                        print("Ocurrio un error al obtener informacion de audio \(String(describing: error))")
                        return
                    }
                    self.audioURLs = (url?.absoluteString)!
                })
            }
        }
        imagen.putData(imagenData, metadata: nil) {(metadata, error) in
            if error != nil {
                self.mostrarAlerta(title: "Error", message: "Se produjo un error al subir la imagen. Vuelva a intentarlo.", action: "Cancelar")
                self.elegirContactoBoton.isEnabled = false
                print("Ocurrio un error al subir imagen: \(String(describing: error)) ")
                return
            } else {
                imagen.downloadURL(completion: {(url, error) in
                    guard let enlaceURL = url else{
                        self.mostrarAlerta(title: "Error", message: "Se produjo un error al obtener información de imagen.", action: "Cancelar")
                        self.elegirContactoBoton.isEnabled = true
                        print("Ocurrio un error al obtener informacion de imagen \(String(describing: error))")
                        return
                    }
                    self.performSegue(withIdentifier: "seleccionarContactoSegue", sender: url?.absoluteString)
                })
            }
        }
    }
    
    func mostrarAlerta(title: String, message: String, action:String) {
        let alertaGuia = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelok = UIAlertAction(title: action, style: .default, handler: nil)
        alertaGuia.addAction(cancelok)
        present(alertaGuia, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let siguienteVC = segue.destination as! ElegirUsuarioViewController
        siguienteVC.imagenURL = sender as! String
        siguienteVC.descrip = descripcionTextField.text!
        siguienteVC.imagenID = imagenID
        siguienteVC.audioID = audioID
        siguienteVC.audioURL = audioURLs
        siguienteVC.tempo = tempo
    }
    
 

}
