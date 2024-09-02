import { LightningElement , wire} from 'lwc';
//import checkUserPermission from '@salesforce/apex/CommunityLoginController.checkUserPermission';
export default class PortalHomePage extends LightningElement {

    //Used the wire decorator to call Apex method to check user permissions
    // @wire(checkUserPermission)
    // wiredCheckUserPermission({ error, data }) {
    //     if (data) {
    //         window.open(data, '_self');
    //     } else if (error) {
    //         console.log('Error => ' + JSON.stringify(error));
    //     }
    // }
}