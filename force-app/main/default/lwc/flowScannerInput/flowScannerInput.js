import { LightningElement, api, track } from "lwc";
import {
  FlowAttributeChangeEvent,
  FlowNavigationNextEvent
} from "lightning/flowSupport";

export default class FlowScannerInput extends LightningElement {
  @api title;
  @api nextButtonLabel;
  @api inputLabel;
  @api value;
  @api availableActions = [];

  @track isLoading = false;

  handleChange(evt) {
    this.value = evt.target.value;
  }

  handleKeyPress(evt) {
    if (evt.which == 13) this.handleNext();
  }

  @api focus() {
    this.template.querySelector("lightning-input").focus();
  }

  _hasFocused = false;
  renderedCallback() {
    if (!this._hasFocused) {
      this.focus();
      this._hasFocused = true;
    }
  }

  @api handleNext() {
    this.isLoading = true;
    this.dispatchEvent(new FlowAttributeChangeEvent("value", this.value));
    if (this.availableActions.find((action) => action === "NEXT")) {
      this.dispatchEvent(new FlowNavigationNextEvent());
    }
  }
}