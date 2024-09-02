import { LightningElement ,wire , track, api} from 'lwc';
import event from '@salesforce/label/c.CQ_EventHeading';
import newsHaeding from '@salesforce/label/c.CQ_news_Update_Heading';
import eventDetails from '@salesforce/label/c.CQ_Event_details';
import des from '@salesforce/label/c.CQ_Description';
import comments from '@salesforce/label/c.CQ_Comments';
import eventType from '@salesforce/label/c.CQ_Event_Type';
import dietaryReq from '@salesforce/label/c.CQ_Dietary_Requirements';
import startDate from '@salesforce/label/c.CQ_Start_Date';
import time from '@salesforce/label/c.CQ_Time';
import finishDate from '@salesforce/label/c.CQ_Finish_Date';
import specNeeds from '@salesforce/label/c.CQ_Special_Needs';
import noevent from '@salesforce/label/c.CQ_No_Events';
import messageEvent from '@salesforce/label/c.CQ_Events_Mess';
import resources from '@salesforce/label/c.CQ_Resources_Heading';
import headerImg from '@salesforce/resourceUrl/CQ_SkyBlueHeader';
import fatchEvent from '@salesforce/apex/VolunteerEventController.fetchEvents';
import eventdetails from '@salesforce/apex/VolunteerEventController.eventDetails';
import updateStatus from '@salesforce/apex/VolunteerEventController.updateEventDetails';
import geteventData from '@salesforce/apex/VolunteerEventController.getDataForEvent';
import updateDetails from '@salesforce/apex/VolunteerEventController.updateVoluEvent';
import preferredSessionPicklist from '@salesforce/apex/VolunteerEventController.preferredSessionPicklist';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
// Import constant TYPE_FIELD from Account schema
import shirtSize from '@salesforce/schema/Contact.Shirt_Size__c';
import INDUSTRY_FIELD from '@salesforce/schema/Special_Needs__c.Long_Description__c';
import LightningAlert from 'lightning/alert';
import getContentVersion from '@salesforce/apex/VolunteerEventController.contentVersion';
import partialFont from '@salesforce/resourceUrl/campQualityCss';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class CommunityEventPage extends LightningElement {

//Declare variable  
headerSkyBlueImg = headerImg;
waitForRes = false;
backBtn = false;
pickListValue;
//Custom Label 
label = {
event,
newsHaeding,
resources,
eventDetails,
comments,
des,
eventType,
startDate,
dietaryReq,
time,
finishDate,
specNeeds,
noevent,
messageEvent
}
//Declare variable  
hasEvent = false;
events =[];
eventDetails = false;
eventDetail = [];
volunteerId;
showUpdatePanel = false;
shirtOptions = [];
shirtSize = '';
optionSharingShow = false;
@track detailsData = {
shirtSize: '',
contactId :'',
emergencyConName : '',
emergencyConRelation : '',
emergencyConMobile : '',
regisPeriodName : '',
imageSharingOptionCheckBox: false,
imageSharedParticipantsCheckBox: false,
imageSharedPromoteWithCharitable : false,
imagepromoteCorporatePartners : false,

imagepublicSharing: false,
agreeToParticipateInEventActi: false,
dietList : [],
speNeedList : [],
speNeedDelete : []
}
keyIndex = 0;
@track itemList = [
// {
//     id: 0,
//     specNeedDescription: '',
//     specNeedComment: ''
// }
];

keyIndexdiet = 0;
@track itemListDiet = [
// {
//     id: 0,
//     dietDescription: '',
//     dietComment: ''
// }
];
@track diet = [];
@track specNeedsPick = [];

getVolAttId;
commentNullError = false;


translationValue = 0;

@api campaignId;
parameters = {};
storeSessionUserId;



connectedCallback() {

    if(sessionStorage.getItem('userId') != undefined){
        this.storeSessionUserId = sessionStorage.getItem('userId');
        this.getEventsData();
        this.parameters = this.getQueryParameters();
        if(this.parameters.Id != undefined && this.parameters.Id != ''){
            this.campaignId = this.parameters.Id;
            this.callEventWithId();       
        }
    }

    this.loadMrOrangeStyles();
}

loadMrOrangeStyles() {
    if (location.origin.includes('partial')) {
        loadStyle(this, partialFont + '/campqualityCss/partialFont.css')
            .then(() => {
                // Stylesheet loaded successfully
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


getQueryParameters() {

    var params = {};
    var search = location.search.substring(1);
    if (search) {
        params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
            return key === "" ? value : decodeURIComponent(value)
        });
    }       
    return params;
}


@track versionData;

async loadContentVersion2(contentVersionId) {
    try {
        const result = await getContentVersion({ contentVerId: contentVersionId });
        // this.versionData = result;
        return result;
        // Do something with versionData
    } catch (error) {
        // Handle errors here
    }
}

@track versionData;

async loadContentVersion(contentVersionId) {
    try {
        const result = await getContentVersion({ contentVerId: contentVersionId });
        return result;
    } catch (error) {
        console.error('Error loading content version', error);
        return undefined;
    }
}


async getEventsData() {
    // Calling the Apex method 'fetchevents' to retrieve event data
    const result = await fatchEvent({recUserId : this.storeSessionUserId});
    // Updating the component's 'events' property with the retrieved data

    for (const ele of result) {
        this.waitForRes = true;
        let objData = {
            Event_Type__c: ele.camp.Event_Type__c || '',
            StartDate: '',
            Event_time__c: ele.camp.Event_time__c || '',
            EndDate: '',
            RVSP__c: ele.camp.RVSP__c || '',
            Portal_Title__c: ele.camp.Portal_Title__c || '',
            Id: ele.camp.Id || '',
            Image_Upload__c: '',
            Image_for_Portals__r: '',
            bolbData: [],
            isblobData : false,
        };

        // Create an array to store promises
        const promises = [];

        if (ele.bolbData !== undefined && ele.bolbData !== '') {
            for (const item of ele.bolbData) {
                // Wait for each promise to resolve before moving to the next iteration
                const result = await this.loadContentVersion(item);
                if (result !== undefined) {
                    objData.bolbData.push('data:image/png;base64,' + result);
                }
            }
        }

    

        if (ele.camp.StartDate !== undefined) {
            let dateComponents = ele.camp.StartDate.split('-');
            let day = dateComponents[2];
            let month = dateComponents[1];
            let year = dateComponents[0];

            objData.StartDate = `${day}-${month}-${year}`;
        }

        if (ele.camp.EndDate !== undefined) {
            let dateComponents = ele.camp.EndDate.split('-');
            let day = dateComponents[2];
            let month = dateComponents[1];
            let year = dateComponents[0];

            objData.EndDate = `${day}-${month}-${year}`;
        }

        if(objData.bolbData.length > 0){
            objData.isblobData = true;
        }
        this.events.push(objData);
        
    }
    this.waitForRes = false;
    if (result.length > 0) {
        this.hasEvent = true;
    }
}




@ track pickListValueSession = [{ label: 'Select an Option', value: '', selected: false }];

// Wire getPicklistValues function from uiObjectInfoApi module to the component
@wire(getPicklistValues, {        
    recordTypeId: '012280000007dCkAAI', // Specify record type ID , if no record type is there specify default record type
    fieldApiName: shirtSize // Specify field API name
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
        console.error(error);
    }
}

CampaignId;
campIdUrl;
//Handle the changes on click of button 
eventDetailsHandle(event){
    this.waitForRes = true;  
    this.campaignId = event.target.dataset.id;
    let getUrl = window.location.href;
    this.campIdUrl = '/volunteer/?page=event&Id='+this.campaignId;
   window.open('/volunteer/?page=event&Id='+this.campaignId , '_self');
    

}



@track bolbData =  [];
async callEventWithId(){
    try {
        const result = await eventdetails({ campId: this.campaignId, recUserId: this.storeSessionUserId });
        this.waitForRes = false;
        this.eventDetail = result;
        if (result.blobEventImages !== undefined && result.blobEventImages !== '') {
          for (const item of result.blobEventImages) {
            if (item.bolbData && typeof item.bolbData[Symbol.iterator] === 'function') {

                    for(const ele of item.bolbData){                     
                        const imageData = await this.loadContentVersion2(ele); // Await the result here
                        if (imageData !== undefined) {
                        this.bolbData.push('data:image/png;base64,' + imageData);
                        }
                    }
                }
            }       
        }  
        this.eventDetails = true;
        this.hasEvent = false;
        this.backBtn = true;
      } catch (error) {
        // Handle errors here
        console.error('Error occurred:', error);
        this.waitForRes = false;
      }
}

customModalOpen = false;
cancelHandle(event){
    this.volunteerId = event.target.dataset.id;
    this.customModalOpen = true;
}
backHandle(){
    this.eventDetails = false;
    this.hasEvent = true;
    this.showUpdatePanel = false;
    this.backBtn = false;
}

closeModal(){
    this.customModalOpen = false;
}
handleShirtSizeChange(event){
    this.shirtSize = event.target.value;
}


//detailsData.regisPeriodName
@track selectedSessionPickList = '';
handleSessionChange(event){
    this.selectedSessionPickList = event.target.value;
}

hideSessionDropdown = false;
hideDietFields = false;
hideSpecialNeedFields = false;
//Updating the data 
updateRegHandle(event){
    this.showUpdatePanel = true;
    window.scrollTo(0, document.body.scrollHeight - 50);
    this.getVolAttId = event.target.dataset.id;
    geteventData({volAttId : event.target.dataset.id})
    .then(result => {
        const data = JSON.parse(result);
        this.detailsData.shirtSize = data.shirtSize;
        this.shirtSize = data.shirtSize;
        this.detailsData.contactId = data.contactId;
        this.detailsData.emergencyConName = data.emergencyConName;
        this.detailsData.emergencyConRelation = data.emergencyConRelation;
        this.detailsData.emergencyConMobile = data.emergencyConMobile
        this.detailsData.imageSharingOptionCheckBox = data.imageSharingOptionCheckBox;
        this.selectedSessionPickList = data.regisPeriodName;
        if (result.regisPeriodName == undefined || result.regisPeriodName == '') {
            this.selectSession = true;
        }
        if(data.imageSharingOptionCheckBox == true){
            this.optionSharingShow = true;
        }
        else {
            this.optionSharingShow = false;
        }
        this.detailsData.imageSharedParticipantsCheckBox = data.imageSharedParticipantsCheckBox;
        this.detailsData.imageSharedPromoteWithCharitable = data.imageSharedPromoteWithCharitable;
        this.detailsData.imagepromoteCorporatePartners = data.imagepromoteCorporatePartners;
        this.detailsData.dietList = data.dietList;
        
        if (this.detailsData.dietList!= null) {
            this.itemListDiet = this.detailsData.dietList;
        }
        else{
            this.hideDietFields = true;
            this.addButtonVisibleSp = true;
        }
        this.detailsData.speNeedList = data.speNeedList;
        if (this.detailsData.speNeedList!= null) {
            this.itemList = this.detailsData.speNeedList;
        }
        else{
            this.hideSpecialNeedFields = true;
            this.addButtonVisible = true;
        }

        preferredSessionPicklist({camId : this.campaignId})
        .then(result=>{
        if(result != undefined && result != ''){
            this.pickListValueSession = [{ label: 'Select an Option', value: '', selected: false }];

            result.forEach(item => {
                const obj = {
                    label: item.label,
                    value: item.value,
                    selected: false
                }
                if (item.value == this.selectedSessionPickList) {
                    obj.selected = true;
                }
                this.pickListValueSession.push(obj);
                this.hideSessionDropdown = false;
            })
        }
        else{
            this.hideSessionDropdown = true;
        }
        
    })
    .catch(error=>{
        console.log('pic erro2', JSON.stringify(error));
    })

    })
    .catch(error =>{
        console.log('error 5',error);
    })

   
    
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
updateStatusDeclined(event){ 
    this.waitForRes = true;  
    this.showUpdatePanel = false;
    updateStatus({voluAttId : event.target.dataset.id , status : 'Declined' , cancelReason : ''})
    .then(result =>{
        // this.handleAlertClick('Declined');
        this.handleAlertClick();
        this.waitForRes = false;  
    })
    .catch(error =>{
        this.waitForRes = false;
        //(JSON.stringify(error));
    })
}
// async handleAlertClick(msg) {
    async handleAlertClick() {
    await LightningAlert.open({
        // message: 'Status updated '+msg+' sucessfully.',
        message: 'Registration successfully updated',
        theme: 'success', // a red theme intended for error states
        label: 'Update Status', // this is the header text
    });
  
    let openEvent = this.template.querySelector('c-volunteer-main-page');
    openEvent.openEvent('event');
}
async handleUpdtaeAlert() {
    
    await LightningAlert.open({
        message: 'Registration Updated Sucessfully.',
        theme: 'success', // a red theme intended for error states
        label: 'Update Registration', // this is the header text
            });
   
}

modalInputvalue;
handleModalInput(event){
    this.modalInputvalue = event.target.value;
    if(this.modalInputvalue != undefined && this.modalInputvalue != '' ){
        this.customModalValidation =  false;
    }
}

customModalValidation =  false;
cancelTrue = true;

handleModalOk(event){
    //('this.modalInputvalue1 ------>' + this.modalInputvalue);
    if(this.modalInputvalue != undefined && this.modalInputvalue != ''){
        //('this.modalInputvalue2 ------>' + this.modalInputvalue);
        this.customModalOpen = false;
        this.waitForRes = true;
        updateStatus({voluAttId : this.volunteerId , status : 'Cancelled' , cancelReason : this.modalInputvalue})
            .then(result =>{
                this.waitForRes = false;
                this.customModalOpen = false;
                // this.handleAlertClick('Declined');
                this.handleAlertClick();
                this.eventDetailsHandle();
                this.cancelTrue = false;
            })
            .catch(error =>{
                this.waitForRes = false;
                this.customModalOpen = false;
                //(JSON.stringify(error));
            })
    }
    else{
        //('Check here Ok button-')
        this.customModalValidation =  true;
    }
}

emergrncyConNameValidation = false;
emerRelationVali = false;
emerMobileVali = false;
waiverValidation = false;
dietDescNullError = false;
spNeedDescNullError = false;
dietcommentNullError = false;
preferresSessVali = false;

completeHandle(event){
   
    if(this.detailsData.emergencyConName == undefined || this.detailsData.emergencyConName.trim() == ''){
        this.emergrncyConNameValidation = true;
        //('this.emergrncyConValidation----------');
    }
    if(this.detailsData.emergencyConRelation == undefined || this.detailsData.emergencyConRelation.trim() == ''){
        this.emerRelationVali = true;
    }
    if(this.detailsData.emergencyConMobile == undefined || this.detailsData.emergencyConMobile.trim() == ''){
        this.emerMobileVali = true;
    }

    if(this.detailsData.agreeToParticipateInEventActi == undefined || this.detailsData.agreeToParticipateInEventActi == ''){
        this.waiverValidation = true;              
    }
    
    if(this.emergrncyConNameValidation == false && this.waiverValidation == false && this.emerRelationVali == false && this.emerMobileVali == false){
        
    // Counter for tracking the presence of empty comments in diet and special needs lists.
    let count = 0;
    let countSp = 0;
    // Setting the shirt size in detailsData.
    this.detailsData.shirtSize = this.shirtSize;

    this.detailsData.regisPeriodName = this.selectedSessionPickList;
    if((this.detailsData.regisPeriodName == undefined || this.detailsData.regisPeriodName == '' || this.detailsData.regisPeriodName == 'Select an Option' || this.detailsData.regisPeriodName == null) && this.pickListValueSession.length > 1){
        this.preferresSessVali= true;
    }
    else if(this.selectedSessionPickList != '' || this.selectedSessionPickList != undefined || this.selectedSessionPickList != null) {
        this.preferresSessVali= false;
    }
    
    this.detailsData.dietList = this.itemListDiet;
    this.detailsData.speNeedList = this.itemList;
   
        if(this.preferresSessVali== false){
         this.waitForRes = true;  
         updateDetails({jsonData : JSON.stringify(this.detailsData), voluAttId : this.getVolAttId})
        .then(result =>{
            this.handleUpdtaeAlert();  
            this.waitForRes = false;
            this.showUpdatePanel = false; 
            this.eventDetails = false;
            this.hasEvent = true;
            this.backBtn = false;
        })
        .catch(error => {
            this.waitForRes = false;
            this.showUpdatePanel = false; 
        })
        }
        

    //Here we update status volunteer status using imperative method
    updateStatus({voluAttId : this.getVolAttId , status : 'Request to Attend' , cancelReason : ''})
    .then(result =>{
        this.waitForRes = false; 
        
    })
    .catch(error =>{
        this.waitForRes = false;
        //(JSON.stringify(error));
    })

}        
}

//Handle diet data
handleChangediet(event) {
   
    const recordId = event.target.dataset.recordid;
    const selectedValue = event.target.value;
    if (event.target.name === 'dietName') {
        //('In Name diet');
        // Find the item in itemListDiet with the matching recordId          
        let itemToUpdate = this.itemListDiet.find(item => item.id == recordId);

        if (itemToUpdate) {
            // Update the dietDescription property of the item
            itemToUpdate.dietDescription = selectedValue;
            if(selectedValue !=''){
                this.dietDescNullError = false; 
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
                this.dietcommentNullError =false;
            }
            // You may want to update itemListDiet to trigger reactivity in the template
            this.itemListDiet = [...this.itemListDiet];
        }
    }
}

//Handle special needs data
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
                this.spNeedDescNullError =false;
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

addButtonVisible = false;
//Update the spe needs add and remove it. 
addRow() {
this.addingRow = true;
++this.keyIndex;
var newItem = { id: this.keyIndex, specNeedDescription: '', specNeedComment: '' };
if(newItem){
    this.addButtonVisible = false;
    this.hideSpecialNeedFields =  false;
}
this.itemList.push(newItem);
}

removeRow(event) {
this.spNeedDescNullError = false;
this.commentNullError = false;
let id = event.target.accessKey;
let itemIndex = this.itemList.findIndex(item => item.id == id);
if (itemIndex != -1) {
    this.itemList.splice(itemIndex, 1);
}
if(itemIndex <= 0 ){
    this.addButtonVisible = true;
 }
if(id.length > 10){
    this.detailsData.speNeedDelete.push({id:id});
}
}

addButtonVisibleSp = false;
addRowDiet() {
++this.keyIndexdiet;
var newItemDiet = { id: this.keyIndexdiet, dietDescription: '', dietComment: '' };
if(newItemDiet){
    this.addButtonVisibleSp = false;
    this.hideDietFields = false;
}
this.itemListDiet.push(newItemDiet);
}

removeRowDiet(event) {

this.dietDescNullError = false;
this.dietcommentNullError = false;
let id = event.target.accessKey;
let itemIndex = this.itemListDiet.findIndex(item => item.id == id);
if (itemIndex != -1) {
    this.itemListDiet.splice(itemIndex, 1);
}
if(itemIndex <= 0 ){
    this.addButtonVisibleSp = true;
 }
if(id.length > 10){
    this.detailsData.speNeedDelete.push({id:id});
}
}

//Handle the image checkbox
changeDeatilsHandler(event){

switch (event.target.name) {
    case 'imageSharing':
        this.detailsData.imageSharingOptionCheckBox = event.target.checked;
        if(event.target.checked === true ){
        this.optionSharingShow = true;
        }
        else {
        this.optionSharingShow = false;
        }
        break;
    case 'imagePhotoPart':
        this.detailsData.imageSharedParticipantsCheckBox = event.target.checked;
        break;
    case 'imageSharedPromoteWithCharitable':
        this.detailsData.imageSharedPromoteWithCharitable = event.target.checked;
        break;
    case 'imagepromoteCorporatePartners':
        this.detailsData.imagepromoteCorporatePartners = event.target.checked;
    case 'imageAgree':
        this.detailsData.agreeToParticipateInEventActi = event.target.checked;
        if(this.detailsData.agreeToParticipateInEventActi != undefined || this.detailsData.agreeToParticipateInEventActi != ''){
            this.waiverValidation = false;
        }
        break;
    case 'emergencyConName':
        this.detailsData.emergencyConName = event.target.value;
        if(this.detailsData.emergencyConName !== undefined || this.detailsData.emergencyConName !=''){
            this.emergrncyConNameValidation = false;
        }
        break;
    case 'emergencyConRelation':
        this.detailsData.emergencyConRelation = event.target.value;
        if(this.detailsData.emergencyConRelation !== undefined || this.detailsData.emergencyConName !=''){
            this.emerRelationVali = false;
        }
        break;
    case 'emergencyConMobile':
        this.detailsData.emergencyConMobile = event.target.value;
        if(this.detailsData.emergencyConMobile !== undefined || this.detailsData.emergencyConMobile !=''){
            this.emerMobileVali = false;
        }

}
}
}