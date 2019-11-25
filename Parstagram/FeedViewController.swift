//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Meagan Olsen on 11/15/19.
//  Copyright © 2019 Meagan Olsen. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage
import Alamofire
import MessageInputBar

class FeedViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,MessageInputBarDelegate {

    
    var posts = [PFObject]()
    
    @IBOutlet var tableView: UITableView!
    let messageInputBar: MessageInputBar = MessageInputBar()
    var showsCommentBar: Bool = false
    var selectedPost:PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageInputBar.inputTextView.placeholder = "Add a commment..."
        messageInputBar.sendButton.title = "Post"
        messageInputBar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .interactive
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
         DataRequest.addAcceptableImageContentTypes(["application/octet-stream"])

        // Do any additional setup after loading the view.
    }
    @objc func keyboardWillBeHidden(note: Notification){
        messageInputBar.inputTextView.text = nil
        showsCommentBar = false
        self.becomeFirstResponder()
        messageInputBar.inputTextView.text = nil
    }
    override var inputAccessoryView: UIView?{
        return messageInputBar
    }
    override var canBecomeFirstResponder: Bool{
        return showsCommentBar
    }
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        //Clear and dismiss the input bar
        messageInputBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
        messageInputBar.inputTextView.resignFirstResponder()
        
        //Create the comment
        let comment = PFObject(className: "Comments")
        
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()!

        selectedPost.add(comment, forKey: "comments")
        selectedPost.saveInBackground { (success, error) in
            if success{
                print("Comment saved")
            }
            else{
                print("Error saving comments")
            }
        }
        tableView.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let query = PFQuery(className: "Posts")
        query.includeKeys(["author","comments","comments.author"])
        query.limit = 20
        
        query.findObjectsInBackground { (posts, error) in
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
        tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
            let post = posts[section]
            let comments = post["comments"] as? [PFObject] ?? []
            return comments.count+2
    }
    func numberOfSections(in tableView:UITableView)->Int {
        return posts.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /*Grab post*/
        let post = posts[indexPath.section]
        let comments = post["comments"] as? [PFObject] ?? []
        
        if indexPath.row == 0 {
            
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        let user = post["author"] as! PFUser
        cell.nameLabel.text = user.username
        cell.captionLabel.text = post["caption"] as! String
        
       /*Grab the image*/
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        cell.photoView.af_setImage(withURL: url)
        
        return cell
        }
        else if indexPath.row <= comments.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            let comment = comments[indexPath.row - 1]
            cell.commentLabel.text = comment["text"] as? String
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            return cell
        }
    }
    @IBAction func onLogoutButton(_ sender: Any) {
        let main = UIStoryboard(name:"Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        let delegate = self.view.window?.windowScene?.delegate as! SceneDelegate
        
        delegate.window?.rootViewController = loginViewController
        PFUser.logOut()
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        
        
       // let comment = PFObject(className: "Comments")
        let comments = post["comments"] as? [PFObject] ?? []
        
        if indexPath.row == comments.count+1 {
            print("Adding a comment")
            showsCommentBar = true
            self.becomeFirstResponder()
            messageInputBar.inputTextView.becomeFirstResponder()
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

}
