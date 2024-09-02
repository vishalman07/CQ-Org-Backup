import { LightningElement, wire, track, api } from 'lwc';
import locationInProfile from '@salesforce/apex/CommunityProfilePageController.locationInProfile';
import createCase from '@salesforce/apex/CommunityLoginController.contactUs';
import getProfile from '@salesforce/apex/CommunityProfilePageController.getProfiledata';
import saveProfile from '@salesforce/apex/CommunityProfilePageController.saveData';
import userAvatar from '@salesforce/apex/CommunityProfilePageController.userAvatar';
import uploadImage from '@salesforce/apex/CommunityProfilePageController.imageUpload';
import volunteerPro from '@salesforce/label/c.CQ_Volunteer_Profile';
import cardExpires from '@salesforce/label/c.CQ_children_card_expires';
import detailsNotAvl from '@salesforce/label/c.CQ_volunteerSkillDetails';
import editBtn from '@salesforce/label/c.CQ_Edit';
import emailAdd from '@salesforce/label/c.CQ_Email_Address';
import homePh from '@salesforce/label/c.CQ_Home_Phone';
import swimAbility from '@salesforce/label/c.CQ_Swimming_Ability';
import address from '@salesforce/label/c.CQ_Address';
import mobilePh from '@salesforce/label/c.CQ_Mobile_Phone';
import shirtSize from '@salesforce/label/c.CQ_Shirt_Size';
import suburb from '@salesforce/label/c.CQ_Suburb';
import eventLocation from '@salesforce/label/c.CQ_Preferred_Event_Locations';
import imgPermission from '@salesforce/label/c.CQ_Image_Permissions';
import photoApprove from '@salesforce/label/c.CQ_Photo_Approve';
import state from '@salesforce/label/c.CQ_State';
import notApprove from '@salesforce/label/c.CQ_If_photo_not_Approve';
import postCode from '@salesforce/label/c.CQ_Postcode';
import moreInfo from '@salesforce/label/c.CQ_More_Info';
import privacyUrl from '@salesforce/label/c.CQ_Privacy_URL';
import dietaryReq from '@salesforce/label/c.CQ_Dietary_Requirements';
import specNeeds from '@salesforce/label/c.CQ_Special_Needs';
import description from '@salesforce/label/c.CQ_Description';
import comments from '@salesforce/label/c.CQ_Comments';
import dietarybtn from '@salesforce/label/c.CQ_Add_Dietary_Requirement_btn';
import specianlNeedbtn from '@salesforce/label/c.CQ_Add_Special_Need_btn';

import currentVoluType from '@salesforce/label/c.CQ_Current_Volunteer_Types';
import CQtype from '@salesforce/label/c.CQ_Type';
import Status from '@salesforce/label/c.CQ_Status';
import saveYourChg from '@salesforce/label/c.CQ_save_your_changes';
import updateOtherDetail from '@salesforce/label/c.CQ_update_any_other_details';
import errorMsg from '@salesforce/label/c.CQ_Error_Meassage';
import verfiPassNotsame from '@salesforce/label/c.CQ_Verify_Pass_Not_Same';
import profileUpdatedBtn from '@salesforce/label/c.CQ_Profile_Updated';


// static resource URL for the image.
import avatar from '@salesforce/resourceUrl/CQAssetAvatar';
import headerTopImg from '@salesforce/resourceUrl/CQ_headerYellowTop';
//Imports for the picklist values.
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import INDUSTRY_FIELD from '@salesforce/schema/Special_Needs__c.Long_Description__c';
import shirtSizePick from '@salesforce/schema/Contact.Shirt_Size__c';
import swimAbilityPick from '@salesforce/schema/Contact.Swimming_Ability__c';


//Use for navigation
import logout from '@salesforce/label/c.CQ_Logout';
import profile from '@salesforce/label/c.CQ_Profile';
import contactUs from '@salesforce/label/c.CQ_Contact_Us';
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import UserNameFIELD from '@salesforce/schema/User.Name';
import UserFirstName from '@salesforce/schema/User.FirstName';
import UserLastName from '@salesforce/schema/User.LastName';
import userEmailFld from '@salesforce/schema/User.Email';
import basePath from "@salesforce/community/basePath";

