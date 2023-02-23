public class DataFactory {
    public static Set<Id> getFieldIdsFromsObjects(List<sObject> objects, String fieldApiName){
        Set<id> ids = new Set<Id>();
        for( sObject sObj : objects ){
            Ids.add((Id)sObj.get(fieldApiName));
        }
        return Ids;
    }
    public static Map<Id,List<sObject>> getsObjectsByFieldId(List<sObject> objects, String fieldApiName){
        Map<Id,List<sObject>> sOjectsById = new  Map<Id,List<sObject>>();
          for( sObject sObj : objects ){
              if(sOjectsById.containsKey((Id)sObj.get(fieldApiName))){
                  sOjectsById.get((Id)sObj.get(fieldApiName)).add(sObj);
              }
              else{
                  sOjectsById.put((Id)sObj.get(fieldApiName),new List<sObject>{sObj});
              }
        }
        return sOjectsById;
    }
}