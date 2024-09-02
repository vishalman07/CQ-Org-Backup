import { LightningElement, api } from 'lwc';
import logo from '@salesforce/resourceUrl/CampQuality';
import title from '@salesforce/label/c.Camp_Quality_Title';
export default class PortalVerifypassword extends LightningElement {


     campQualityLogo = logo;
     invalidUser = false;
     uservalid = false;
     blankValue = false;
     invalidValue = false
     userEmail = '';
     userOtp = '';
     waitForRes = false;
     resultUrl;
     resendCode = false;

      // Define labels for UI elements
    label = {
        title
    }

    @api getOtpResponce ;

    showEmailPage = false;
    showLoginPage = false;
    backBtn(){
        
        window.open("/login");
    }

    backTLoginLink(){
        this.showLoginPage = false;
        this.showMobilePage = false;
    }

    
    value = '';

    get options() {
        return [
            { label: 'Send Email Address to ', value: 'option1' },
            { label: 'Send SMS to mobile number ', value: 'option2' },
        ];
    }

    showLoginPage = false;
    showRadioBtnScreen = false;

}