import { LightningElement, api, wire } from 'lwc';
import  findUser from  '@salesforce/apex/ActionButtonLogin.findUser';
import contactRecord from '@salesforce/apex/ActionButtonLogin.contactRecord';

export default class PortalLoginFromActionBtn extends LightningElement {

@api recordId;
userIdToLoginVol;
userIdToLoginFam;
waitForRes = false;

volTrue = false;
familyTrue = false;
notPortalUser = false;
// Wire method to fetch contact record
@wire(contactRecord, { conId: '$recordId'})
wiredContacts({data, error}){
    if(data){
        // Call Apex method to get user Id and permission set based on the pemission set we show the button either family portal or volunteer portal.
        findUser({ contactId: data })
        .then(result => {
            if(result.permissionSetName == 'Volunteer_Portal_Permissions'){
                this.userIdToLoginVol = result.adduserIdToUrl;
                this.waitForRes = true;
                this.volTrue = true;               
            }
            else if(result.permissionSetName == 'Family_Portal_Permissions'){
                this.userIdToLoginVol = result.adduserIdToUrl;
                this.waitForRes = true;
                this.familyTrue = true;
            }                         
        })
        .catch(error =>{
            console.log('Error --->: ', JSON.stringify(error));
        })
    }
    else{
        console.log('Error--->'+ error);
    } 
}

// Method to handle volunteer portal button click
handleVolunteer(event){
    window.open('https://campquality--partial.sandbox.my.site.com/volunteer?c__userId='+this.userIdToLoginVol+'&page=home' , '_blank');  

}

// Method to handle family portal button click
handleFamily(event){
    window.open('https://campquality--partial.sandbox.my.site.com/family?c__userId='+this.userIdToLoginVol+'&page=home' , '_blank'); 
}
}