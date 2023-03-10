({
    doInit : function(component, event, helper) {
        var currentDay = new Date();
        let months =[{'label': 'January', 'value': '1'},
                     {'label': 'February', 'value': '2'},
                     {'label': 'March', 'value': '3'},
                     {'label': 'April', 'value': '4'},
                     {'label': 'May', 'value': '5'},
                     {'label': 'June', 'value': '6'},
                     {'label': 'July', 'value': '7'},
                     {'label': 'August', 'value': '8'},
                     {'label': 'September', 'value': '9'},
                     {'label': 'October', 'value': '10'},
                     {'label': 'November', 'value': '11'},
                     {'label': 'December', 'value': '12'}];
        var year = currentDay.getFullYear();
        var month = currentDay.getMonth() +1;
        console.log('year'+year);
        let yearList =[{'label': year , 'value': year},
                       {'label': year-1, 'value': year-1},
                       {'label': year-2, 'value': year-2}];
        component.set('v.selectedYear',currentDay.getFullYear());
        component.set('v.monthList',months);
        component.set('v.selectedMonth',month);
        component.set('v.yearList',yearList);
    },
    handleUserChanges : function(component, event, helper) {
        helper.getBreakDownData(component, event, helper);  
        helper.updateRecordThroughYear(component,event,helper);    
        helper.updateRecordThroughMonth(component,event,helper);    
    },
    updaterecordThroughMonth : function(component, event, helper) {
        helper.updateRecordThroughMonth(component,event,helper);    
    },
    updaterecordThroughYear : function(component, event, helper) {
        helper.updateRecordThroughYear(component,event,helper);    
    },
})