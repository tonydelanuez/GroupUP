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
        return self.messages[indexPath.row]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didDeleteMessageAt indexPath: IndexPath!) {
        self.messages.remove(at: indexPath.row)
        self.collectionView.reloadData()
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        // If I sent the messgae, display outgoing bubble
        if self.messages[indexPath.row].senderId == self.senderId {
            return JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
        }
        
        // Message is incoming
        else {
            return JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    
}
