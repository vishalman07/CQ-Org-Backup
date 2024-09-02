import { LightningElement } from 'lwc';
import forgetPassword from '@salesforce/apex/CommunityLoginController.forgetPassword';
import forgetPasswordTitle from '@salesforce/label/c.CQ_Forgot_password';
import resetpasswordtext from '@salesforce/label/c.CQ_reset_password';
import emailsend from '@salesforce/label/c.CQ_emailsend';
import send from '@salesforce/label/c.CQ_Send';
import cancel from '@salesforce/label/c.CQ_Cancel';
import validUserName from '@salesforce/label/c.CQ_valid_Username';
import noActiveUser from '@salesforce/label/c.CQ_No_active_user';
import userName from '@salesforce/label/c.CQ_Enter_Your_UserName';
import campQualityImg from '@salesforce/resourceUrl/CampQuality';
import LightningAlert from 'lightning/alert';
export default class CommunityForgetPage extends LightningElement {

    // Initialize variables and  static resources
    campQualityLogo = campQualityImg;
    
    isValidUser = false;
    waitForRes = false;
    forgrtPassVali = false;
    userName;
    getuserName;
    getPassword;
    noUser;
    label = {
        forgetPasswordTitle,
        resetpasswordtext,
        userName,
        validUserName,
        send,
        cancel,
        emailsend,
        noActiveUser
    };

    // Event handler for username input
    emailtoFocus(event){
        let user = event.target.value;
        const validRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
         if (user.match(validRegex) || user == '') {
            this.isValidUser = false;
        }
        else {
            this.isValidUser = true;
        }
    
    }
    emailChange(event){
        this.userName = event.target.value;  
        // if(this.userName == undefined || this.userName == ''){
        //     this.forgrtPassVali = true;
        // }
        // else{
        //     this.forgrtPassVali = false;
        // }   
    }

     // Event handler for the login button click
    loginClick(){
        this.waitForRes = true;
        if(this.userName == undefined || this.userName == ''){
            this.forgrtPassVali = true;
            this.isValidUser = false; 
            this.waitForRes = false;   
            if(this.isValidUser){      
                this.isValidUser = true;    
                this.waitForRes = false;            
            }
        }
       
        
        else{
        // Invoking the forgetPassword method with the provided username.
        forgetPassword({username : this.userName })
        .then(result=>{
            // Checking the result for different cases.
            if(result.includes('Invalid Password')){
                this.isValidUser = true;
                this.waitForRes = false; 
                this.forgrtPassVali = false;
            }
            else if(result.includes('No active user exists with Username')){
               this.noUser = true;
               this.waitForRes = false;
               this.forgrtPassVali = false;
            }
            else {
                this.waitForRes = false;
                this.forgrtPassVali = false;
                // Invoking the alert message
                this.handleAlertClick(emailsend,result); 
            }
        })
        .catch(error=>{
            this.waitForRes = false;
        })
    }
    }

    // Show a success message using Lightning Alert
    async handleAlertClick(msg,result) {       
    await LightningAlert.open({
        message: msg,
        theme: 'success', // a red theme intended for error states
        variant: 'headerless', // this is the header text
    });
    window.open(result,'_self');
    }
   
}