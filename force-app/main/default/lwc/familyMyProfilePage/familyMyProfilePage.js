import { LightningElement, track, wire, api } from 'lwc';
//Import the apex method
import getFamilyProfiledata from '@salesforce/apex/FamilyMyProfilePageController.getFamilyProfiledata';
import getConDatafortable from '@salesforce/apex/FamilyMyProfilePageController.getConDatafortable';
import getTableBtnData from '@salesforce/apex/FamilyMyProfilePageController.getTableBtnData';
import savefamilyData from '@salesforce/apex/FamilyMyProfilePageController.savefamilyData';
import updatetableData from '@salesforce/apex/FamilyMyProfilePageController.updatetableData';
// Import the getPicklistValues function from the lightning/uiObjectInfoApi module
import { getPicklistValues } from "lightning/uiObjectInfoApi";
// Import the schema for the Contact object's Shirt_Size__c field
import shirtSize from '@salesforce/schema/Contact.Shirt_Size__c';
// Import the schema for the Contact object's Swimming_Ability__c field
import swimAbility from '@salesforce/schema/Contact.Swimming_Ability__c';
//Import the apex method
import createCase from '@salesforce/apex/CommunityLoginController.contactUs';
import locationInProfile from '@salesforce/apex/FamilyMyProfilePageController.locationInProfile';
import familyInterestData from '@salesforce/apex/FamilyMyProfilePageController.familyInterestData';
//Importing lightning alert
import LightningAlert from 'lightning/alert';
// Import the schema for the special need object's for long description  field
import longDescription from '@salesforce/schema/Special_Needs__c.Long_Description__c';
//Importing static resources and custom labels
import headerTopImg from '@salesforce/resourceUrl/CQ_headerYellowTop';
import myfamilyprofile from '@salesforce/label/c.CQ_Profile';
import myfamilyproHeading from '@salesforce/label/c.CQ_Family_Profile_Heading';
import emailAdd from '@salesforce/label/c.CQ_Email_Address';
import homePh from '@salesforce/label/c.CQ_Home_Phone';
import address from '@salesforce/label/c.CQ_Address';
import mobilePh from '@salesforce/label/c.CQ_Mobile_Phone';
import suburb from '@salesforce/label/c.CQ_Suburb';
import state from '@salesforce/label/c.CQ_State';
import postCode from '@salesforce/label/c.CQ_Postcode';
import editBtn from '@salesforce/label/c.CQ_Edit';
import imgPermission from '@salesforce/label/c.CQ_Image_Permissions';
import dietaryReq from '@salesforce/label/c.CQ_Dietary_Requirements';
import specNeeds from '@salesforce/label/c.CQ_Special_Needs';
import swimmingAbi from '@salesforce/label/c.CQ_Swimming_Ability';
import reason from '@salesforce/label/c.CQ_Reason';
import none from '@salesforce/label/c.CQ_None';
import requestCall from '@salesforce/label/c.CQ_Request_a_call';
import requesthelp from '@salesforce/label/c.CQ_Request_help_using_My_Camp_Quality';
import event from '@salesforce/label/c.CQ_Question_about_upcoming_event_experience';
import news from '@salesforce/label/c.CQ_Share_some_news_with_us';
import subject from '@salesforce/label/c.CQ_Subject';
import details from '@salesforce/label/c.CQ_Details';
import submit from '@salesforce/label/c.CQ_Submit_Enquiry';
import reasonError from '@salesforce/label/c.CQ_Reason_error';
import subError from '@salesforce/label/c.CQ_Subject_error';
import detailsError from '@salesforce/label/c.CQ_Details_error';
import partialFont from '@salesforce/resourceUrl/campQualityCss';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class FamilyMyProfilePage extends LightningElement {

    //Declare varaible, arrays, custom labels and objects
    imgTopyellow = headerTopImg;
    label = {
    myfamilyprofile,
    myfamilyproHeading,
    emailAdd,
    homePh,
    address,
    mobilePh,
    suburb,
    state,
    postCode,
    imgPermission,
    editBtn,
    dietaryReq,
    specNeeds,
    reason,
    none,
    requestCall,
    requesthelp,
    event,
    news,
    subject,
    details,
    reasonError,
    subError,
    detailsError,
    submit,
    swimmingAbi
    };
    reason = '--None--';
    subject = '';
    details = '';
    waitForRes = false;
    dependentCheckBox = false;
     @track familyData = {
        email : '',
        street : '',
        postalCode : '',
        country : '',
        city : '',
        state: '',
        preferredEventLocations : '',
        familyInterest : '',
        homePhone : '',
        mobilePhone : '',
        shirtSize : '',
        swimmingAbility : '',
        name: '',
        relationship : '',
        birthday : '',
        conId: '',
        contactList : [],
        mediaOptInTakeVideoPhotos : false,
        mediaOptInShareParticipants : false ,
        mediaPermissionPublic2019 : false,
        mediaOptInShareParticipantsChild : false,
        mediaPermissionPublic2019Child : false,
        imageOptInPermissionCorporateChild : false,
        mediapermissioncorporate2019 : false    
    };
    @track tableWrap = {
        shirtSize : '',
        swimmingAbility : '',      
        dietList: [],
        speNeedList: [],
        speNeedDelete : []        
    }
    swimOptions = [];
    swimAbility = '';
    shirtOptions = [];
    shirtSize = '';
    @track selectedPreferredLocations = [];
    @track selectedFamilyInterest = [];
    @track preferredLocation = [];
    @track familyInterest = [];
    editBtncheck = false;
    error;
    editBtnforSave = true;
    conData;
    getConIdFortable;
    commentNullError = false;
    keyIndexdiet = 0;
    @track dietForCon = [
        // {
        //     id: 0,
        //     dietDescription: '',
        //     dietComment: ''
        // }
    ]
    keyIndex = 0;
    @track specialFOrCon = [
        // {
        //     id: 0,
        //     specNeedDescription: '',
        //     specNeedComment: ''
        // }
    ]

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


    //Get the picklist value of the shirt size of particular record type Id
    @wire(getPicklistValues, { 
        recordTypeId: "012280000007dCj", 
        fieldApiName: shirtSize 
    })
    //propertyOrFunction;
    wiredTypePicklistValuesShirt({ error, data }) {
        // If data is returned from the wire function
        if (data) {
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
            console.error(error);
        }
    }

    //This function Handle the change in values of shirt size and assign in wrapper class variable 
    handleShirtSizeChange(event){
        //this.shirtSize = event.target.value;
        this.tableWrap.shirtSize = event.target.value;
    }
   
    //Get the picklist value of the swiming ability of particular record type Id
    @wire(getPicklistValues, {
        recordTypeId: "012280000007dCj", 
        fieldApiName: swimAbility 
    })
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
            this.waitForRes = false;
            // Log the error to the console
            console.error(error);
        }
    }

    //This function Handle the change in values of swiming ability input and assign in wrapper class variable 
    handleSwimAbilityChange(event){
        this.tableWrap.swimmingAbility = event.target.value;
    }

    storeSessionUserId;
    //Call the multiple methods when component inserted in the DOM
    connectedCallback(){
        this.loadMrOrangeStyles();
        this.fetchingLocation();
        this.fetchingFamilyInterest();
         if(sessionStorage.getItem('OTP') != undefined){
            this.storeSessionUserId = sessionStorage.getItem('OTP');
            this.getProfileData();
            this.fetchTableData();
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

    
    getProfileData(){
        //Call apex method to get the family prfile datab
        getFamilyProfiledata({recUserId : this.storeSessionUserId})
        .then(data=>{
            console.log('----------------data--------------'+ data);
            //Parse the data comming from apex method
            let profileData = JSON.parse(data);
            console.log('============profileData==========='+ JSON.stringify(profileData));
            // Update the familyData object with the fetched profile information
            this.familyData.email = profileData.email;
            this.familyData.conId = profileData.conId;
            this.familyData.street = profileData.street;
            this.familyData.postalCode = profileData.postalCode;
            this.familyData.country = profileData.country;
            this.familyData.city = profileData.city;
            this.familyData.state = profileData.state;
            this.familyData.shirtSize = profileData.shirtSize;
            this.familyData.swimmingAbility = profileData.swimmingAbility;
            this.familyData.birthday = profileData.birthday;
            if (profileData.preferredEventLocations != null && profileData.preferredEventLocations != '') {
                // Check if preferredEventLocations contains multiple values separated by ';'
                if (profileData.preferredEventLocations.includes(';')) {
                    profileData.preferredEventLocations.split(';').forEach(item => {
                        this.selectedPreferredLocations.push(item);
                    })
                }
                else {
                    // If there is only one value, add it to the selectedPreferredLocations array
                    this.selectedPreferredLocations.push(profileData.preferredEventLocations);
                }
            }
            // this.familyData.preferredEventLocations = profileData.selectedPreferredLocations;

            if(profileData.familyInterest != null && profileData.familyInterest !='') {
                // Check if familyInterest contains multiple values separated by ';'
                if(profileData.familyInterest.includes(';')){
                    // Split the values and add each one to the selectedFamilyInterest array
                    profileData.familyInterest.split(';').forEach(item=>{
                        this.selectedFamilyInterest.push(item);
                    })
                }
                else{
                    // If there is only one value, add it to the selectedFamilyInterest array
                    this.selectedFamilyInterest.push(profileData.familyInterest);
                }
            }
            this.familyData.homePhone = profileData.homePhone;
            this.familyData.mobilePhone = profileData.mobilePhone;
            this.familyData.preferredEventLocations = this.selectedPreferredLocations;
            this.familyData.familyInterest = this.selectedFamilyInterest;

            this.familyData.mediaOptInTakeVideoPhotos  = profileData.mediaOptInTakeVideoPhotos;
            if(this.familyData.mediaOptInTakeVideoPhotos == true){
                this.dependentCheckBox = true;
            }
            this.familyData.mediaOptInShareParticipants = profileData.mediaOptInShareParticipants;
            this.familyData.mediaPermissionPublic2019 = profileData.mediaPermissionPublic2019;
            this.familyData.mediaOptInShareParticipantsChild = profileData.mediaOptInShareParticipantsChild;
            
            this.familyData.mediaPermissionPublic2019Child = profileData.mediaPermissionPublic2019Child;

            this.familyData.imageOptInPermissionCorporateChild  = profileData.imageOptInPermissionCorporateChild;
            this.familyData.mediapermissioncorporate2019  = profileData.mediapermissioncorporate2019;
        
            this.familyData.contactList = profileData.contableList;
            
            
            //Make all the input field as disable 
            setTimeout(() =>{
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
            if(this.familyData.mediaOptInTakeVideoPhotos == true){
                this.template.querySelectorAll('input[data-id=disableOr]').forEach(elem => {
                    elem.disabled = true;
                    
                })
            }
        }, )
        })        
        .catch(error=>{
            console.log('============Error================='+ JSON.stringify(error));
            console.log('============Error================='+ error);
        })   
    }

        //This method retrive contact data from apex method 
        fetchTableData(){
            getConDatafortable({recUserId : this.storeSessionUserId})
            .then(result=>{
                result.forEach(ele=>{
                  
                    if(ele.Birthdate != undefined){
                        let dataFormat = ele.Birthdate.split('-');
                        let day = dataFormat[2];
                        let month = dataFormat[1];
                        let year = dataFormat[0];

                        ele.Birthdate = `${day}-${month}-${year}`;
                    }
                });
                this.conData= result;
            })
            .catch(error=>{
                this.error = error;
            })
        }


    //This method retrives the location from the apex method 
    fetchingLocation(){
        locationInProfile()
        .then(data=>{
            // Iterate over each item in the 'data' array
            data.forEach(item => {
                // Create an object with 'label' and 'value' properties using the current item, then push it to the 'preferredLocation' array
                this.preferredLocation.push({ label: item, value: item });
            });                  
        })      
        .catch(error=>{
        })
    }

    //This method retrives family interest data from apex method 
    fetchingFamilyInterest(){
        familyInterestData()
        .then(data=>{
            // Iterate over each item in the 'data' array
            data.forEach(item => {
                // Create an object with 'label' and 'value' properties using the current item, then push it to the 'preferredLocation' array
                this.familyInterest.push({ label: item, value: item });
            });
        })
    }


    //Get the picklist value of long description from record type for the dietary requirement
    @wire(getPicklistValues, {
        recordTypeId: '01228000000iUeuAAE', // Default record type Id
        fieldApiName: longDescription
    })
    getPicklistValuesDiet({ error, data }) {
        if (data) {
            //Create an empty and push label and value in the array.
            let valueList = [];
            data.values.forEach(item => {
                valueList.push({ label: item.label, value: item.value });
            });
            this.specNeedsPick = valueList;
        } else if (error) {
            // Handle error
        }
    }

    //Get the picklist value of long description from record type for for the special need requirement
    @wire(getPicklistValues, {
        recordTypeId: '01228000000iUetAAE', // Default record type Id
        fieldApiName: longDescription
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

    //Handle the input values from the location picklist and assign the value to the variable and display in the HTML
    handleMultiSelectLocation(event){
        this.selectedPreferredLocations = event.detail.value;
    }

    //Handle the values from the familly interest picklist and assign the value to the variable and display in the HTML
    handleMultiSelectFamily(event){
        this.selectedFamilyInterest = event.detail.value;
    }

    //Handle the checkbox values and store it in variable 
    permissionChangeHandle(event){
        this.familyData.mediaOptInTakeVideoPhotos = event.target.checked; 
        if(event.target.checked === true){
            this.dependentCheckBox = true;
        }
        else{
            this.dependentCheckBox = false;
        }
    }
    permissionChangeforAdultForParticipant(event){
        this.familyData.mediaOptInShareParticipants = event.target.checked;
    }
    permissionChangeforAdultPublic(event){
        this.familyData.mediaPermissionPublic2019 = event.target.checked;
    }
    permissionChangeforAdultCorporate(event){
        this.familyData.mediapermissioncorporate2019 = event.target.checked;
    }
    permissionChangeForChildParticipant(event){
        this.familyData.mediaOptInShareParticipantsChild = event.target.checked;
    }
    permissionChangeForChildPublic(event){
        this.familyData.mediaPermissionPublic2019Child = event.target.checked;
    }
    permissionChangeForChildCorporate(event){
        this.familyData.imageOptInPermissionCorporateChild = event.target.checked;
    }

    handleEdit(){
        // Set the flag to indicate that the component is in editing mode
        this.editBtnforSave = false;
        //Make all the field as editable on click of edit button 
        this.template.querySelectorAll('input[data-id=disable]').forEach(item => {
            item.disabled = false;
        })
        this.template.querySelectorAll('input[data-id=disableOr]').forEach(item => {
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
    }

    handleCancel(){
        //Make all the field disable on click of cancel button 
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

    handleSave(){
        //Make all the field as disble on click of save button 
        this.editBtnforSave = true;
        this.waitForRes = true;
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
        let location = '';
        if (this.selectedPreferredLocations != undefined && this.selectedPreferredLocations != null) {
            this.selectedPreferredLocations.forEach(item => {
                location = location + ';' + item;
            })
            location = location.substring(1);
        }
        this.familyData.preferredEventLocations = location;
        let famInterest = '';
        if(this.selectedFamilyInterest != undefined && this.selectedFamilyInterest != null){
            this.selectedFamilyInterest.forEach(item=>{
                famInterest = famInterest + ';' + item;
            })
            famInterest = famInterest.substring(1);
        }
        this.familyData.familyInterest = famInterest;   

        //This method save all the data in database 
        savefamilyData({jsonData : JSON.stringify(this.familyData) , recUserId : this.storeSessionUserId})
        .then(result =>{
            this.waitForRes = false;
            //This will show alert message
            this.handleAlertClick('Profile Updated Succesfully');
            this.keyIndex = 0;
            this.keyIndexdiet = 0;
        })
        .catch(error=>{
            this.waitForRes = false;
        })       
    }


    //This function store the values in wrapper class variable 
    changeDeatilsHandler(event){
        switch(event.target.name){
            case 'email':
                this.familyData.email = event.target.value;
                break;
            case 'home':
                this.familyData.homePhone = event.target.value;
                break;
            case 'mobile':
                this.familyData.mobilePhone = event.target.value.replace(/\s+/g, '');
                break;
            case 'suburb':
                this.familyData.city = event.target.value;
                break;
            case 'state':
                this.familyData.state = event.target.value;
                break;
            case 'postCode':
                this.familyData.postalCode = event.target.value;
                break;
            case 'address':
                this.familyData.street = event.target.value;
                break;
            
        }
    }

    //This function handle the input values of the swiming ability and shirt size of the table data 
    changeDeatilsFortable(event){
        switch(event.target.name){
            case 'swim':
                this.tableWrap.swimmingAbility = event.target.value;
                break;
                
            case 'shirt':
                this.tableWrap.shirtSize = event.target.value;
                break;
        }
    }

    //This function handles the diet requirement values 
    handleChangediet(event) {
        const recordId = event.target.dataset.recordid;
        const selectedValue = event.target.value;
        if (event.target.name === 'dietName') {
            // Find the item in dietForCon with the matching recordId
            let itemToUpdate = this.dietForCon.find(item => item.id == recordId);

            if (itemToUpdate) {
                // Update the dietDescription property of the item
                itemToUpdate.dietDescription = selectedValue;

                // You may want to update dietForCon to trigger reactivity in the template
                this.dietForCon = [...this.dietForCon];
            }
        }
        if (event.target.name === 'dietComment') {
            // Find the item in dietForCon with the matching recordId
            let itemToUpdate = this.dietForCon.find(item => item.id == recordId);

            if (itemToUpdate) {
                // Update the dietComment property of the item
                itemToUpdate.dietComment = selectedValue;
                // You may want to update dietForCon to trigger reactivity in the template
                this.dietForCon = [...this.dietForCon];
            }
        }
    }

    //This function handles the special needs requirements values.
    handleChange(event) {
        // Retrieve the record ID from the dataset of the target element in the event
        let recordId = event.target.dataset.recordid;
        // Retrieve the selected value from the target element in the event
        let selectedValue = event.target.value;
        if (event.target.name === 'speNeedDes') {
             // Find the item in dietForCon with the matching recordId
            let itemToUpdate = this.specialFOrCon.find(item => item.id == recordId);

            if (itemToUpdate) {
                // Update the dietDescription property of the item
                itemToUpdate.specNeedDescription = selectedValue;
                // You may want to update dietForCon to trigger reactivity in the template
                this.specialFOrCon = [...this.specialFOrCon];
            }
        }
        if (event.target.name === 'speNeedCom') {
            // Find the item in dietForCon with the matching recordId
            let itemToUpdate = this.specialFOrCon.find(item => item.id == recordId);

            if (itemToUpdate) {
                // Update the dietComment property of the item
                itemToUpdate.specNeedComment = selectedValue;
                // You may want to update dietForCon to trigger reactivity in the template
                this.specialFOrCon = [...this.specialFOrCon];
            }
        }
    }

    hideSpecialNeedFields = false;
    hideDietFields = false;
    @track isModalOpen = false;
    //This is finction is used to open modal and retrive the data from apex method 
    openModal(event) {
        //Get the the record Id from the dataset of the target element in the event
        this.getConIdFortable = event.target.dataset.id;
        getTableBtnData({contId : event.target.dataset.id})      
        .then(result=>{
            //Parse the data comming from the method
            let tableData = JSON.parse(result);
            //Retrive the data from the apex method and assign it to varible
             this.tableWrap.swimmingAbility = tableData.swimmingAbility;
             this.tableWrap.shirtSize = tableData.shirtSize;
             this.tableWrap.dietList = tableData.dietList;
             if(this.tableWrap.dietList!= null){
                this.dietForCon = this.tableWrap.dietList;
             }
             else{
                this.hideDietFields = true;
                this.addButtonVisibleSp = true;
             }            
             this.tableWrap.speNeedList = tableData.speNeedList
             if(this.tableWrap.speNeedList!= null){
                this.specialFOrCon = this.tableWrap.speNeedList
             }
             else{
                this.hideSpecialNeedFields = true;
                this.addButtonVisible = true;
             }
        })
        .catch(error=>{
        })
        this.isModalOpen = true;
        this.editBtncheck = true;
    }

    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
        this.editBtncheck = false;
    }

    //This funtion invoke when click on submit button 
    submitDetails() {
        // to close modal set isModalOpen tarck value as false
        this.waitForRes = true;
        this.tableWrap.dietList = this.dietForCon;
        this.tableWrap.speNeedList = this.specialFOrCon;

        let count = 0;
        if((this.tableWrap.dietList != undefined || this.tableWrap.dietList != null)  && (this.tableWrap.speNeedList != undefined || this.tableWrap.speNeedList != null)){
            this.tableWrap.dietList.forEach(item=>{
                if(item.dietComment == '' || item.dietComment == null){
                    count += 1 ;
                }
            })

            this.tableWrap.speNeedList.forEach(item=>{
                if(item.specNeedComment == '' || item.specNeedComment == null){
                    count += 1 ;
                }
            })
            if(count > 0){
                this.commentNullError = true;
            }
            else{
                this.commentNullError = false;
            }
         }


        this.waitForRes = true;
        // if(this.commentNullError == false){
        //This method update the data in database 
        updatetableData({tableJsonData : JSON.stringify(this.tableWrap) , contId :this.getConIdFortable})
        .then(result=>{
            this.waitForRes = false;
            this.isModalOpen = false;
            this.editBtncheck = false;
            //This function is called to display alert message on save method 
            this.handleAlertClick('Profile Updated Succesfully');
        })
        .catch(error=>{
            this.waitForRes = false;
            this.isModalOpen = false;
            this.editBtncheck = false;
        })
    // }
    // else {
    //     this.waitForRes = false; 
    //     this.isModalOpen = true; 
    //     this.editBtncheck = true;   
    // }   
    }

    //This function open the alert to show message 
    async handleAlertClick(msg) {
        await LightningAlert.open({
            message: msg,
            theme: 'success', 
            variant: 'headerless', // this is the header text
        });
        //window.open("/volunteerhomepage?page=profile" , "_self");
        }

    addButtonVisible = false;
    //Update the special needs and diet and can add and remove it. 
    addRow() {
        this.addingRow = true;
        ++this.keyIndex;
        var newItem = { id: this.keyIndex, specNeedDescription: '', specNeedComment: '' };
        this.specialFOrCon.push(newItem);
        if(newItem){
            this.addButtonVisible = false;
            this.hideSpecialNeedFields =  false;
        }
    }

    removeRow(event) {
        let id  = event.target.accessKey;
        let itemIndex = this.specialFOrCon.findIndex(item => item.id == id);
        if (itemIndex != -1) {
            this.specialFOrCon.splice(itemIndex, 1);
            console.log('---itemIndex ---' + itemIndex);
        }
        if(itemIndex <= 0 ){
            this.addButtonVisible = true;
         }
        if(id.length > 10){
            this.tableWrap.speNeedDelete.push({id:id});
        }
    }


    addButtonVisibleSp = false;
    addRowDiet() {
        ++this.keyIndexdiet;
        var newItemDiet = { id: this.keyIndexdiet, dietDescription: '', dietComment: '' };
        this.dietForCon.push(newItemDiet);
        if(newItemDiet){
            this.addButtonVisibleSp = false;
            this.hideDietFields = false;
        }
    }

    removeRowDiet(event) {
        let id = event.target.accessKey;
        let itemIndex = this.dietForCon.findIndex(item => item.id == id);
        if (itemIndex != -1) {
            this.dietForCon.splice(itemIndex, 1);
        }
        if(itemIndex <= 0 ){
           this.addButtonVisibleSp = true;
        }
        if(id.length > 10){
            this.tableWrap.speNeedDelete.push({id:id});
        }
    }

    //Handle the input value of the reason and apply validation if the reason is empty
    reasonHandler(event) {
        this.reason = event.target.value;
        if (this.reason !== '--None--') {
            this.checkReqReason = false;
        }
    }

    //Handle input value of the subject and apply validation if the reason is empty
    subjectHandler(event) {
        this.subject = event.target.value;
        if (this.subject != undefined && this.subject != '') {
            this.checkReqSub = false;
        }
    }

    //Handle the input value of details and apply validation if the detail is empty
    detailsHandler(event) {
        this.details = event.target.value;
        if (this.details != undefined && this.details != '') {
            this.checkReqdetail = false;
        }
    }

    checkReqReason = false;
    checkReqSub = false;
    checkReqdetail = false;
    
    submitHandler() {
        

        if (this.reason == undefined || this.reason == '--None--' || this.subject.trim() == undefined || this.subject == '' || this.details == undefined || this.details.trim() == '') {
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
            //This method create case and update fields in database 
            createCase({ subject: this.subject, details: this.details, reason: this.reason, userId : this.storeSessionUserId })
                .then(result => {
                    if (result != '' || result != undefined) {
                        
                        if (result.includes('Your message has')) {
                            //This funtion call the finction and display alert message.
                            this.handleAlertClick('Your message has been received. Someone will contact you shortly.');
                            //Make the input field as empty
                            this.details = '';
                            this.subject = '';
                            this.reason = '--None--';
                            this.template.querySelector('[name ="reason"]').selectedIndex = 0;
                            //This will make the detials field as empty
                            this.template.querySelector('[name ="details"]').value = '';
                        }
                    }
                    this.waitForRes = false;
                })
                .catch(error => {
                    //Here we handle the details, reason, subject
                    this.details = '';
                    this.subject = '';
                    this.reason = '--None--';
                    this.template.querySelector('[name ="reason"]').selectedIndex = 0;
                    this.template.querySelector('[name ="details"]').value = '';
                    this.waitForRes = false;
                })
        }
    }
}