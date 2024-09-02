import { LightningElement, track } from 'lwc';
import headerImg from '@salesforce/resourceUrl/CQ_OliveGreenHeader';
import retreats from '@salesforce/label/c.CQ_nav_Retreats';
import retreatHeading from '@salesforce/label/c.CQ_retreats_Heading';
import getPropData from '@salesforce/apex/FamilyRetreatsPageController.getPropData';
// import createCase from '@salesforce/apex/CommunityLoginController.contactUs';
import createCase from '@salesforce/apex/FamilyPortalLoginController.contactUs';
import LightningAlert from 'lightning/alert';
import getContentVersion from '@salesforce/apex/FamilyRetreatsPageController.contentVersion';
import partialFont from '@salesforce/resourceUrl/campQualityCss';
import { loadStyle } from 'lightning/platformResourceLoader';
export default class FamilyRetreatsPage extends LightningElement {

headerOliveGreenImg = headerImg;
label = {
    retreats,
    retreatHeading
    }

retreatProp = [];
error;
retretName;
openContact = false;
checkReqReason = false;
// checkReqSub = false;
checkReqdetail = false;
waitForRes = false;
backBtn = false;
storeSessionUserId;
connectedCallback(){
    this.loadMrOrangeStyles();
    if(sessionStorage.getItem('OTP') != undefined){
        this.storeSessionUserId = sessionStorage.getItem('OTP');
        console.log(' In this profileKey of OTP');
        console.log('this.storeSessionUserIdprofile--->'+ this.storeSessionUserId);
        this.getPropertyData();
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


// Call getContentVersion API with contentVersionId
async loadContentVersion(contentVersionId) {
    try {
        const result = await getContentVersion({ contentVerId: contentVersionId });
        return result;
    } catch (error) {
        console.error('Error loading content version', error);
        return undefined;
    }
}


async getPropertyData(){
    try {
    const result = await getPropData({recUserId : this.storeSessionUserId})
        // Loop through each element in the result array
            for(const ele of result){
            this.waitForRes = true;
            let objData = {
                Name : ele.propList.Name || '',
                Address__c : ele.propList.Address__c || '',
                State__c : ele.propList.State__c || '',
                Guests__c : ele.propList.Guests__c || '',
                Length_of_stay__c : ele.propList.Length_of_stay__c || '',
                Portal_Description__c : ele.propList.Portal_Description__c,
                Id : ele.propList.Id || '',
                blobData : []
            }

            if (ele.blobData !== undefined && ele.blobData !== '') {
                for (const item of ele.blobData) {
                    // Wait for each promise to resolve before moving to the next iteration
                    const result = await this.loadContentVersion(item);
                    if (result !== undefined) {
                        objData.blobData.push('data:image/png;base64,' + result);
                    }
                }
            }
            this.retreatProp.push(objData);
        }
        this.waitForRes = false;
        console.log('this.retreatProp before catch --------->' + JSON.stringify(this.retreatProp));
        } catch (error) {
            this.error = error;
            this.waitForRes = false;
            console.error('Error in getPropertyData', error);
        }
}


handleContactUs(event){
    this.subject = event.target.dataset.name;
    this.openContact = true;
    this.backBtn = true;
}

reasonHandler(event){
    this.reason = 'Enquiry for Respite';
    console.log('This reason ------------>'+ this.reason);
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

async handleAlertClick(msg) {
        await LightningAlert.open({
            message: msg,
            theme: 'success', 
            variant: 'headerless', // this is the header text
        });
        }

backHandle(){
    this.backBtn = false;
    this.openContact = false;
}

submitHandler() {
    console.log('check value' + this.reason);
    console.log('check value' + this.subject);
    console.log('check value' + this.details);

    if ( this.subject.trim() == undefined || this.subject.trim() == '' || this.details.trim() == undefined || this.details.trim() == '') {
        if (this.subject.trim() == undefined || this.subject.trim() == '') {
            this.checkReqSub = true;
        }
        if (this.details.trim() == undefined || this.details.trim() == '') {
            this.checkReqdetail = true;
        }
    }
    else {
        this.waitForRes = true;
        createCase({ subject: this.subject, details: this.details, reason: 'Enquiry for Respite', userId : this.storeSessionUserId })
            .then(result => {
                console.log('success Msg : ' + result);
                if (result != '' || result != undefined) {
                    if (result.includes('Your message has')) {
                        this.handleAlertClick('Your message has been received. Someone will contact you shortly.');
                        this.details = '';
                        this.subject = '';
                        this.reason = 'Enquiry for Respite';
                        this.template.querySelector('[name ="reason"]').selectedIndex = 0;
                        this.template.querySelector('[name ="details"]').value = '';
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
                console.log('Find error in catch' + error);
                console.log('Find error in catch 23' + JSON.stringify(error));
            })
    }
}
}