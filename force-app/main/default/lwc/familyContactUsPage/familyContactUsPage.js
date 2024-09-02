import { LightningElement } from 'lwc';
import createCase from '@salesforce/apex/FamilyPortalLoginController.contactUs'; 
import userInfo from '@salesforce/apex/FamilyPortalLoginController.avtarUser'; 
import LightningAlert from 'lightning/alert';
import successMsg from '@salesforce/label/c.CQ_Contact_success_msg';
import partialFont from '@salesforce/resourceUrl/campQualityCss';
import { loadStyle } from 'lightning/platformResourceLoader';
import headerImg from '@salesforce/resourceUrl/CQ_purpalImage';
import contactus from '@salesforce/label/c.CQ_Contact_Us';
export default class FamilyContactUsPage extends LightningElement {

    reason = '--None--';
    subject = '';
    details = '';

    checkReqReason = false;
    checkReqSub = false;
    checkReqdetail = false;
    waitForRes = false;
    alertMessageFont = false;

    headerPurpalImg = headerImg;
    userFirstName = '';
    userEmail = '';
    userLastname = '';

    label = {
        contactus
    }

    storeSessionUserId;
    //Calling the function in connectedCallback
    connectedCallback(){
        this.loadMrOrangeStyles();
        if(sessionStorage.getItem('OTP') != undefined){
            this.storeSessionUserId = sessionStorage.getItem('OTP');
            this.getUserInfo();
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
    
    getUserInfo(){
        userInfo({reocrdId : this.storeSessionUserId})
            .then(result=>{
                this.userFirstName = result.FirstName;
                this.userEmail = result.Email;
                this.userLastname = result.LastName;
            })
            .catch(error=>{
                console.log(' User Error--'+ JSON.stringify(error));
            })       
    }

   
    //Handle input fields
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
    
            if (this.reason == undefined || this.reason == '--None--' || this.subject.trim() == undefined || this.subject.trim() == '' || this.details.trim() == undefined || this.details.trim() == '') {
                if (this.reason.trim() == undefined || this.reason.trim() == '--None--') {
                    this.checkReqReason = true;
                }
                if (this.subject.trim() == undefined || this.subject.trim() == '') {
                    this.checkReqSub = true;
                }
                if (this.details.trim()  == undefined || this.details.trim() == '') {
                    this.checkReqdetail = true;
                }
            }

            else {
                this.waitForRes = true;
                createCase({ subject: this.subject, details: this.details, reason: this.reason, userId : this.storeSessionUserId })
                    .then(result => {
                        if (result != '' || result != undefined) {
                            if (result.includes('Your message has')) {
                                this.handleAlertClick(successMsg);
                                this.details = '';
                                this.subject = '';
                                this.reason = '--None--';
                                this.template.querySelector('[name ="reason"]').selectedIndex = 0;
                                this.template.querySelector('[name ="details"]').value = '';
                                console.log('In the then block ')
                            }
                        }
                        this.waitForRes = false;
                    })
                    .catch(error => {
                        this.details = '';
                        this.subject = '';
                        this.reason = '--None--';
                        this.template.querySelector('[name ="reason"]').selectedIndex = 0;
                        this.waitForRes = false;
                        console.log('Find error in catch' + JSON.stringify(error));
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
            //Alert has been closed
           
        }
    
    
}