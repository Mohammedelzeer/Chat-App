//
//  MSGViewController.swift
//  Chat Clone
//
//  Created by Mohammed on 16/01/2024.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Gallery
import RealmSwift

class MSGViewController: MessagesViewController {
    
    //MARK:- View customized
    
    let leftBarButtonView: UIView = {
        return UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    } ()
    
    let titleLabel: UILabel = {
        
        let title = UILabel(frame: CGRect(x: 5, y: 0, width: 100, height: 25))
        title.textAlignment = .left
        title.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        title.adjustsFontSizeToFitWidth = true
        
        return title
        
    }()
    
    let subTitleLabel: UILabel = {
        
        let title = UILabel(frame: CGRect(x: 5, y: 22, width: 100, height: 24))
        title.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        title.adjustsFontSizeToFitWidth = true
        
        return title
    } ()
    
    
    
    
    
    
    
    
    //MARK:- Vars
    
    private var chatId = ""
    private var recipientId = ""
    private var recipientName = ""
    let refreshController = UIRefreshControl()
    let micButton = InputBarButtonItem()
    
    let currentUser = MKSender(senderId: User.currentId, displayName: User.currentUser!.username)
    
    var mkMessages: [MKMessage] = []
    var allLocalMessages: Results<LocalMessage>!
    let realm = try! Realm()
    
    var notifactionToken: NotificationToken?
    
    var dispayingMessagesCount = 0
    var maxMessageNumber = 0
    var minMessageNumber = 0
    
    var typingCounter = 0
    
    var gallery: GalleryController!
    
    var longPressGesture: UILongPressGestureRecognizer!
    
    var audioFileName: String = ""
    var audioStartTime: Date = Date()
    
