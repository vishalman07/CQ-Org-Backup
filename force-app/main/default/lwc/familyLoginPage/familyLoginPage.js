import { LightningElement, track } from 'lwc';
//Importing static resources, custom label and apex classes
import logo from '@salesforce/resourceUrl/CampQuality';
import title from '@salesforce/label/c.Camp_Quality_Title';
import loginUserByOtp from '@salesforce/apex/FamilyPortalLoginController.loginUserByOtp';
import checkUsersEmailAndPhone from '@salesforce/apex/FamilyPortalLoginController.checkUsersEmailAndPhone';
// import createCase from '@salesforce/apex/PortalContactUs.createLoginCase'; 
// import loginContactUsPage from '@salesforce/apex/FamilyPortalLoginController.loginContactUsPage'; 
import LightningAlert from 'lightning/alert';
import headerImg from '@salesforce/resourceUrl/CQ_purpalImage';
import partialFont from '@salesforce/resourceUrl/campQualityCss';
import { loadStyle } from 'lightning/platformResourceLoader';
export default class FamilyLoginPage extends LightningElement {
     // Initialize variables and resources
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

    //Wrapper class fields
    userInfoWrapper = {
        userPhone : '',
        userEmail : '',
        message : ''
    }

    generatedOtp;
    sessionSeting;

    //In connected call back we added this code for Google tag manager
    connectedCallback(){
        this.loadMrOrangeStyles();
        var lwr_forms = window.frames[0].window.document.querySelectorAll('.subscribe');
        lwr_forms.forEach(lwr_form_function);
        function lwr_form_function(item) {
            item.addEventListener('submit', function (event) {
                window.dataLayer.push({
                    'event': 'formSubmit',
                    'FormTarget': event.target["target"],
                    'FormId': event.target.id,
                    'FormClass': event.target.className,
                    'FormUrl': event.target.src,
                    'FormElement': event.target,
                    'FormText': event.target.innerText
                });
            });
        }  
        
    }

    loadMrOrangeStyles() {
        if (location.origin.includes('partial')) {
            loadStyle(this, partialFont + '/campqualityCss/partialFont.css')
                .then(() => {
                    // Stylesheet loaded successfully
                    console.log('font lodded');
                })
                .catch(error => {
                    // Handle error if stylesheet fails to load
                    console.error('Error loading MrOrange stylesheet: ', error);
                });
        }
        else {
            loadStyle(this, partialFont + '/campqualityCss/productionFont.css')
                .then(() => {
                    // Stylesheet loaded successfully
                    console.log('font lodded');
                })
                .catch(error => {
                    // Handle error if stylesheet fails to load
                    console.error('Error loading MrOrange stylesheet: ', error);
                });
        }
    }

   
    

    // Event handler for username input
    usernameHandler(event) {
        let user = event.target.value;
        const validRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        console.log('username : ' + user);
        if (user.match(validRegex) || user == '') {
            console.log('this');
            this.uservalid = false;
        }
        else {
            console.log('not this');
            this.uservalid = true;
        }
    }

    //Handling input value of email
    handleInputEmail(event){
        this.userEmail = event.target.value;     
    }

    //Handling input value of OTP
    handleOtp(event){
        this.userOtp = event.target.value;       
    }

    showMobilePage = false;
    //Calling fuction on click of button and making variable true to render screen and also calling the method to send the OTP
    mobileNext(){
        console.log('mobileNext function')
        if(this.openEMailPage == true){
            this.showEmailPage = true;
            this.showRadioBtnScreen = false;  
            this.sendEmailOtp();   
        }
        if(this.openMobilePage == true){
            this.showMobilePage = true;
            console.log('Mobile Next click')
            this.showRadioBtnScreen = false;
            this.sendSMSOTP();
        }
    }

    mobileLastScreenPage(){   

        if(this.generatedOtp == this.userOtp){
            console.log('Verified OTP');
            this.sessionSeting = sessionStorage.setItem('OTP', this.userIdToStore);
            if(sessionStorage.getItem('urlParameter') != undefined && sessionStorage.getItem('urlParameterPage') != undefined){
                let sessionEventId = sessionStorage.getItem('urlParameter');
              //  window.open('/family/?page='+sessionStorage.getItem('urlParameterPage')+'&Id='+ sessionEventId , '_self');
                const originalUrl = sessionStorage.getItem('allUpdateYes');
                // console.log('--Line--333-'+ sessionStorage.getItem('allUpdateYes'));
                // window.open(originalUrl, "_self")
                if(originalUrl !=undefined){
                    const originalUrl = sessionStorage.getItem('allUpdateYes');
                    console.log('--Line--148-'+ sessionStorage.getItem('allUpdateYes'));
                    window.open(originalUrl, "_self");
                }
                else{
                    window.open('/family', "_self");
                }
            }
            else{
                // window.open('/family', "_self");
                const originalUrl = sessionStorage.getItem('allUpdateYes');
                if(originalUrl){
                    window.open(originalUrl, "_self");
                }
                else{
                    window.open('/family', "_self");
                }
                
            }
            
        } 
        else{
            this.incorrectOtp = true;
        }
    }     

