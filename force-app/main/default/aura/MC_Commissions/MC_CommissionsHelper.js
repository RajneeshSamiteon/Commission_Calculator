({
    getBreakDownData : function(component, event, helper) {
        var action = component.get("c.getMonthlyBreakDown");
        userProfileName : component.get("v.currentLoggedInUser").Profile.Name
        action.setParams({  
                          month :component.get("v.selectedMonth"),
                          userName : component.get("v.currentLoggedInUser").Profile.Name});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.monthlyCommission' , response.getReturnValue().monthlyCommission); 
                component.set('v.monthlyBreakDown' , response.getReturnValue().monthlyBreakDown); 
                component.set('v.MastermonthlyBreakDown' , response.getReturnValue().monthlyBreakDown); 
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                        let errorObj = {'className' : "MyCommissionController - Aura"};
                        if(errors[0].message.includes('Trace')){                            
                            let err = errors[0].message.split('Trace');
                            errorObj.apexTrace= err[1];
                            errorObj.exceptionMsg = err[0]
                        }
                        else{
                            errorObj.apexTrace= 'helper.getBreakDownData';
                            errorObj.exceptionMsg = errors[0].message;
                        }
                        helper.CreateExceptionLog(component,event,helper,errorObj);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    updateRecordThroughMonth : function(component, event, helper) {
        component.set('v.spinner',true);
        var selectedOptionValue = event.getParam("value");
        if(selectedOptionValue.length ==1){
            selectedOptionValue = '-0'+selectedOptionValue+'-';
        }
        else{
            selectedOptionValue = '-'+selectedOptionValue+'-';
        }
        component.set('v.selectedMonth',selectedOptionValue);
        helper.updateBreakDownRecord(component, event, helper);
    },
    updateRecordThroughYear : function(component, event, helper) {
        component.set('v.spinner',true);
        var selectedOptionValue = event.getParam("value");
        component.set('v.selectedYear',selectedOptionValue);
        helper.updateBreakDownRecord(component, event, helper);
    },
    updateBreakDownRecord :  function(component, event, helper) {
        let filtredMonthlyCommissionByYear =[];
        let breakDownms = component.get('v.MastermonthlyBreakDown')
        for(let breakDown in breakDownms){
            if(breakDownms[breakDown].CreatedDate.includes(component.get('v.selectedYear')) &&  breakDownms[breakDown].CreatedDate.includes(component.get('v.selectedMonth'))){
                let temp = {}
                temp=breakDownms[breakDown];
                filtredMonthlyCommissionByYear.push(temp);
            }
        }
        component.set('v.monthlyBreakDown',filtredMonthlyCommissionByYear);
        component.set('v.spinner',false);
    }
})