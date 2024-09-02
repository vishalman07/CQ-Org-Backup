import { LightningElement, api, wire } from 'lwc';
import  findUser from  '@salesforce/apex/ActionButtonLogin.findUser';
import contactRecord from '@salesforce/apex/ActionButtonLogin.contactRecord';

export default class PortalLoginFromActionBtn extends LightningElement {

@api recordId;
userIdToLoginVol;
userIdToLoginFam;

// connectedCallback(){
//         console.log('Contact Id--->'+ this.recordId);
//         // console.log('Contact Id--->'+ this.recordId);
//         // this.getUserInfo();
//         if(this.userIdToLoginVol != undefined){
//             sessionStorage.setItem("userIdToSet", "userIdToLoginVol");
//             window.open('/volunteer?page=home' , '_self');
//         }
//         else if(this.userIdToLoginFam !=undefined){
//             sessionStorage.setItem("userIdToSet", "userIdToLoginFam");
//             window.open("/family/login" , '_self');
//         }
//         console.log('user: ', this.user);
// }
volTrue;
familyTrue;
@wire(contactRecord, { conId: '$recordId'})
wiredContacts({data, error}){
    console.log('ContactId e---+ Contact Id222--->'+ this.recordId);
    if(data){
        console.log('ContactId e---+ Contact Id333--->'+ data);
        findUser({ contactId: data })
        .then(result => {
            console.log('result: ', result);
            for (const ele of result) {
                console.log('ele1: ', ele);
                console.log('ele2: ', ele.AssigneeId);
                this.userIdToLoginVol = ele.AssigneeId;
                if(ele.PermissionSet.Name == 'Volunteer_Portal_Permissions'){
                    this.volTrue = true;
                    console.log('--this.volTrue---'+ this.volTrue);
                 // sessionStorage.setItem("userIdToSet", "userIdToLoginVol");
                }
                else if(ele.PermissionSet.Name == 'Family_Portal_Permissions'){
                    this.familyTrue = true;
                    console.log('--this.familyTrue---'+ this.familyTrue);
                }
            }

            if(this.volTrue == true){
                console.log(           '----true----' );
                // sessionStorage.setItem("userIdToSet", "result.AssigneeId");
                // window.open('https://campquality--partial.sandbox.my.site.com/volunteer?page=home' , '_self');  
            }
            else if(this.familyTrue == true){
                // sessionStorage.setItem("userIdToSet", "result.AssigneeId");
                // window.open('https://campquality--partial.sandbox.my.site.com/family?page=home' , '_self'); 
            }
            
            // if(result.PermissionSet.Name     == 'Volunteer_Portal_Permissions'){
            //     this.userIdToLoginVol  = result.AssigneeId; 
            //     sessionStorage.setItem("userIdToSet", "result.AssigneeId");
            //     window.open('/volunteer?page=home' , '_self');       
            // }
            // else if(result.PermissionSet.Name == 'Family_Portal_Permissions'){
            //     this.userIdToLoginFam  = result.AssigneeId; 
            //     sessionStorage.setItem("userIdToSet", "result.AssigneeId");
            //     window.open("/family/login" , '_self');            
            // }       
        })
        .catch(error =>{
            console.log('Error --->: ', JSON.stringify(error));
            console.error('Error message:', error.message);
            console.error('Stack trace:', error.stack);
        })
    }



// getUserInfo(){

//     findUser({ contactId: this.recordId })
//     .then(result => {
//         console.log('result: ', result);
//         if(result.PermissionSet.Name == 'Volunteer_Portal_Permissions'){
//             this.userIdToLoginVol  = result.AssigneeId;
            
//         }
//         else if(result.PermissionSet.Name == 'Family_Portal_Permissions'){
//             this.userIdToLoginFam  = result.AssigneeId;
            

//         }       
//     })
//     .catch(error =>{
//         console.log('Error --->: ', JSON.stringify(error));
//         console.error('Error message:', error.message);
//          console.error('Stack trace:', error.stack);
//     })

// }


}
}