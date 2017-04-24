//
//  ChatViewController.swift
//  GroupUP
//
//  Created by Eric Goodman on 4/6/17.
//  Copyright © 2017 GroupUP. All rights reserved.
//

import Foundation
import JSQMessagesViewController
import FirebaseDatabase
import FirebaseAuth

class ChatViewController : JSQMessagesViewController {
    
    var group: Group!
    var groupEndpoint: FIRDatabaseReference?
    var messages: [JSQMessage] = []
    var user: FIRUser!
    private lazy var messageEndpoint: FIRDatabaseReference = FIRDatabase.database().reference().child("messages")
    
    //Grab all groups
    private lazy var groupsRef: FIRDatabaseReference = FIRDatabase.database().reference().child("pins")
    
    lazy var outgoingBubbleImageView : JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView : JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    //Bubble setup
    //Outgoing
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    //Incoming
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    //View messages, append to the chat. 
    
    func detectMessages() {
        let groupMessageEndpoint = messageEndpoint.child(self.group.id).queryLimited(toLast: 25)
        
        groupMessageEndpoint.observe(FIRDataEventType.childAdded, with : { snapshot -> Void in
            guard let data = snapshot.value as? Dictionary<String, String> else {
                print("Could not decode message data")
                return
            }
            
            guard let id = data["senderId"], let senderName = data["senderDisplayName"], let text = data["text"] else {
                return
            }

            guard let message = JSQMessage(senderId: id, displayName: senderName, text: text) else {
                return
            }

            self.messages.append(message)
            
            self.finishReceivingMessage()
        })
    }
    
    // CollectionView overrides
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let groupMessageEndpoint = messageEndpoint.child(self.group.id).childByAutoId()
        var message : [String:String] = [:]
        message["text"] = text
        message["senderId"] = self.user.uid
        message["senderDisplayName"] = self.senderDisplayName
        groupMessageEndpoint.setValue(message)
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.finishSendingMessage()
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return self.messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didDeleteMessageAt indexPath: IndexPath!) {
        self.messages.remove(at: indexPath.item)
        self.collectionView.reloadData()
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        // If I sent the messgae, display outgoing bubble
        if self.messages[indexPath.item].senderId == self.senderId {
            return outgoingBubbleImageView
        }
            
            // Message is incoming
        else {
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        cell.textView.textColor = self.senderId == message.senderId ? UIColor.white : UIColor.black
        
        return cell
    }
    
    //Removing Avatar Data
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        if indexPath.item > 0 && self.messages[indexPath.item].senderId == self.messages[indexPath.item-1].senderId {
            return nil
        }
        let string = self.messages[indexPath.item].senderDisplayName
        return NSAttributedString(string: string!)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        if indexPath.item > 0 && self.messages[indexPath.item].senderId == self.messages[indexPath.item-1].senderId {
            return 0
        }
        return 15
    }
    
    //Grab user details
    func auth(){
        user = FIRAuth.auth()?.currentUser
        if let user = user {
            let uid = user.uid
            let email = user.email
            print(uid)
            print(String(describing: email))
            
        }
    }
    
    override func viewDidLoad() {
        self.tabBarController?.tabBar.isHidden = true
        super.viewDidLoad()
        self.navigationItem.title = self.group.name
        self.detectMessages()
        auth()
        //Remove avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
    }

    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
}
