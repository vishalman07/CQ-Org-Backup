({
	toggleLookupList : function (component, ariaexpanded, classadd, classremove) {
        component.find("divLookup").set("v.aria-expanded", ariaexpanded);
        $A.util.addClass(component.find("divLookup"), classadd);
        $A.util.removeClass(component.find("divLookup"), classremove);
    },
     
    searchRecord : function (component, searchText) {
        component.find("searchinput").set("v.isLoading", true);        
        var action = component.get("c.searchCampaign");
        action.setParams({
            "campaignName":searchText
        });
         
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                if(response.getReturnValue()){
                    component.set("v.matchingRecords", response.getReturnValue());
                    if(response.getReturnValue().length > 0){
                        this.toggleLookupList(component, true, 'slds-is-open', 'slds-combobox-lookup');
                    }
                    component.find("searchinput").set("v.isLoading", false);
                }
            }
        });
        $A.enqueueAction(action);
    }
})