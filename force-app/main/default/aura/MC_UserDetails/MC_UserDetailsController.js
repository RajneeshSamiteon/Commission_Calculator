({
	doInit : function(component, event, helper) {
       component.set('v.activeSections',['CommissionTiers','EoYBonusTargets']);
    },
    
    handleUserChanges : function(component, event, helper) {
		helper.populateCommissionMasterSchema(component, event, helper);  
    }
})