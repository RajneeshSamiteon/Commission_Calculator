declare module "@salesforce/apex/MyCommissionController.getLoggedInUser" {
  export default function getLoggedInUser(): Promise<any>;
}
declare module "@salesforce/apex/MyCommissionController.getMonthlyBreakDown" {
  export default function getMonthlyBreakDown(param: {month: any, userName: any}): Promise<any>;
}
