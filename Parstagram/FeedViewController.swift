//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Tahmid Zaman on 3/12/21.
//

import UIKit
import Parse

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var tableView: UITableView!
    
    var posts = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let query = PFQuery(className: "Posts")
        query.includeKeys(["author", "comments", "comments.author"]) 
        query.limit = 20
        
        query.findObjectsInBackground(){ (posts, error) in
            if posts != nil{
                self.posts = posts!
                self.tableView.reloadData()
            }
            
        
    }
}
    //Number or rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        return comments.count+1
    }
    
    //Number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []

        
        if indexPath.row == 0 { //Postcell is at 0 row
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            
            let user = post["author"] as! PFUser
            cell.usernameLabel.text = user.username
            
            cell.captionLabel.text = post["caption"] as! String
            
            let imageFile  = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            
            cell.photoView.af_setImage(withURL: url)
        
            return cell
        } else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            
            let comment =  comments[indexPath.row - 1] //Brings you first comment
            cell.commentLabel.text = comment["text"] as? String
            
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
            
            
            
            
            return cell
        }
    }
     
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row] //Choose a post to add a comment to
        
        let comment = PFObject(className: "Comments") //Create a comment object, will be creased in Parse automaticlly
        comment["text"] = "This is a random comment" //Everything assocaited with comment object
        comment["post"] = post
        comment["author"] = PFUser.current()!
        
        post.add(comment, forKey: "comments") //Add comment to post
        
        //Parse will save post and realize comment needs to be saved as well, unlike Firebase you have to do it yourself
        post.saveInBackground { (success, error) in
            if success{
                print("Comment Saved")
            }else{
                print("Error saving comment")
            }
        }
        
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    @IBAction func onLogoutButton(_ sender: Any) {
        PFUser.logOut() //Logout action, clears Parse cache
        
        let main = UIStoryboard(name: "Main", bundle: nil) //Grab Main storyboard and instantiate it
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController") //Instantiate loginViewController
        
       //let delegate = UIApplication.shared.delegate as! SceneDelegate  //UIApplication is the one object that exist for each application. We cast delegate as SceneDelegate becuase its subclass contains the property window
       guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                             let delegate = windowScene.delegate as? SceneDelegate
                           else {
                             return
                           }
        
        delegate.window?.rootViewController = loginViewController //When logout button is clicked rootViewController will immediately be switched to login button
    }

}
