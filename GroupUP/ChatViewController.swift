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

class ChatViewController : JSQMessagesViewController {
    
    var group: Group?
    var groupEndpoint: FIRDatabaseReference?
    var messages: [JSQMessage] = []
    
    // CollectionView overrides
    
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
            return JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
        }
            
            // Message is incoming
        else {
            return JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if message.senderId == senderId { // 1
            cell.textView?.textColor = UIColor.white // 2
        } else {
            cell.textView?.textColor = UIColor.black // 3
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let string = self.messages[indexPath.item].senderDisplayName
        return NSAttributedString(string: string!)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 15
    }
    
    override func viewDidLoad() {
        self.tabBarController?.tabBar.isHidden = true
        super.viewDidLoad()
        
        self.navigationItem.title = self.group?.name
        let dummyMessage = JSQMessage(senderId: self.senderId, displayName: "Justin", text: "Study tomorrow?")
        let other = JSQMessage(senderId: "4321", displayName: "Eric" , text: "Works for me")
        let moreother = JSQMessage(senderId: "12345", displayName: "Tony", text: "I'll bring the textbook")
        self.messages.append(dummyMessage!)
        self.messages.append(other!)
        self.messages.append(moreother!)
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
}
