//
//  ViewController.swift
//  Chat Clone
//
//  Created by Mohammed on 03/04/2023.
//

import UIKit
import ProgressHUD

class LoginVc: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        forgetPasswordOutlet.isHidden = true
        emailLable.text = ""
        passwordLable.text = ""
        confirmPasswordLable.text = ""
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        ConfirmPasswordTextField.delegate = self
        
        setUpBackGroundTap()
        
        
    }
    
    //MARK:- Variables
    
    var isLogin: Bool = false
    
    //MARK:- IBoutlets
    
    
    //Lables
    
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var emailLable: UILabel!
    @IBOutlet weak var passwordLable: UILabel!
    @IBOutlet weak var confirmPasswordLable: UILabel!
    @IBOutlet weak var haveAnAccountLable: UILabel!

    //TextFields
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var ConfirmPasswordTextField: UITextField!
    
    
    
    //Button Outlets
    
    @IBOutlet weak var forgetPasswordOutlet: UIButton!
    @IBOutlet weak var resendEmailOutlet: UIButton!
    @IBOutlet weak var registerOutlet: UIButton!
    @IBOutlet weak var loginOutlet: UIButton!
    
    

    //MARK:- IBaction
    
    @IBAction func forgetPasswordBtnClicked(_ sender: UIButton) {
        
        if isDataInputedFor(mode: "forgetPassword") {
            print("all data inputed correctly")
            
            forgetPassword()
            //TODO:- Reset password
        } else {
            ProgressHUD.showError("all fields are required")
        }
    }
    
    @IBAction func resendEmailBtnClicked(_ sender: UIButton) {
        print("resend email")
        
        resendVerficationEmail()
    }
    
    @IBAction func registerBtnClicked(_ sender: UIButton) {
        if isDataInputedFor(mode: isLogin ? "login" : "register") {
            
            isLogin ? loginUser() : registerUser()
            //TODO:- Login Or Register
            
            // Register
            
            
        
    }
    }
    
    
    @IBAction func loginBtnClicked(_ sender: UIButton) {
        updateUIMode(mode: isLogin)
    }
    
    private func updateUIMode(mode: Bool) {
        if !mode {
            titleLable.text = "Login"
            confirmPasswordLable.isHidden = true
            ConfirmPasswordTextField.isHidden = true
            registerOutlet.setTitle("Login", for: .normal)
            loginOutlet.setTitle("Register", for: .normal)
            haveAnAccountLable.text = "New here?"
            forgetPasswordOutlet.isHidden = false
            resendEmailOutlet.isHidden = true
        } else {
            titleLable.text = "Register"
            confirmPasswordLable.isHidden = false
            ConfirmPasswordTextField.isHidden = false
            registerOutlet.setTitle("Register", for: .normal)
            loginOutlet.setTitle("Login", for: .normal)
            haveAnAccountLable.text = "Hava an account?"
            resendEmailOutlet.isHidden = false
            forgetPasswordOutlet.isHidden = true
        }
        isLogin.toggle()
    }
    
     //MARK:- Helpers
    private func isDataInputedFor (mode: String) -> Bool {
        switch mode {
        
        case "login":
            return emailTextField.text != "" && passwordTextField.text != ""
            
        case "register":
            return emailTextField.text != "" && passwordTextField.text != nil && ConfirmPasswordTextField.text != ""
            
        case "forgetPassword":
            return emailTextField.text != ""
            
        default:
            return false
        }
    }
    
    //MARK:- Tap Gesture Recognizer
    
    private func setUpBackGroundTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    @objc func hideKeyboard () {
        view.endEditing(false)
    }
    
    //MARK:- Forget Password
    
    private func forgetPassword() {
        FUserListener.shared.resetPasswordFor(email: emailTextField.text!) { (error) in
            if error == nil {
                ProgressHUD.showSuccess("Reset Password email has been sent")
            } else {
                ProgressHUD.showFailed(error!.localizedDescription)
            }
        }
    }
    
    
    
    //MARK:- Register User
    
    private func registerUser() {
        
            if passwordTextField.text! == ConfirmPasswordTextField.text! {
                FUserListener.shared.registerUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error) in
                    if error == nil {
                        ProgressHUD.showSuccess("Verification email sent")
                    } else {
                        ProgressHUD.showError(error?.localizedDescription)
                    }
            }
        }
        
    }
    
    private func resendVerficationEmail() {
        FUserListener.shared.resendVerficationEmailWith(email: emailTextField.text!) { (error) in
            if error == nil {
                ProgressHUD.showSuccess("Verfication email sent successfuly")
            } else {
                ProgressHUD.showFailed(error!.localizedDescription)
            }
        }
    }

    
    
    //MARK:- Login User
    
    private func loginUser() {
        
        FUserListener.shared.loginUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error, isEmailVerified) in
            if error == nil {
                if isEmailVerified {
                    
                    self.goToApp()
                } else {
                    ProgressHUD.showFailed("PLZ Check Your Email and Verify Your Registration")
                }
                
            } else {
                ProgressHUD.showFailed(error!.localizedDescription)
            }
        }
        
    }
    
    //MARK:- Navigation
    
    private func goToApp() {
        let mainview = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainView") as! UITabBarController
        mainview.modalPresentationStyle = .fullScreen
        self.present(mainview, animated: true, completion: nil)
    }
    

}

//MARK:- UI Text Delegate


extension LoginVc: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        emailLable.text = emailTextField.hasText ? "Email" : ""
        passwordLable.text = passwordTextField.hasText ? "Password" : ""
        confirmPasswordLable.text = ConfirmPasswordTextField.hasText ? "Confirm Password" : ""
        
    }
}