    open lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)

    
    
    
    //MARK:- init
    
    init(chatId: String, recipientId: String, recipientName: String) {
        super.init(nibName: nil, bundle: nil)
        
        self.chatId = chatId
        self.recipientId = recipientId
        self.recipientName = recipientName
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureGestureRecognizer()

        configureMessageCollectionView()
        configureMessageInputBar()
        //self.title = recipientName
        
        loadMessages()
        listenForNewMessages()
        
        configureGestureRecognizer()
        configureCustomTitle()
        createTypingObserver()
        listenForReadStatusUpdates()
        
        navigationItem.largeTitleDisplayMode = .never
        
        
    }
    
    private func configureMessageCollectionView () {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        
        scrollsToLastItemOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        messagesCollectionView.refreshControl = refreshController

    }
    
    private func configureMessageInputBar () {
        messageInputBar.delegate = self
        let attachButton = InputBarButtonItem()
        attachButton.image = UIImage(systemName: "paperclip", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        attachButton.setSize(CGSize(width: 30, height: 30), animated: false)
        attachButton.onTouchUpInside { item  in
            
            self.actionAttachMessage()
        }
        
       
        micButton.image = UIImage(systemName: "mic.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        micButton.setSize(CGSize(width: 30, height: 30), animated: false)
        
        micButton.addGestureRecognizer(longPressGesture)
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        //TODO:- Update mic button status
        
        updateMicButtonStatus(show: true)
        
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground
    }
    
    //Long press configuration
    
    private func configureGestureRecognizer() {
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(recordAndSend))
    }
    
    
    
    
    
    
    //MARK:- configure custom title
    
    private func configureCustomTitle() {
        
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(self.backButtonPressed))]
        
        leftBarButtonView.addSubview(titleLabel)
        leftBarButtonView.addSubview(subTitleLabel)
        
        let leftBarButtonItem = UIBarButtonItem(customView: leftBarButtonView)
        self.navigationItem.leftBarButtonItems?.append(leftBarButtonItem)
        titleLabel.text = self.recipientName
        
    }
    
    @objc func backButtonPressed () {
        
        removeListeners()
        
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- MarkMessage As read
    
    private func markMessageAsRead(_ localMessage: LocalMessage) {
        if localMessage.senderId != User.currentId {
            FMessageListener.shared.updateMessageStatus(localMessage, userId: recipientId)
        }
    }
    
    
    
    
    
    
    //MARK:- Update typing indicator
    
    func updateTypingIndicator(_ show: Bool) {
        
        subTitleLabel.text = show ? "Typing..." : ""
    }
    
    func startTypingIndicator () {
        typingCounter += 1
        FTypingListener.saveTypingCounter(typing: true, chatRoomId: chatId)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.stopTypingIndicator()
        }
    }
    
    func stopTypingIndicator () {
        typingCounter -= 1
        
        if typingCounter == 0 {
            FTypingListener.saveTypingCounter(typing: false, chatRoomId: chatId)
        }
    }
    
    func createTypingObserver() {
        FTypingListener.shared.createTypingObserver(chatRoomId: chatId) { (isTyping) in
            
            DispatchQueue.main.async {
                self.updateTypingIndicator(isTyping)
            }
        }
    }
    
    
    
    
    
    
    
    func updateMicButtonStatus (show: Bool) {
        if show {
            messageInputBar.setStackViewItems([micButton], forStack: .right, animated: false)
            
            messageInputBar.setRightStackViewWidthConstant(to: 30, animated: false)
        } else {
            messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: false)
            
            messageInputBar.setRightStackViewWidthConstant(to: 55, animated: false)
        }
    }
    
    //MARK:- Actions
    
    func send(text: String?, photo:UIImage?, video: Video?, audio: String?, location: String?, audioDuration: Float = 0.0) {
        
        Outgoing.sendMessage(chatId: chatId, text: text, photo: photo, video: video, audio: audio, location: location, memberIds: [User.currentId, recipientId])
        
    }
    
    //Record and send function
    
    @objc func recordAndSend() {
        switch longPressGesture.state {
            
        case .began:
            audioFileName = Date().stringDate()
            audioStartTime = Date()
            AudioRecorder.shared.startRecording(fileName: audioFileName)
            
        case .ended:
            AudioRecorder.shared.finishRecording()
            if fileExistsAtPath(path: audioFileName + ".m4a") {
                
                let audioDuration = audioStartTime.interval(ofComponent: .second, to: Date())
                send(text: nil, photo: nil, video: nil, audio: audioFileName, location: nil, audioDuration: audioDuration)
                
            } else {
                print("No File Found")
            }
            
        @unknown default:
            print("Unknown")
        }
    }
    
    private func actionAttachMessage() {
        
        messageInputBar.inputTextView.resignFirstResponder()
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { (alert) in
            
            self.showImageGallery(camera: true)
        }
        
        let shareMedia = UIAlertAction(title: "Library", style: .default) { (alert) in
            
            self.showImageGallery(camera: false)
            print("library")
        }
        
        let shareLocation = UIAlertAction(title: "Show Location", style: .default) { (alert) in
            
           // if let location1 = LocationManger.shared.currentLocation {
                self.send(text: nil, photo: nil, video: nil, audio: nil, location: kLOCATION)
                print("Location")

            //}
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        takePhotoOrVideo.setValue(UIImage(systemName: "camera"), forKey: "image")
        shareMedia.setValue(UIImage(systemName: "photo.fill"), forKey: "image")
        shareLocation.setValue(UIImage(systemName: "mappin.and.ellipse"), forKey: "image")
        
        optionMenu.addAction(takePhotoOrVideo)
        optionMenu.addAction(shareMedia)
        optionMenu.addAction(shareLocation)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
        
    }
    
    //MARK:- UIScrollViewDelegate
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshController.isRefreshing {
            if dispayingMessagesCount < allLocalMessages.count {
                self.insertMoreMKMessages()
                messagesCollectionView.reloadDataAndKeepOffset()
            }
        }
        
        refreshController.endRefreshing()
    }
    
    //MARK:- Load Message
    
    private func loadMessages () {
        
        let predicate = NSPredicate(format: "chatRoomId = %@", chatId)
        
        allLocalMessages = realm.objects(LocalMessage.self).filter(predicate).sorted(byKeyPath: kDATE, ascending: true)
       // print("Messages found", allLocalMessages.count)
        
        if allLocalMessages.isEmpty {
            checkForOldMessage()
        }
        
        
        notifactionToken = allLocalMessages.observe({(change: RealmCollectionChange) in
            
            switch change {
                
            case.initial:
                self.insertMKMessages()
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem(animated: true)
                
            case.update(_, _, let insertions, _):
                for index in insertions {
                    self.insertMKMessage(localMessage: self.allLocalMessages[index])
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem(animated: false)
                    self.messagesCollectionView.scrollToBottom(animated: false)
                }
            case .error(let error):
                
                print("error on new insertion", error.localizedDescription)
            }
            
            
        })
    }
    
    private func insertMKMessage (localMessage: LocalMessage) {
        markMessageAsRead(localMessage)
       let incoming = Incoming (messageViewController: self)
       let mkMessage = incoming.createMKMessage (localMessage: localMessage)
       self.mkMessages.append (mkMessage)
        
  }
    
    private func insertOlderMKMessage (localMessage: LocalMessage) {
       let incoming = Incoming (messageViewController: self)
       let mkMessage = incoming.createMKMessage (localMessage: localMessage)
       self.mkMessages.insert(mkMessage, at: 0)
       dispayingMessagesCount += 1
        
  }

    
    private func insertMKMessages () {
        
        maxMessageNumber = allLocalMessages.count - dispayingMessagesCount
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        
        for i in minMessageNumber ..< maxMessageNumber {
         insertMKMessage (localMessage: allLocalMessages[i])
  }

}
    
    private func insertMoreMKMessages () {
        
        maxMessageNumber = minMessageNumber - 1
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        
        for i in (minMessageNumber ... maxMessageNumber).reversed() {
         insertOlderMKMessage(localMessage: allLocalMessages[i])
  }

}


    private func checkForOldMessage() {
        
        FMessageListener.shared.checkForOldMessage(User.currentId, collectionId: chatId)
    }
    
    private func listenForNewMessages() {
        FMessageListener.shared.listenForNewMessages(User.currentId, collectionId: chatId, lastMessageDate: lastMessageDate())
    }
    
    //MARK:- update Read Status
    
    private func updateReadStatus (_ updateLocalMessage: LocalMessage) {
        for index in 0 ..< mkMessages.count {
            let tempMessage = mkMessages[index]
            if updateLocalMessage.id == tempMessage.messageId {
                mkMessages[index].status = updateLocalMessage.status
                mkMessages[index].readDate = updateLocalMessage.readDate
                
                RealmManger.shared.save(updateLocalMessage)
                
                if mkMessages[index].status == kREAD {
                    self.messagesCollectionView.reloadData()
                }
            }
        }
    }
    
    private func listenForReadStatusUpdates() {
        FMessageListener.shared.listenForReadStatus(User.currentId, collectionId: chatId) { (updatedMessage) in
            self.updateReadStatus(updatedMessage)
        }
    }
    
    //MARK:- Helper
    
    private func lastMessageDate()-> Date {
        let lastMessageDate = allLocalMessages.last?.date ?? Date()
        return Calendar.current.date(byAdding: .second, value: 1, to: lastMessageDate) ?? lastMessageDate
    }
    
    private func removeListeners() {
        FTypingListener.shared.removeTypingListener()
        FMessageListener.shared.removeNewMessageListener()
    }
    
    //MARK:- Gallery
    
    private func showImageGallery(camera: Bool) {
        gallery = GalleryController()
        gallery.delegate = self
        Config.tabsToShow = camera ? [.cameraTab] : [.imageTab, .videoTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        Config.VideoEditor.maximumDuration = 30
        
        self.present(gallery, animated: true, completion: nil)
    }
    
}

extension MSGViewController: GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        
        //TODO:- Send photo image
        
        if images.count > 0 {
            images.first!.resolve { (image) in
                self.send(text: nil, photo: image, video: nil, audio: nil, location: nil)
            }
        }
        
        print("we have selected \(images.count)")
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        self.send(text: nil, photo: nil, video: video, audio: nil, location: nil)
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}


