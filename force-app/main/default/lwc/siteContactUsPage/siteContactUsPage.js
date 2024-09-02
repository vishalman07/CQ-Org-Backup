import { LightningElement, wire, api } from 'lwc';
import createCase from '@salesforce/apex/CommunityLoginController.contactUs';
import userInfo from '@salesforce/apex/CommunityLoginController.avtarUser'; 
import campQualityImg from '@salesforce/resourceUrl/CampQuality';
import headerImg from '@salesforce/resourceUrl/CQ_purpalImage';
import reason from '@salesforce/label/c.CQ_Reason';
import none from '@salesforce/label/c.CQ_None';
import requestCall from '@salesforce/label/c.CQ_Request_a_call';
import requesthelp from '@salesforce/label/c.CQ_Request_help_using_My_Camp_Quality';
import event from '@salesforce/label/c.CQ_Question_about_upcoming_event_experience';
import news from '@salesforce/label/c.CQ_Share_some_news_with_us';
import volunteerDetails from '@salesforce/label/c.CQ_Update_Volunteer_Details';
import subject from '@salesforce/label/c.CQ_Subject';
import details from '@salesforce/label/c.CQ_Details';
import submit from '@salesforce/label/c.CQ_Submit_Enquiry';
import connect from '@salesforce/label/c.CQ_Connect_With_Us';
import facebook from '@salesforce/label/c.CQ_Facebook';
import twitter from '@salesforce/label/c.CQ_Twitter';
import youtube from '@salesforce/label/c.CQ_Youtube';
import instagram from '@salesforce/label/c.CQ_Instagram';
import linkedin from '@salesforce/label/c.CQ_LinkedIn';
import contact from '@salesforce/label/c.CQ_Contact_Us';
import phone from '@salesforce/label/c.CQ_Phone';
import sendMsg from '@salesforce/label/c.CQ_send_message';
import reasonError from '@salesforce/label/c.CQ_Reason_error';
import subError from '@salesforce/label/c.CQ_Subject_error';
import detailsError from '@salesforce/label/c.CQ_Details_error';
import conSucessMsg from '@salesforce/label/c.CQ_Contact_success_msg';
import home from '@salesforce/label/c.CQ_Home';
import successMsg from '@salesforce/label/c.CQ_Contact_success_msg';
//Use for navigation
import logout from '@salesforce/label/c.CQ_Logout';
import profile from '@salesforce/label/c.CQ_Profile';
import contactUs from '@salesforce/label/c.CQ_Contact_Us';
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
//Get the user data by scheme
import UserNameFIELD from '@salesforce/schema/User.Name';
import UserFirstName from '@salesforce/schema/User.FirstName';
import UserLastName from '@salesforce/schema/User.LastName';
import userEmailFld from '@salesforce/schema/User.Email';
import basePath from "@salesforce/community/basePath";
import LightningAlert from 'lightning/alert';
import partialFont from '@salesforce/resourceUrl/campQualityCss';
import { loadStyle } from 'lightning/platformResourceLoader';


export default class SiteContactUsPage extends LightningElement {
    // Importing images and labels
    campQualityLogo = campQualityImg;
    headerPurpalImg = headerImg;
    reason = '--None--';
    subject = '';
    details = '';

    label = {
        contact,
        phone,
        sendMsg,
        reason,
        none,
        requestCall,
        requesthelp,
        event,
        news,
        volunteerDetails,
        subject,
        details,
        submit,
        connect,
        facebook,
        twitter,
        youtube,
        instagram,
        linkedin,
        reasonError,
        subError,
        detailsError,
        conSucessMsg,
        logout,
        profile,
        contactUs,
        home,
        successMsg
    }

    //Declare variable and keep intial value as false 
    checkReqReason = false;
    checkReqSub = false;
    checkReqdetail = false;
    waitForRes = false;
    userFirstName = '';
    userEmail = '';
    userLastname = '';
    alertMessageFont = false;

    //Used to scroll the page at top 
    @api contactUsHandle() {
        window.scrollTo(0, 0);
    }

    storeSessionUserId;
    //Calling the function in connectedCallback
    connectedCallback(){
        console.log('The session check here');
        if(sessionStorage.getItem('userId') != undefined){
            this.storeSessionUserId = sessionStorage.getItem('userId');
            this.getUserInfo();
        }
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

    getUserInfo(){
        userInfo({reocrdId : this.storeSessionUserId})
            .then(result=>{
                console.log('---Result--->'+ result);
                console.log('---Result20--->'+ JSON.stringify(result));
                this.userFirstName = result.FirstName;
                console.log('UserFirstname----'+ this.userFirstName);
                this.userEmail = result.Email;
                this.userLastname = result.LastName;
                console.log('UserFirstname----'+ this.userLastname);
            })
            .catch(error=>{
                console.log(' User Error--'+ JSON.stringify(error));
            })       
    }

    //Handle the input values and add validation if empty
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
        if (this.reason == undefined || this.reason == '--None--' || this.subject == undefined || this.subject.trim() == '' || this.details == undefined || this.details.trim() == '') {
            if (this.reason == undefined || this.reason == '--None--') {
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
            //Create the case on click of submit button and update the record by the values in parameter
            createCase({ subject: this.subject, details: this.details, reason: this.reason, userId : this.storeSessionUserId })
                .then(result => {
                    if (result != '' || result != undefined) {
                        if (result.includes('Your message has')) {
                            //Call the method to show alert 
                            this.handleAlertClick(successMsg);
    
                            this.details = '';
                            this.subject = '';
                            this.reason = '--None--';
                            this.template.querySelector('[name ="reason"]').selectedIndex = 0;
                            this.template.querySelector('[name ="details"]').value = '';
                        }
                    }
                    this.waitForRes = false;
                })
                .catch(error => {
                    console.log('----Error 1----'+ error);
                    console.log('----Error 2----'+ JSON.stringify(error));
                    this.details = '';
                    this.subject = '';
                    this.reason = '--None--';
                    this.template.querySelector('[name ="reason"]').selectedIndex = 0;
                    this.waitForRes = false;
                })
        }       
    }
    //Dropdown Button
    get logoutLink() {
        const sitePrefix = basePath.replace(/\/s$/i, ""); // site prefix is the site base path without the trailing "/s"
        return sitePrefix + "/secur/logout.jsp";
    }
    //Get the current/Login  user data using wire decorator 
    @wire(getRecord, { recordId: Id, fields: [UserNameFIELD, userEmailFld, UserFirstName, UserLastName] })
    currentUserInfo({ error, data }) {
        if (data) {
            this.currentUserName = data.fields.Name.value;
            this.currentEmail = data.fields.Email.value;
            this.avtar = data.fields.FirstName.value.substring(0, 1) + data.fields.LastName.value.substring(0, 1);
        }
        else if (error) {
            this.error = error;
        }
    }
    dropdownClass = 'dropdown-content'; // Initial state is hidden
    toggleDropdown() {
        // Toggle the dropdown's visibility
        this.dropdownClass = this.dropdownClass === 'dropdown-content' ? 'dropdown-content show ' : 'dropdown-content';
    }
    dropdownUserClass = 'dropdown-content_User'; // Initial state is hidden
    toggleDropdownuser() {
        this.dropdownUserClass = this.dropdownUserClass === 'dropdown-content_User' ? 'dropdown-content_User show ' : 'dropdown-content_User';
    }

    //Display alert message after case is created
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