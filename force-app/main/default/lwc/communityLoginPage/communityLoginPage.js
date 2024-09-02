import { LightningElement, track, api } from 'lwc';
import logo from '@salesforce/resourceUrl/CampQuality';
import { loadStyle } from 'lightning/platformResourceLoader';
import partialFont from '@salesforce/resourceUrl/campQualityCss';
import title from '@salesforce/label/c.Camp_Quality_Title'
import userName from '@salesforce/label/c.CQ_Enter_Your_UserName';
import passWord from '@salesforce/label/c.CQ_Enter_Your_Password';
import login from '@salesforce/label/c.CQ_Login';
import passwordHelp from '@salesforce/label/c.CQ_Password_Help';
import validEmailMsg from '@salesforce/label/c.CQ_valid_Email';
import invaliduserName from '@salesforce/label/c.CQ_Invalid';
import invalidUserNameMsg from '@salesforce/label/c.CQ_username_or_passwrod_cannot_be_null';
import loginUserByOtp from '@salesforce/apex/CommunityLoginController.loginUserByOtp';
import checkUsersEmailAndPhone from '@salesforce/apex/CommunityLoginController.checkUsersEmailAndPhone';
// import createCase from '@salesforce/apex/PortalContactUs.createLoginCase'; 
//import loginContactUsPage from '@salesforce/apex/CommunityLoginController.loginContactUsPage'; 
import LightningAlert from 'lightning/alert';
import successMsg from '@salesforce/label/c.CQ_Contact_success_msg';
import headerImg from '@salesforce/resourceUrl/CQ_purpalImage';

export default class CommunityLoginPage extends LightningElement {
    // Initialize variables and resources
    campQualityLogo = logo;
    invalidUser = false;
    uservalid = false;
    blankValue = false;
    invalidValue = false
    username = '';
    password = '';
    waitForRes = false;
    resultUrl;
    resendCode = false;

    // Define labels for UI elements
    label = {
        title,
        userName,
        passWord,
        login,
        passwordHelp,
        validEmailMsg,
        invalidUserNameMsg,
        invaliduserName
    };

    userInfoWrapper = {
        userPhone: '',
        userEmail: '',
        message: ''
    }

    generatedOtp;
    userEmail = '';

    // Event handler for username input
    usernameHandler(event) {
        let user = event.target.value;
        const validRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        if (user.match(validRegex) || user == '') {
            this.uservalid = false;
        }
        else {
            this.uservalid = true;
        }
    }


    //Handling the input fields value here  
    handleInputEmail(event) {
        this.userEmail = event.target.value;
    }

    handleOtp(event) {
        this.userOtp = event.target.value;
    }

    showMobilePage = false;
    //Calling fuction on click of button and making variable true to render different screen and also calling the method to send the OTP
    mobileNext() {
        if (this.openEMailPage == true) {
            this.showEmailPage = true;
            this.showRadioBtnScreen = false;
            this.sendEmailOtp();
        }
        if (this.openMobilePage == true) {
            this.showMobilePage = true;
            this.showRadioBtnScreen = false;
            this.sendSMSOTP();
        }
    }

    mobileLastScreenPage() {

        if (this.generatedOtp == this.userOtp) {

            this.sessionSeting = sessionStorage.setItem('userId', this.userIdToStore);

            if (sessionStorage.getItem('urlParameterId') != undefined && sessionStorage.getItem('urlParameterPage') != undefined) {
                let sessionEventId = sessionStorage.getItem('urlParameter');
                window.open('/volunteer/?page=' + sessionStorage.getItem('urlParameterId') + '&Id=' + sessionEventId, '_self');
            }
            else {
                window.open('/volunteer?page=home', "_self");
            }
        }
        else {
            this.incorrectOtp = true;
        }

    }

    

