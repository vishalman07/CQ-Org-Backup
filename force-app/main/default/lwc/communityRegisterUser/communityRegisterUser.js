import { LightningElement } from 'lwc';
export default class CommunityRegisterUser extends LightningElement {

 value = '--None--';

    get options() {
        return [
            { label: 'Home', value: 'Home' },
            { label: 'Work', value: 'Work' },
            { label: 'Mobile', value: 'Mobile' },
            { label: 'Other', value: 'Other' },
        ];
    }
}