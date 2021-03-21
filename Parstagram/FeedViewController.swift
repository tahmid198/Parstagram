//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Tahmid Zaman on 3/12/21.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {
    

    @IBOutlet weak var tableView: UITableView!
    
    //Creates comment bar
    let commentBar = MessageInputBar()
    var showsCommentBar = false
    var posts = [PFObject]()
    var selectedPost: PFObject!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        
        
        
        tableView.delegate = self
        tableView.dataSource = self

        tableView.keyboardDismissMode = .interactive //Dissmisses keyboard
        // Do any additional setup after loading the view.
        
        let center = NotificationCenter.default //Handles all notifications
        center.addObserver(self, selector: #selector(keyboardWillBeHiddden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil) //Grab notificatin center, call this function when the event, keyboard hides, on myself
    }
    @objc func keyboardWillBeHiddden(note: Notification){
        //This function gets called when keyboard is hiding
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        //Create a comment
        let comment = PFObject(className: "Comments")
        comment["text"] = text //Everything assocaited with comment object
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()!

        selectedPost.add(comment, forKey: "comments") //Add comment to post

        //Parse will save post and realize comment needs to be saved as well, unlike Firebase you have to do it yourself
        selectedPost.saveInBackground { (success, error) in
            if success{
                print("Comment Saved")
            }else{
                print("Error saving comment")
            }
        }
        tableView.reloadData() //So commment appears immedietly 
        
        //Clear and dismiss input bar
        commentBar.inputTextView.text = nil
        
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()//After post button is pressed, beyboard will dismiss
    }
    
    //Places Comment bar
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    override var canBecomeFirstResponder: Bool{
        return showsCommentBar
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
        return comments.count+2
    }
    
    //Number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []

        
        if indexPath.row == 0 { //Postcell is at 0 row; this row is for original post
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            
            let user = post["author"] as! PFUser
            cell.usernameLabel.text = user.username
            
            cell.captionLabel.text = post["caption"] as! String
            
            let imageFile  = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            
            cell.photoView.af_setImage(withURL: url)
        
            return cell
        } else if indexPath.row <= comments.count{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            
            let comment =  comments[indexPath.row - 1] //Brings you first comment
            cell.commentLabel.text = comment["text"] as? String
            
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addCommentCell")!
            return cell //Shows addcomment line in comment sections of app
        }
    }
     
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section] //Choose a post to add a comment to
        let comments = (post["comments"] as? [PFObject]) ?? [] //Create a comment object, will be create in Parse automaticlly
        
        if indexPath.row == comments.count + 1{
            showsCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder() //Raises keyboard
            
            selectedPost = post
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