    visibleBackBtn = false;
    showLoginPage = false;

    //This method is called when user click on back button it will redirect to login page.
    backBtn(){
        if(this.incorrectOtp == true){
            this.incorrectOtp = false;
        }       
        this.showLoginPage = false;
        this.showEmailPage = false;
        // this.visibleBackBtn = false;
        // this.showRadioBtnScreen = false;
        // this.showMobilePage = false;
        // this.showEmailPage = false;
        if(this.showLoginPage == false){
            this.visibleBackBtn = false;
            this.showRadioBtnScreen = false;
             this.showMobilePage = false;
             this.showEmailPage = false;
        }               
    }
  
    @track radioValue = '';
    //Here we are adding the dynamic options to put inside the radio button.
    get options() {

        let maskNo = this.maskPhonestr.replace(/\s+/g, '');
        // Format the mobile number and Concatenate the label with the formatted mobile number
        let labelWithNumber = "Send SMS to mobile number " + maskNo.replace(/\d(?=\d{4})/g, "*");

        let  labelwithEmail = `Send to email address ${this.radioBtnLabelEmail}`
        return [
            { label: labelwithEmail, value: 'email' },
            { label: labelWithNumber, value: 'mobile' },
        ];
    }


    openEMailPage = false;
    openMobilePage = false;
    catchBackBtn = false;
    handleRadioChange(event){
        this.radioValue = event.detail.value;
         // Call the Apex method to send OTP based on selected method
        if(this.radioValue === 'email') {
            this.openEMailPage = true;
            this.openMobilePage = false;
            
        } 
        if (this.radioValue === 'mobile') {
            this.openMobilePage = true;
            this.openEMailPage = false;
        }
    }

    showLoginPage = false;
    showRadioBtnScreen = false;
    userIdToStore;
    getUserdetail;
    maskPhonestr;
    loginClick(){
        if(this.uservalid == true){
            console.log('Console log Family Login')
            this.showRadioBtnScreen = false;
            this.showEmailPage = false;
            this.errorInloginUserByOtp = false;
        }
        else{ 
            console.log('Event check');     
        // This method is used to check the user phone number and email address.         
        checkUsersEmailAndPhone({userMail : this.userEmail})
        .then(result=>{
            if(result.message == "Do not have family permission" || result.message == "User not found"){
                this.errorInloginUserByOtp = true;
                this.visibleBackBtn = false;
            }
            else{
                this.getUserdetail = result;
                this.maskPhonestr = result.userPhone;
                this.radioBtnLabelEmail = result.userEmail;
                this.userIdToStore = result.userId;
                if(result.userPhone != undefined){
                        this.showRadioBtnScreen = true;
                        if(this.showRadioBtnScreen == true){
                            this.visibleBackBtn = true;
                            if(this.visibleBackBtn == true){
                                this.errorInloginUserByOtp = false;
                            }
                        }
                        this.showLoginPage = true;
                        this.resendCode = false;         
                }           
                else{                                          
                        this.showEmailPage = true;
                        if(this.showEmailPage == true){
                            this.visibleBackBtn = true;
                        }
                        this.showLoginPage = true;
                        this.sendEmailOtp();
                 }
            }
        })
        .catch(error=>{
            this.errorInloginUserByOtp = true;
            if(this.errorInloginUserByOtp == true){
                this.showEmailPage = false;
                this.showshowEmailPage == false;
                this.showLoginPage == true;
            }
            this.catchBackBtn = true
        }) 
        }        
        
    }

