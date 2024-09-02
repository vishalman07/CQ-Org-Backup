import { LightningElement, api, wire } from 'lwc';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
import leadConvert from '@salesforce/apex/CustomLeadConvert.leadConvert';
import leadRecord from '@salesforce/apex/CustomLeadConvert.leadRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class CallApexFromButton extends NavigationMixin(LightningElement) {
    @api recordId;
    isLoading = true;
    subscription = {};
    callMethod = true;
    @api channelName = '/event/LeadConvert__e';

    @wire(leadRecord, { leadId: '$recordId' })
    wiredData({ error, data }) {
        if (data) {
            // Call the leadConvert Apex method with the retrieved Lead Id
            leadConvert({ leadId: data })
                .then(result => {
                    // Log the result message
                    //console.log('Message : ' + result.message);
                })
                .catch(error => {
                    // Log and display an error message if there's an error
                    console.log(JSON.stringify(error.body.message));
                    this.showErrorToast(JSON.stringify(error.body.message));

                    // Set isLoading to false to hide the spinner
                    this.isLoading = false;
                });
            }
        else if(error){
            console.log('Error : '+error);
        }
    }
    connectedCallback() {
        // Register error listener     
        this.registerErrorListener();

        // Subscribe to the channel only if not already subscribed
        if (this.callMethod) {
            this.handleSubscribe();
            this.callMethod = false;
        }
    }

    // Handles subscribe button click
    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const self = this;
        const messageCallback = function (response) {
            console.log('New message received 1: ', JSON.stringify(response));
            console.log('New message received 2: ', response);
            var obj = JSON.parse(JSON.stringify(response));
            console.log(obj.data.payload);
            console.log(obj.data.payload.Message__c);
            let objData = obj.data.payload;
            self.message = objData.Message__c;
            self.recordId = objData.ConvertContactId__c;
            if(self.message.includes('Lead conversion was successful')){
            self.showSuccessToast(self.message);
            }
            else {
                self.showErrorToast(self.message);
            }
            // Navigate to a Lead record page using NavigationMixin
            self.navigateToRecordPage(self.recordId);
        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback).then(response => {
            // Response contains the subscription information on subscribe call
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            this.subscription = response;
        });
    }

    // Handle unsubscribing when the component is about to be destroyed
    disconnectedCallback() {
        this.handleUnsubscribe();
    }

    // Handle unsubscribing from the channel
    handleUnsubscribe() {
        unsubscribe(this.subscription, response => {
            console.log('Unsubscribed from channel: ', JSON.stringify(response));
        });
    }

    // handle Error
    registerErrorListener() {
        onError(error => {
            console.log('Received error from server: ', JSON.stringify(error));
        });
    }

    // Method to display a success toast message
    showSuccessToast(msg) {
        const evt = new ShowToastEvent({
            title: 'Success message',
            message: msg,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    // Method to display an error toast message
    showErrorToast(msg) {
        const evt = new ShowToastEvent({
            title: 'Error message',
            message: msg + ' And If you are not able to view the Lead Convert button, then reload this page.',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    // Method to navigate to a Contact record page
    navigateToRecordPage(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Contact',
                actionName: 'view',
            },
        });
    }
}