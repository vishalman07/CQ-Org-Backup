import { LightningElement, api } from 'lwc';
export default class FamilyEventChild extends LightningElement {


@api htmlVal;

    connectedCallback() {
        
    }renderedCallback(){
        this.template.querySelector('.elementHoldin').innerHTML = this.htmlVal;
        // event.preventDefault();
    }
}