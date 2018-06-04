//
//  SnapsViewController.swift
//  Snapchat
//
//  Created by MAC10 on 21/05/18.
//  Copyright © 2018 tecsup. All rights reserved.
//

import UIKit
import Firebase

class SnapsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var snaps:[Snap] = [ ]
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
            Database.database().reference().child("usuarios").child((Auth.auth().currentUser?.uid)!).child("snaps").observe(DataEventType.childAdded, with: {(snapshot) in
                let snap = Snap()
                snap.imagenURL = (snapshot.value as! NSDictionary)["imagenURL"] as! String
                snap.from = (snapshot.value as! NSDictionary)["from"] as! String
                snap.descrip = (snapshot.value as! NSDictionary)["descripcion"] as! String
                snap.id = snapshot.key
                snap.imagenID = (snapshot.value as! NSDictionary)["imagenID"] as! String
                snap.audioID = (snapshot.value as! NSDictionary)["audioID"] as! String
                snap.audioTempo = (snapshot.value as! NSDictionary)["audioTempo"] as! String
                snap.audioURL = (snapshot.value as! NSDictionary)["audioURL"] as! String
                self.snaps.append(snap)
                self.tableView.reloadData()
            })
        
        Database.database().reference().child("usuarios").child((Auth.auth().currentUser?.uid)!).child("snaps").observe(DataEventType.childRemoved, with: {(snapshot) in
            var iterator = 0
            for snap in self.snaps{
                if snap.id == snapshot.key{
                    self.snaps.remove(at: iterator)
                }
                iterator += 1
            }
            self.tableView.reloadData()
        })
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if snaps.count == 0{
            return 1
        } else{
        return snaps.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if snaps.count == 0{
            cell.textLabel?.text = "No tienes Snaps 😭"
        } else{
        let snap = snaps[indexPath.row]
        cell.textLabel?.text = snap.from
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if snaps.count == 0{
           tableView.deselectRow(at: indexPath, animated: true)
        } else {
        let snap = snaps[indexPath.row]
        performSegue(withIdentifier: "verSnapSegue", sender: snap)
        }
    }
    @IBAction func cerrarSesionTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "verSnapSegue" {
            let siguienteVC = segue.destination as! VerSnapViewController
            siguienteVC.snap = sender as! Snap
        }
    }
    

}
