import { LightningElement, track } from 'lwc';
// Importing custom labels from Salesforce
import portalName from '@salesforce/label/c.CQ_Portal';
import newPassword from '@salesforce/label/c.CQ_New_Password';
import verifyNewPass from '@salesforce/label/c.CQ_Verify_New_Password';
import changePass from '@salesforce/label/c.CQ_Change_Password';
import errorforPassfield from '@salesforce/label/c.CQ_Error_Meassage';
import verifyPassNotMatch from '@salesforce/label/c.CQ_Verify_Pass_Not_Same';
// Importing a static resource that represents an image
import campQualityImg from '@salesforce/resourceUrl/CampQuality';
export default class CommunityChangePassword extends LightningElement {

    campQualityLogo = campQualityImg;

     // Creating an object to store custom labels
    label = {
        portalName,
        newPassword,
        verifyNewPass,
        changePass,
        errorforPassfield,
        verifyPassNotMatch      
    }

    // Initializing variables to store password-related information
    newPassword;
    verifyNewPass;
    errorfound = false;
    errorMessage = false;

    // Handling the input for the new password field
    handlePass(event){
        this.newPassword = event.target.value;       
    }

    // Handling the input for the verify password field and checking for password match
    handleVerifyPass(event){
        this.verifyNewPass = event.target.value;
        if(event.target.value !== this.newPassword){
            this.errorfound = true;
        } 
        else{
            this.errorfound = false;
        }    
    }

    // Handling the change password button click and checking for empty fields
    handleChangePass(){
        console.log(this.verifyNewPass +' : '+this.newPassword);
        if(this.verifyNewPass == undefined || this.verifyNewPass == '' || this.newPassword == undefined || this.newPassword == ''){
            this.errorMessage = true;
        }
        else{
            console.log('right');
        }
    }
}