    connectedCallback() {
        // Load the stylesheet when the component is connected to the DOM
        this.loadMrOrangeStyles();
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


    visibleBackBtn = false;
    showLoginPage = false;
    backBtn() {
        if (this.incorrectOtp == true) {
            this.incorrectOtp = false;
        }

        this.showLoginPage = false;
        this.visibleBackBtn = false;
        this.showRadioBtnScreen = false;
        this.showMobilePage = false;
        this.showEmailPage = false;
        // if(this.showLoginPage == false){
        //     this.visibleBackBtn = false;
        //     this.showRadioBtnScreen = false;
        //      this.showMobilePage = false;
        //      this.showEmailPage = false;
        // }               
    }

    backTLoginLink() {
        this.showLoginPage = false;
        this.showMobilePage = false;
    }



    showContactUsPage = false;



    @track radioValue = '';
    //Here we are adding the dynamic options to put inside the radio button.
    get options() {

        // Format the mobile number and Concatenate the label with the formatted mobile number
        let labelWithNumber = "Send SMS to mobile number " + this.maskPhonestr.replace(/\d(?=\d{4})/g, "*");

        let labelwithEmail = `Send to email address ${this.radioBtnLabelEmail}`
        return [
            { label: labelwithEmail, value: 'email' },
            { label: labelWithNumber, value: 'mobile' },
        ];
    }

    openEMailPage = false;
    openMobilePage = false;
    catchBackBtn = false;
    handleRadioChange(event) {
        this.radioValue = event.detail.value;
        // Call the Apex method to send OTP based on selected method
        if (this.radioValue === 'email') {
            this.openEMailPage = true;
            this.openMobilePage = false;
            // this.sendEmailOtp();
        }
        if (this.radioValue === 'mobile') {
            this.openMobilePage = true;
            this.openEMailPage = false;
            // this.sendSMSOTP();
        }
    }

    showLoginPage = false;
    showRadioBtnScreen = false;
    userIdToStore;
    getUserdetail;
    maskPhonestr;

    loginClick() {
        if (this.uservalid == true) {
            this.showRadioBtnScreen = false;
            this.showEmailPage = false;
            this.errorInloginUserByOtp = false;
        }
        else {
            // This method is used to check the user phone number and email address.         
            checkUsersEmailAndPhone({ userMail: this.userEmail })
                .then(result => {
                    if (result.message == "Do not have Volunteer permission" || result.message == "User not found") {
                        this.errorInloginUserByOtp = true;
                        this.visibleBackBtn = false;
                    }
                    else {
                        this.getUserdetail = result;
                        this.maskPhonestr = result.userPhone;
                        this.radioBtnLabelEmail = result.userEmail;
                        this.userIdToStore = result.userId;
                        console.log('-----this.userIdToStore----' + this.userIdToStore)
                        if (result.userPhone != undefined) {
                            this.showRadioBtnScreen = true;
                            if (this.showRadioBtnScreen == true) {
                                this.visibleBackBtn = true;
                                if (this.visibleBackBtn == true) {
                                    this.errorInloginUserByOtp = false;
                                }
                            }
                            this.showLoginPage = true;
                            this.resendCode = false;
                        }
                        else {
                            this.showEmailPage = true;
                            if (this.showEmailPage == true) {
                                this.visibleBackBtn = true;
                            }
                            this.showLoginPage = true;
                            this.sendEmailOtp();
                        }
                    }
                })
                .catch(error => {
                    this.errorInloginUserByOtp = true;
                    console.log('error--->' + error);
                    if (this.errorInloginUserByOtp == true) {
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
    sendEmailOtp() {
        loginUserByOtp({ userEmail: this.userEmail, deliveryMethod: 'email' })
            .then(result => {
                this.generatedOtp = result;

            })
            .catch(error => {
                // Handle errors (e.g., display an error message)
                console.error('Error:' + JSON.stringify(error));
                this.errorInloginUserByOtp = true;
                if (this.errorInloginUserByOtp == true) {
                    this.showEmailPage = false;
                    this.showLoginPage == true;
                }
            });

    }
    //This method is to used to generate OTP and send the OTP wia SMS
    sendSMSOTP() {
        // Call the Apex method to send OTP via SMS
        loginUserByOtp({ userEmail: this.userEmail, deliveryMethod: 'sms' })
            .then(result => {
                this.generatedOtp = result;
            })
            .catch(error => {
                // Handle errors (e.g., display an error message)
                this.errorInloginUserByOtp = true;
                console.log('error--->' + error);
                if (this.errorInloginUserByOtp == true) {
                    this.showEmailPage = false;
                    this.showLoginPage == false;
                }
            });
    }
    //This fuction called when we user click on the resend OTP button so here we are calling the specfic method based the variable.
    handleResendOtp() {
        this.resendCode = true;
        if (this.openEMailPage == true) {
            this.sendEmailOtp();
        }
        if (this.openMobilePage == true) {
            this.sendSMSOTP();
        }
    }

    incorrectOtp = false
    //This function called ehen user input OTP matched with system generated OTP if it matches it will redirect to the website
    emailNext() {
        if (this.generatedOtp == this.userOtp) {

            this.sessionSeting = sessionStorage.setItem('userId', this.userIdToStore);
            if (sessionStorage.getItem('urlParameter') != undefined && sessionStorage.getItem('urlParameterPage') != undefined) {
                let sessionEventId = sessionStorage.getItem('urlParameter');
                console.log('sessionEventId-------' + sessionEventId)
                window.open('/volunteer/?page=' + sessionStorage.getItem('urlParameterPage') + '&Id=' + sessionEventId, '_self');
            }
            else {
                window.open('/volunteer?page=home', "_self")
            }
        }
        else {
            this.incorrectOtp = true;
        }

    }

   



    reason = '--None--';
    subject = '';
    details = '';
    firstname = '';
    lastname = '';
    email = '';

    checkReqReason = false;
    checkReqSub = false;
    checkReqdetail = false;
    checkReqFName = false;
    checkReqLName = false;
    checkReqEmail = false;

    // waitForRes = false;
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
    detailsHandler(event) {
        this.details = event.target.value;
        if (this.details != undefined && this.details != '') {
            this.checkReqdetail = false;
        }
    }


    //Performing Action i.e, creating lead on click of the button
    submitHandler() {


        if (this.reason == undefined || this.reason == '--None--' || this.subject.trim() == undefined || this.subject.trim() == '' || this.details.trim() == undefined || this.details.trim() == ''
            || this.firstname == undefined || this.firstname.trim() == ' ' || this.lastname.trim() == undefined || this.lastname.trim() == '' || this.email.trim() == undefined || this.email.trim() == '') {

            if (this.firstname.trim() == undefined || this.firstname.trim() == '') {
                this.checkReqFName = true;
            }
            if (this.lastname.trim() == undefined || this.lastname.trim() == '') {
                this.checkReqLName = true;
            }
            if (this.email.trim() == undefined || this.email.trim() == '') {
                this.checkReqEmail = true;
            }
            if (this.reason.trim() == undefined || this.reason.trim() == '--None--') {
                this.checkReqReason = true;
            }
            if (this.subject.trim() == undefined || this.subject.trim() == '') {
                this.checkReqSub = true;
            }
            if (this.details.trim() == undefined || this.details.trim() == '') {
                this.checkReqdetail = true;
            }
        }

        else {
            this.waitForRes = true;
            loginContactUsPage({ subject: this.subject, details: this.details, reason: this.reason, email: this.email, firstName: this.firstname, lastName: this.lastname })
                .then(result => {
                    if (result != '' || result != undefined) {
                        if (result.includes('Your message has')) {
                            this.handleAlertClick(successMsg);
                            this.details = '';
                            this.subject = '';
                            this.email = '';
                            this.lastname = '';
                            this.firstname = '';
                            this.reason = '--None--';
                            this.template.querySelector('[name ="reason"]').selectedIndex = 0;
                            this.template.querySelector('[name ="details"]').value = '';
                            console.log('Method run correct');
                        }
                    }
                    else {
                        if (result.includes('Your message has')) {
                            this.handleAlertClick(successMsg);
                            this.details = '';
                            this.subject = '';
                            this.email = '';
                            this.lastname = '';
                            this.firstname = '';
                            this.reason = '--None--';
                            this.template.querySelector('[name ="reason"]').selectedIndex = 0;
                            this.template.querySelector('[name ="details"]').value = '';
                            console.log('Method run correct');
                        }
                    }
                    this.waitForRes = false;
                })
                .catch(error => {
                    this.details = '';
                    this.subject = '';
                    this.reason = '--None--';
                    this.email = '';
                    this.lastname = '';
                    this.firstname = '';
                    this.template.querySelector('[name ="reason"]').selectedIndex = 0;
                    this.waitForRes = false;
                    console.log('error1.0--->' + error);
                    console.log('error3.0--->' + JSON.stringify(error));

                })
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




    backTologinPg() {
        this.showContactUsPage = false;
        this.showLoginPage = false;
        this.showEmailPage = false;
        this.showRadioBtnScreen = false;
        this.showMobilePage = false;
        this.showLoginPage = false;
    }

    handleLinkToContactus() {
        this.showContactUsPage = true;
        this.showLoginPage = true;
        this.visibleBackBtn = false;
    }



}