//Labels
import home from '@salesforce/label/c.CQ_Home';
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
import phone from '@salesforce/label/c.CQ_Phone';
import sendMsg from '@salesforce/label/c.CQ_send_message';
import reasonError from '@salesforce/label/c.CQ_Reason_error';
import subError from '@salesforce/label/c.CQ_Subject_error';
import detailsError from '@salesforce/label/c.CQ_Details_error';
import conSucessMsg from '@salesforce/label/c.CQ_Contact_success_msg';
import successMsg from '@salesforce/label/c.CQ_Contact_success_msg';
import shareOption from '@salesforce/label/c.CQ_Image_Sharing_Option';
import allowPhoto from '@salesforce/label/c.CQ_allow_Photo_Video_to_share';
import ortick from '@salesforce/label/c.CQ_or_Tick';
import sharedPhoto from '@salesforce/label/c.CQ_shared_photo_by_participants';
import allowPromote from '@salesforce/label/c.CQ_allow_to_Promote_charitable_purposes';
import allowCorporate from '@salesforce/label/c.CQ_allow_to_corporate_partners';
import LightningAlert from 'lightning/alert';
import partialFont from '@salesforce/resourceUrl/campQualityCss';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class CommunityProfilePage extends LightningElement {

    imgTopyellow = headerTopImg;
    //Custom label store in object
    label = {
        shareOption,
        allowPhoto,
        ortick,
        sharedPhoto,
        allowPromote,
        allowCorporate,
        logout,
        profile,
        contactUs,
        detailsNotAvl,
        home,
        volunteerPro,
        cardExpires,
        editBtn,
        emailAdd,
        homePh,
        swimAbility,
        address,
        mobilePh,
        shirtSize,
        suburb,
        eventLocation,
        imgPermission,
        photoApprove,
        state,
        notApprove,
        postCode,
        moreInfo,
        privacyUrl,
        dietaryReq,
        specNeeds,
        description,
        comments,
        dietarybtn,
        specianlNeedbtn,
        currentVoluType,
        CQtype,
        Status,
        saveYourChg,
        updateOtherDetail,
        errorMsg,
        verfiPassNotsame,
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
        successMsg
    }
    //Wrapper class variables for holding volunteer information.
    @track volunteerData = {
        emailAddress: '',
        homePhone: '',
        swimmingAbility: '',
        address: '',
        mobilePhone: '',
        shirtSize: '',
        suburb: '',
        preferredEventLocations: '',
        state: '',
        postcode: '',
        expires:'',
        imagePermissionCheckBox: false,
        imageSharedParticipantsCheckBox: false,
        imageSharedPromoteWithCharitable: false,
        imagepromoteCorporatePartners: false,
        imageBelowways : false,
        dietList: [],
        speNeedList: [],
        speNeedDelete:[],
        volList : [],
    };

    editBtnforSave = true;
    waitForRes = true;
    addDietaryReqVar = 0;
    addSpecialNeedVar = 0;
    value = '';
    fileType;
    fileData;
    avatarofUser = avatar;
    checkedPermission = false;
    getVoluntearExpire;
    commentNullError = false;
    dietcommentNullError = false;

    checkReqReason = false;
    checkReqSub = false;
    checkReqdetail = false;
    reason = '--None--';
    subject = '';
    details = '';

    //Counter variable to track the index of the special needs and dietary list.
    @track keyIndex = 0;
    @track itemList = [
        // {
        //     id: 0,
        //     specNeedDescription: '',
        //     specNeedComment: ''
        // }
    ]; 
    @track keyIndexdiet = 0;
    @track itemListDiet = [
        // {
        //     id: 0,
        //     dietDescription: '',
        //     dietComment: ''
        // }
    ];

    //Declare variable
    addingRow = false;
    expiresDate ;
    hideVoltypeStatus = false;
    @track diet = [];
    @track specNeedsPick = [];
    @track preferredLocation = [];
    @track selectedPreferredLocations = [];
    error;
  

    //By default disble the all types of fields and checkbox
    @api handledisabled(){
        this.template.querySelectorAll('input[data-id=disable]').forEach(item => {
            item.disabled = true;
        })
        this.template.querySelectorAll('input[data-id=disableOr]').forEach(item => {
        item.disabled = true;
        })
        this.template.querySelectorAll('lightning-dual-listbox[data-id=disableDualListBoxId]').forEach(ele => {
            ele.disabled = true;
        })
        this.template.querySelectorAll('lightning-combobox[data-id=disableComboId]').forEach(elem => {
            elem.disabled = true;
        })
        this.template.querySelectorAll('textarea[data-id=disabletextArea]').forEach(elem => {
            elem.disabled = true;
        })
        this.template.querySelectorAll('input[data-id=imageData]').forEach(elem => {
            elem.disabled = true;
        })
        window.scrollTo(0, 0);
    }

    // Wire service to fetch picklist values for the Special Needs Long description field
    @wire(getPicklistValues, {
        recordTypeId: '01228000000iUeuAAE', // Default record type Id
        fieldApiName: INDUSTRY_FIELD
    })
    getPicklistValuesDiet({ error, data }) {
        if (data) {
            let valueList = [];
            data.values.forEach(item => {
                valueList.push({ label: item.label, value: item.value });
            });
            this.specNeedsPick = valueList;
        } else if (error) {
            // Handle error
        }
    }

       @wire(getPicklistValues, {
        recordTypeId: '01228000000iUetAAE', // Default record type Id
        fieldApiName: INDUSTRY_FIELD
    })
    getPicklistValuesSpecialNeed({ error, data }) {
        if (data) {
            let specialNeed = [];
            data.values.forEach(item => {
                specialNeed.push({ label: item.label, value: item.value });
            });
            this.diet = specialNeed;
        } else if (error) {
            // Handle error
        }
    }





    storeSessionUserId;
    //Calling the function in connectedCallback
    connectedCallback(){
        this.fetchingLocationByWire();
        if(sessionStorage.getItem('userId') != undefined){
            this.storeSessionUserId = sessionStorage.getItem('userId');
            this.getProfileInfo();
            this.fetchingAvatar();
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

    @track hideSpecialNeedFields = false;
    @track hideDietFields = false;
    getProfileInfo(){
        //Call the getProfile Apex method to fetch profile information
        getProfile({recUserId : this.storeSessionUserId})
        .then(data=>{
            // Parse the JSON data received from the Apex method
            const result = JSON.parse(data);
            this.waitForRes = false;
            // Update the volunteerData object with the fetched profile information
            this.volunteerData.emailAddress = result.emailAddress;
            this.volunteerData.homePhone = result.homePhone;
            this.volunteerData.swimmingAbility = result.swimmingAbility;
            this.volunteerData.address = result.address;
            this.volunteerData.mobilePhone = result.mobilePhone;
            this.volunteerData.shirtSize = result.shirtSize;
            this.volunteerData.suburb = result.suburb;
            this.volunteerData.volList = result.volList;
            // Format and update the 'expires' and 'getVoluntearExpire' properties
            if(result.expires){
            // Create a Date object from the input string
            const inputDate = new Date(result.expires);

            // Define an array for month names
            const monthNames = [
                'January', 'February', 'March', 'April', 'May', 'June', 'July',
                'August', 'September', 'October', 'November', 'December'
            ];

            // Get the day, month, and year from the Date object
            const day = inputDate.getDate();
            const month = (inputDate.getMonth() + 1).toString().padStart(2, '0');
            const year = inputDate.getFullYear();

            // Function to get the day suffix (e.g., '1st', '2nd', '3rd', '4th', etc.)
            function getDaySuffix(day) {
                if (day >= 11 && day <= 13) {
                    return day + 'th';
                }
                switch (day % 10) {
                    case 1: return day + 'st';
                    case 2: return day + 'nd';
                    case 3: return day + 'rd';
                    default: return day + 'th';
                }
            }

            // Construct the formatted date string
             this.volunteerData.expires = result.expires;
            //  this.getVoluntearExpire = `${getDaySuffix(day)} of ${month} ${year}`;
            this.getVoluntearExpire = `${day}/${month}/${year}`
            }
             // Populate the 'selectedPreferredLocations' array based on the fetched data
            if (result.preferredEventLocations != null && result.preferredEventLocations != '') {
                if (result.preferredEventLocations.includes(';')) {
                    result.preferredEventLocations.split(';').forEach(item => {
                        this.selectedPreferredLocations.push(item);
                    })
                }
                else {
                    this.selectedPreferredLocations.push(result.preferredEventLocations);
                }
            }
            this.volunteerData.preferredEventLocations = result.preferredEventLocations;
            this.volunteerData.state = result.state;
            this.volunteerData.postcode = result.postcode;
            this.volunteerData.imagePermissionCheckBox = result.imagePermissionCheckBox;
            if(this.volunteerData.imagePermissionCheckBox == true){
                this.checkedPermission = true;
            }
            this.volunteerData.imageBelowways = result.imageBelowways
            this.volunteerData.imageSharedParticipantsCheckBox = result.imageSharedParticipantsCheckBox;
            this.volunteerData.imageSharedPromoteWithCharitable = result.imageSharedPromoteWithCharitable;
            this.volunteerData.imagepromoteCorporatePartners = result.imagepromoteCorporatePartners;
            // Populate 'dietList' and 'itemListDiet' based on fetched data
            this.volunteerData.dietList = result.dietList;         
            if (this.volunteerData.dietList != null  ) {
                this.itemListDiet = this.volunteerData.dietList;
                console.log('this.itemListDiet------'+this.itemListDiet)
            }
            else{
                console.log('Update  dietlistis is null---->')
                this.hideDietFields = true;
                this.addButtonVisibleSp = true;
            }
            this.volunteerData.speNeedList = result.speNeedList;
            if (this.volunteerData.speNeedList != null) {
                this.itemList = this.volunteerData.speNeedList;
                console.log('this.itemList speci==='+ this.itemList);
            }
            else{
                console.log('itemList else===');
                this.hideSpecialNeedFields = true;
                this.addButtonVisible = true;
                console.log('Update  dietlistis is null---->')
            }
        console.log('itemList out===');

            //Disble all the fields 
            setTimeout(() =>{
                this.template.querySelectorAll('input[data-id=disable]').forEach(item => {
                    item.disabled = true;
                })           
                this.template.querySelectorAll('lightning-dual-listbox[data-id=disableDualListBoxId]').forEach(ele => {
                    ele.disabled = true;
                })
                this.template.querySelectorAll('lightning-combobox[data-id=disableComboId]').forEach(elem => {
                    elem.disabled = true;
                })
                this.template.querySelectorAll('textarea[data-id=disabletextArea]').forEach(elem => {
                    elem.disabled = true;
                })
                this.template.querySelectorAll('input[data-id=imageData]').forEach(elem => {
                    elem.disabled = true;
                })
                if(this.volunteerData.imageBelowways == true){
                    this.template.querySelectorAll('input[data-id=disableOr]').forEach(elem => {
                        elem.disabled = true;                      
                    })
                }
            }, )
        })
        .catch(error=>{
        })
    }
 


    // Method to fetch the user's avatar using the userAvatar Apex method
    fetchingAvatar(){
        userAvatar({recUserId : this.storeSessionUserId})
        .then(data=>{
            if(data != null && data != undefined){
            // Update the 'avatarofUser' property with the base64 image data
            this.avatarofUser = 'data:image/png;base64,' + data;
            }
            else {
                // Set a default avatar image if data is not available
                this.avatarofUser = avatar;  
            }
        })
        .catch(error=>{
            this.avatarofUser = avatar;
        })
    }
   
    // Method to fetch preferred locations using the locationInProfile Apex method
    fetchingLocationByWire(){
        locationInProfile()
        .then(data=>{
            // Process the received data and create an array of objects for Lightning Combobox
            data.forEach(item => {
                this.preferredLocation.push({ label: item, value: item });
            });
        })      
        .catch(error=>{
        })
    }
    // Function to handle changes in multi-select preferred locations
    handleMultiSelect(event) {
        this.selectedPreferredLocations = event.detail.value;
    }
    // Function to handle changes in diet combo boxes

    
    handleChangediet(event) {
        const recordId = event.target.dataset.recordid;
        const selectedValue = event.target.value;
        if (event.target.name === 'dietName') {
            // Find the item in itemListDiet with the matching recordId
            let itemToUpdate = this.itemListDiet.find(item => item.id == recordId);

            if (itemToUpdate) {
                // Update the dietDescription property of the item
                itemToUpdate.dietDescription = selectedValue;
                if(selectedValue !=''){
                    this.dietDescNullError =false;
                }
                // You may want to update itemListDiet to trigger reactivity in the template
                this.itemListDiet = [...this.itemListDiet];
            }
        }
        if (event.target.name === 'dietComment') {
            // Find the item in itemListDiet with the matching recordId
            let itemToUpdate = this.itemListDiet.find(item => item.id == recordId);
            if (itemToUpdate) {
                // Update the dietComment property of the item
                itemToUpdate.dietComment = selectedValue;
                if(selectedValue !=''){
                    this.dietcommentNullError = false;
                }
                // You may want to update itemListDiet to trigger reactivity in the template
                this.itemListDiet = [...this.itemListDiet];
            }
        }
    }
    // Function to handle changes in special needs combo boxes
    
    handleChange(event) {
        let recordId = event.target.dataset.recordid;
        let selectedValueNeed = event.target.value;
        if (event.target.name === 'speNeedDes') {
             // Find the item in itemListDiet with the matching recordId
            let itemToUpdate = this.itemList.find(item => item.id == recordId);

            if (itemToUpdate) {
                // Update the dietDescription property of the item
                itemToUpdate.specNeedDescription = selectedValueNeed;
                if(selectedValueNeed !=''){
                    this.spNeedDescNullError = false;
                }
                // You may want to update itemListDiet to trigger reactivity in the template
                this.itemList = [...this.itemList];
            }
        }


        if (event.target.name === 'speNeedCom') {
             // Find the item in itemListDiet with the matching recordId
            let itemToUpdate = this.itemList.find(item => item.id == recordId);

            if (itemToUpdate) {
                // Update the dietComment property of the item
                itemToUpdate.specNeedComment = selectedValueNeed;
                if(selectedValueNeed !=''){
                    this.commentNullError =false;
                }
                // You may want to update itemListDiet to trigger reactivity in the template
                this.itemList = [...this.itemList];
            }
        }
    }

    //Validation error if the reason, subject, details are empty
    reasonHandler(event) {
        this.reason = event.target.value;
        if(this.reason !== '--None--'){
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

    submitHandler() {
        if (this.reason == undefined || this.reason == '--None--' || this.subject == undefined || this.subject.trim() == '' || this.details == undefined || this.details.trim() == '') {
            if (this.reason == undefined || this.reason == '--None--') {
                this.checkReqReason = true;
            }
             if (this.subject == undefined || this.subject.trim() == '') {
                this.checkReqSub = true;
            }
            if(this.details == undefined || this.details.trim() == '') {
                this.checkReqdetail = true;
            }
        }
        else {
            this.waitForRes = true;
            //On click of submit we create the case in backend
            createCase({ subject: this.subject, details: this.details, reason: this.reason, userId : this.storeSessionUserId })
                .then(result => {
                    if(result != '' || result != undefined ){
                        if (result.includes('Your message has')) {
                        // Display success message
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
                    // Reset form fields and handle errors
                    this.details = '';
                    this.subject = '';
                    this.reason = '--None--';
                    this.template.querySelector('[name ="reason"]').selectedIndex = 0;
                    this.template.querySelector('[name ="details"]').value = '';
                    this.waitForRes = false;
                })
        }       
    }
    // Display alert after case created/Save in backend
    async handleAlertClick(msg) {
    await LightningAlert.open({
        message: msg,
        theme: 'success', 
        variant: 'headerless', // this is the header text
    });
    
    }


    //Dropdown Button
    get logoutLink() {
        const sitePrefix = basePath.replace(/\/s$/i, ""); // site prefix is the site base path without the trailing "/s"
        return sitePrefix + "/secur/logout.jsp";
    }

    // Wire adapter to fetch current user information
    @wire(getRecord, { recordId: Id, fields: [UserNameFIELD, userEmailFld, UserFirstName, UserLastName] })
    currentUserInfo({ error, data }) {
        if (data) {
            // Get and set current user information
            this.currentUserName = data.fields.Name.value;
            this.currentEmail = data.fields.Email.value;
            // Generate avatar from first letters of first and last name
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

    //Make the all the input fields updatable on click of edit button 
    handleEdit() {
        this.editBtnforSave = false;
        this.hideDietFields = false;
        this.hideSpecialNeedFields = false;
        this.template.querySelectorAll('input[data-id=disable]').forEach(item => {
            item.disabled = false;
        })
        this.template.querySelectorAll('lightning-dual-listbox[data-id=disableDualListBoxId]').forEach(ele => {
            ele.disabled = false;
        })
        this.template.querySelectorAll('lightning-combobox[data-id=disableComboId]').forEach(elem => {
            elem.disabled = false;
        })
        this.template.querySelectorAll('textarea[data-id=disabletextArea]').forEach(elem => {
            elem.disabled = false;
        })
        this.template.querySelectorAll('input[data-id=imageData]').forEach(elem => {
            elem.disabled = false;
        })

        if(this.volunteerData.imageBelowways == true){
            this.template.querySelectorAll('input[data-id=disableOr]').forEach(item => {
                item.disabled = true;
            })
        }
        else{
            this.template.querySelectorAll('input[data-id=disableOr]').forEach(item => {
                item.disabled = false;
            })
        }
    }

    dietDescNullError = false;
    spNeedDescNullError = false;
    // Method to handle the save action
    handleSave() {
        this.editBtnforSave = true;
        if(this.itemList.length < 0){           
            this.hideSpecialNeedFields = true;
        }
         if(this.itemListDiet.length < 0){
            this.hideDietFields = true;
         }
        // Upload image if fileData is available
        if (this.fileData != undefined) {
            this.uploadImage(); // Call the method to handle image upload
        }
        // Construct preferred locations string
        let location = '';
        if (this.selectedPreferredLocations != undefined && this.selectedPreferredLocations != null) {
            this.selectedPreferredLocations.forEach(item => {
                location = location + ';' + item;
            })
            location = location.substring(1);
        }
        this.volunteerData.preferredEventLocations = location;
        // Update volunteer data for diet and special needs
        this.volunteerData.dietList = this.itemListDiet;
        this.volunteerData.speNeedList = this.itemList;

        // let count = 0;
        // let countSp = 0;
        // // Checking if 'dietList' and 'speNeedList' are defined and not null
        // if ((this.volunteerData.dietList != undefined || this.volunteerData.dietList != null) && (this.volunteerData.speNeedList != undefined || this.volunteerData.speNeedList != null)) {
        //     // Looping through 'dietList' to check for empty comments
        //     this.volunteerData.dietList.forEach(item => {
        //         if (item.dietComment.trim() == '' || item.dietComment.trim() == null) {
        //             count += 1;
        //         }
        //     })
        //     // Looping through 'speNeedList' to check for empty comments
        //     this.volunteerData.speNeedList.forEach(item => {
        //         if (item.specNeedComment.trim() == '' || item.specNeedComment.trim() == null) {
        //             countSp += 1;
        //         }
        //     })
        //     // Checking if there are any empty comments if they empty show error else don't show error
        //     if (count > 0) {
        //         this.dietcommentNullError = true;
        //     }
        //     else {
        //         this.dietcommentNullError = false;
        //     }

        //     if (countSp > 0) {
        //         this.commentNullError = true;
        //     }
        //     else {
        //         this.commentNullError = false;
        //     }
        // }

        // let countDiet = 0;
        // if(this.volunteerData.dietList != undefined || this.volunteerData.dietList != null){
        //     this.volunteerData.dietList.forEach(item=>{
        //         if(item.dietDescription == '' || item.dietDescription == null){
        //             countDiet +=1;
        //         }
        //     })
            
        // }
        // if(countDiet > 0){
        //     this.dietDescNullError = true;
        // }

        // let countSpNeed = 0;
        // if(this.volunteerData.speNeedList !=  undefined || this.volunteerData.speNeedList != null){
        //     this.volunteerData.speNeedList.forEach(item=>{
        //         if(item.specNeedDescription == '' || item.specNeedDescription == null ){
        //             countSpNeed +=1;
        //         }
        //     })
        // }

        // if(countSpNeed > 0){
        //     this.spNeedDescNullError = true;
        // }

        this.waitForRes = true
        // Call the saveProfile Apex method
        if(this.volunteerData.dietList == null){
            this.volunteerData.dietList = [];
        }
        if(this.volunteerData.speNeedList == null){
            this.volunteerData.speNeedList = [];
        }
        saveProfile({jsonStr: JSON.stringify(this.volunteerData) , recUserId : this.storeSessionUserId})
        .then(result => {
            this.waitForRes = false;
            // Handle success with an alert
            this.keyIndex = 0;
            this.keyIndexdiet = 0;
            this.handleAlertClick(profileUpdatedBtn);
            console.log('Result--->'+ result);
        })
        .catch(error => {
            this.waitForRes = false;
            console.log('error---------'+ JSON.stringify(error));
        })
    
      
        this.editBtnforSave = true;
        this.template.querySelectorAll('input[data-id=disable]').forEach(item => {
            item.disabled = true;
        })
        this.template.querySelectorAll('input[data-id=disableOr]').forEach(item => {
        item.disabled = true;
        })
        this.template.querySelectorAll('lightning-dual-listbox[data-id=disableDualListBoxId]').forEach(ele => {
            ele.disabled = true;
        })
        this.template.querySelectorAll('lightning-combobox[data-id=disableComboId]').forEach(elem => {
            elem.disabled = true;
        })
        this.template.querySelectorAll('textarea[data-id=disabletextArea]').forEach(elem => {
            elem.disabled = true;
        })
        this.template.querySelectorAll('input[data-id=imageData]').forEach(elem => {
            elem.disabled = true;
        })
    }

    //Disable all the input field 
    handleCancel() {
        this.editBtnforSave = true;
        this.template.querySelectorAll('input[data-id=disable]').forEach(item => {
            item.disabled = true;
        })
        this.template.querySelectorAll('input[data-id=disableOr]').forEach(item => {
        item.disabled = true;
        })
        this.template.querySelectorAll('lightning-dual-listbox[data-id=disableDualListBoxId]').forEach(ele => {
            ele.disabled = true;
        })
        this.template.querySelectorAll('lightning-combobox[data-id=disableComboId]').forEach(elem => {
            elem.disabled = true;
        })
        this.template.querySelectorAll('textarea[data-id=disabletextArea]').forEach(elem => {
            elem.disabled = true;
        })
          this.template.querySelectorAll('input[data-id=imageData]').forEach(elem => {
            elem.disabled = true;
        })
    }

    addButtonVisible = false;
    //Update the special needs and diet and can add and remove it. 
    addRow() {
        this.addingRow = true;
        
         // Increment the keyIndex to generate a unique ID for the new row
        ++this.keyIndex;
        
        // Create a new item with a unique ID and default values for specNeedDescription and specNeedComment
        var newItem = { id: this.keyIndex, specNeedDescription: '', specNeedComment: '' };
        if(newItem){
            this.addButtonVisible = false;
            this.hideSpecialNeedFields =  false;
        }
        // Add the new item to the itemList
        this.itemList.push(newItem);
    }

    removeRow(event) {
        this.spNeedDescNullError = false;
        this.commentNullError = false;
        // Retrieve the unique ID from the accessKey attribute of the clicked element
        let id  = event.target.accessKey;
        // Find the index of the item in the itemList with the matching ID
        let itemIndex = this.itemList.findIndex(item => item.id == id);
        this.hideDietaryFields =  false;
        // Check if the item was found in the itemList
        if (itemIndex != -1) {
            // Remove the item from the itemList
            this.itemList.splice(itemIndex, 1);
        }
        if(itemIndex <= 0 ){
            this.addButtonVisible = true;
         }
        // Check if the ID length is greater than 10 (indicating it's an existing item)
        if(id.length > 10){
            // Add the ID to the volunteerData.speNeedDelete array for deletion on save
            this.volunteerData.speNeedDelete.push({id:id});
        }
    }

    addButtonVisibleSp = false;
    addRowDiet() {
        // Increment the keyIndex to generate a unique ID for the new row
        ++this.keyIndexdiet;
        // Create a new item with a unique ID and default values for diet description  and diet Comment
        var newItemDiet = { id: this.keyIndexdiet, dietDescription: '', dietComment: '' };
        // this.hideDietFields =  false;
        if(newItemDiet){
            this.addButtonVisibleSp = false;
            this.hideDietFields = false;
        }
        // Add the new item to the itemListDiet
        this.itemListDiet.push(newItemDiet);
    }

    removeRowDiet(event) {
        this.dietDescNullError = false;
        this.dietcommentNullError = false;
        // Retrieve the unique ID from the accessKey attribute of the clicked element
        let id = event.target.accessKey;
        // Find the index of the item in the itemListDiet with the matching ID
        let itemIndex = this.itemListDiet.findIndex(item => item.id == id);
        // Check if the item was found in the itemListDiet
        if (itemIndex != -1) {
            // Remove the item from the itemListDiet
            this.itemListDiet.splice(itemIndex, 1);
        }
        if(itemIndex <= 0 ){
            this.addButtonVisibleSp = true;
         }
        // Check if the ID length is greater than 10 (indicating it's an existing item)
        if(id.length > 10){
            // Add the ID to the volunteerData.speNeedDelete array for deletion on save
            this.volunteerData.speNeedDelete.push({id:id});
        }
    }

    // Method to handle changes in the selected image
    imagechangedHandler(event) {
        const file = event.target.files[0];
        if (file) {
            if (file.type.startsWith('image/')) {
                this.fileType = file.type;
                this.readFile(file); // Call the method to read the image file
            } else {
                // Handle non-image file selection here
            }
        }
    }

    // Method to read the content of the selected image file
    readFile(file) {
        const reader = new FileReader();
        // Set up an event listener for when the file reading is complete
        reader.onload = (e) => {
            this.fileData = e.target.result.split(',')[1];;
        };
        reader.readAsDataURL(file);
    }

    // Method to upload the selected image
    uploadImage() {
        // Check if image data is available
        if (this.fileData) {
            // Call the uploadImage Apex method to handle image upload
            uploadImage({ imgData: this.fileData })
                .then(result => {
                    // Handle success
                })
                .catch(error => {
                    // Handle error
                });
        }
    }
    //CheckedBox handler and check and uncheck related checkbox according to condition 
    permissionChangeHandle(event) {
        this.volunteerData.imagePermissionCheckBox = event.target.checked;
        if (event.target.checked === true  ) {
            this.checkedPermission = true;
            if(this.volunteerData.imageBelowways === true){
            this.template.querySelectorAll('input[data-id=disableOr]').forEach(elem => {
                elem.disabled = true;
            })
            }
        }
        else if(event.target.checked == false){
                this.volunteerData.imageBelowways = false;
                this.volunteerData.imageSharedParticipantsCheckBox = false;
                this.volunteerData.imageSharedPromoteWithCharitable = false;
                this.volunteerData.imagepromoteCorporatePartners = false;
                this.checkedPermission = false;
        }
        else {
            this.checkedPermission = false;
        }
    }
    allowPhotohandler(event) {
        this.volunteerData.imageBelowways = event.target.checked;
        if (this.volunteerData.imagePermissionCheckBox == true && event.target.checked === true) {
            this.template.querySelectorAll('input[data-id=disableOr]').forEach(elem => {
                elem.disabled = true;
            })
            this.volunteerData.imageSharedParticipantsCheckBox = true;
            this.volunteerData.imageSharedPromoteWithCharitable = true;
            this.volunteerData.imagepromoteCorporatePartners = true;
        }

        else {
            this.template.querySelectorAll('input[data-id=disableOr]').forEach(elem => {
                elem.disabled = false;
            })
        }
    }
    allowSharedPhoto(event){
        this.volunteerData.imageSharedParticipantsCheckBox = event.target.checked;
    }
    allowSharedPromote(event){
        this.volunteerData.imageSharedPromoteWithCharitable = event.target.checked;
    }
    allowCopPer(event){
        this.volunteerData.imagepromoteCorporatePartners = event.target.checked;
    }
    //Handle the values of input values.
    changeDeatilsHandler(event){
                switch (event.target.name) {
            case 'email':
                this.volunteerData.emailAddress = event.target.value;
                break;
            case 'home':
                this.volunteerData.homePhone = event.target.value;
                break;
            case 'swimming':
                this.volunteerData.swimmingAbility = event.target.value;
                break;
            case 'address':
                this.volunteerData.address = event.target.value;
                break;
            case 'mobile':
                this.volunteerData.mobilePhone = event.target.value.replace(/\s+/g, '');
                break;
            case 'shirtSize':
                this.volunteerData.shirtSize = event.target.value;
                break;
            case 'suburb':
                this.volunteerData.suburb = event.target.value;
                break;
            case 'state':
                this.volunteerData.state = event.target.value;
                break;
            case 'postCode':
                this.volunteerData.postcode = event.target.value;
                break;
        }
    }

    // Wire getPicklistValues function from uiObjectInfoApi module to the component
    @wire(getPicklistValues, {        
        recordTypeId: '012280000007dCkAAI', // Specify record type ID , if no record type is there specify default record type
        fieldApiName: shirtSizePick // Specify field API name
    })
    // Define a wired property for type picklist values
    wiredTypePicklistValues({ error, data }) {
        this.waitForRes = true;
        // If data is returned from the wire function
        if (data) {
            this.waitForRes = false;
            // Map the data values to an array of options
            this.shirtOptions = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        }
        
        // If there is an error
        else if (error) {
            this.waitForRes = false;
            // Log the error to the console
        }
    }

    //handle the shirt size from picklist value
     handleShirtSizeChange(event) {
        this.volunteerData.shirtSize =  event.target.value;
    }

        @wire(getPicklistValues, {
        recordTypeId: "012280000007dCjAAI",
        fieldApiName:  swimAbilityPick 
    })
    //propertyOrFunction;
    wiredTypePicklistValuesSwim({ error, data }) {
        // If data is returned from the wire function
        if (data) {
            // Map the data values to an array of options
            this.swimOptions = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        }

        // If there is an error
        else if (error) {

        }
    }

    //handle the swiming ability from picklist value
      handleSwimAbilityChange(event) {
        this.volunteerData.swimmingAbility = event.target.value;
    }
}