    errorInloginUserByOtp = false;
    //This method is to used to generate OTP and send the OTP in the  user email address.
    sendEmailOtp(){
        loginUserByOtp({userEmail : this.userEmail , deliveryMethod: 'email' })  
                  .then(result=>{
                      this.generatedOtp = result;                        
                  })    
                  .catch(error => {
                 // Handle errors (e.g., display an error message)
                  console.error('Error:'+ JSON.stringify(error));
                  this.errorInloginUserByOtp = true;
                  if(this.errorInloginUserByOtp == true){
                    this.showEmailPage = false;
                    this.showLoginPage == true;
                }
                });   
        
    }

    //This method is to used to generate OTP and send the OTP in the user wia SMS.  
    sendSMSOTP() {
        // Call the Apex method to send OTP via SMS
        loginUserByOtp({userEmail : this.userEmail , deliveryMethod: 'sms'})
        .then(result=>{
            this.generatedOtp = result;
        })    
        .catch(error => {
        // Handle errors (e.g., display an error message)
        this.errorInloginUserByOtp = true;
        if(this.errorInloginUserByOtp == true){
            this.showEmailPage = false;
            this.showLoginPage == false;
        }
      });   
    }

    
    //This fuction called when we user click on the resend OTP button so here we are calling the specfic method based the variable.
    handleResendOtp(){
        console.log('Resend OTP')
        this.resendCode = true;
        if(this.openEMailPage == true){
            this.sendEmailOtp();  
        }
        if(this.openMobilePage == true){
            this.sendSMSOTP();
        }

    }

    incorrectOtp = false
    //This function called ehen user input OTP matched with system generated OTP if it matches it will redirect to the website
    emailNext(){        
        if(this.generatedOtp == this.userOtp){
            this.sessionSeting = sessionStorage.setItem('OTP', this.userIdToStore);
            if(sessionStorage.getItem('urlParameter') != undefined && sessionStorage.getItem('urlParameterPage') != undefined){
                let sessionEventId = sessionStorage.getItem('urlParameter');
                // window.open('/family/?page='+sessionStorage.getItem('urlParameterPage')+'&Id='+ sessionEventId , '_self');
                const originalUrl = sessionStorage.getItem('allUpdateYes');
                if(originalUrl){
                    // const originalUrl = sessionStorage.getItem('allUpdateYes');
                window.open(originalUrl, "_self");
                }
                else{
                    window.open('/family', "_self");
                }
             
            }
            else{
                // window.open('/family', "_self");
                const originalUrl = sessionStorage.getItem('allUpdateYes');
                if(originalUrl !=undefined){
                    window.open(originalUrl, "_self");
                }
                else{
                    window.open('/family', "_self");
                }
                
            }
        }      
        else{
            this.incorrectOtp = true;
        }

    }
    


    reason = '--None--';
    subject = '';
    details = '';
    firstname='';
    lastname='';
    email='';

    checkReqReason = false;
    checkReqSub = false;
    checkReqdetail = false;
    checkReqFName = false;
    checkReqLName=false;
    checkReqEmail=false;
    alertMessageFont = false;

    headerPurpalImg = headerImg;


    firstNameHandler(event) {
        this.firstname = event.target.value;

        if (this.firstname != undefined && this.firstname != '') {
            this.checkReqFName = false;
        }
    }
    lastNameHandler(event) {
        this.lastname = event.target.value;

        if (this.lastname != undefined && this.lastname != '') {
            this.checkReqLName = false;
        }
    }

    emailHandler(event) {
        this.email = event.target.value;

        if (this.email != undefined && this.email != '') {
            this.checkReqEmail = false;
        }
    }

    reasonHandler(event) {
        this.reason = event.target.value;
        if (this.reason !== '--None--') {
            this.checkReqReason = false;
        }
    }
    subjectHandler(event) {
        this.subject = event.target.value;

        if (this.subject != undefined && this.subject != '') {
            this.checkReqSub = false;
        }
    }
    detailsHandler(event){
        this.details = event.target.value;
        if (this.details != undefined && this.details != '') {
            this.checkReqdetail = false;
        }
    }





        async handleAlertClick(msg) {
            this.alertMessageFont = true;
            await LightningAlert.open({
                message: msg,
                theme: 'success', // a red theme intended for error states
                variant: 'headerless', // this is the header text
            });

        }
    

  

    showContactUsPage = false;
    backTologinPg(){
        this.showContactUsPage = false;
        this.showEmailPage = false;
        this.showRadioBtnScreen = false;
        this.showMobilePage = false;
        this.showLoginPage = false;
    }

    handleLinkToContactus(){
        this.showContactUsPage = true;
        this.showLoginPage = true;
         this.visibleBackBtn = false;
    }

   
    
}