({	    
    handleSelect : function (component,event) { 
        var chooseEvent = component.getEvent("lookupSelect");
        chooseEvent.setParams({
            "recordId" : component.get("v.record").Id,
            "recordName":component.get("v.record").Name
        });
        chooseEvent.fire();
    }
})