/**
 * @description       : 
 * @author            : MTX Group Inc.
 * @group             : 
 * @last modified on  : 05-06-2024
 * @last modified by  : Ayush Dev
**/
public with sharing class LPI_RelatedListCmpController {
    /**
    * @description 
    * @author Ayush Dev | 05-06-2024 
    * @param columnWrapper 
    * @param parentId 
    * @param parentFieldName 
    * @param objectName 
    * @param queryCondition 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String, Object> getData(
        String columnWrapper,
        String parentId,
        String parentFieldName,
        String objectName,
        String queryCondition
    ) {
        try {
            ColumnWrapper columnWrapList = (ColumnWrapper) JSON.deserializeStrict(
                columnWrapper,
                ColumnWrapper.class
            );
            Map<String, ColumnValueWrapper> columnMap = new Map<String, ColumnValueWrapper>();
            Map<String, Object> result = new Map<String, Object>();
            List<RowWrapper> rowWrapList = new List<RowWrapper>();
            List<ColumnDataWrapper> columnLabelList = new List<ColumnDataWrapper>();
            List<String> colList;

            if (columnWrapList != null) {
                for (ColumnValueWrapper obj : columnWrapList.columnsList) {
                    columnMap.put(obj.colNameApi, obj);

                    if (obj.showOnUI == 'true') {
                        ColumnDataWrapper colWra = new ColumnDataWrapper();
                        colWra.apiName = obj.colNameApi;
                        colWra.label = obj.colNameLabel;
                        colWra.type = obj.type;
                        colWra.hasSorting = obj.isSortable == 'true'
                            ? true
                            : false;
                        colWra.isAsc = false;
                        colWra.isDesc = false;
                        colWra.sortIcon = true;

                        columnLabelList.add(colWra);
                    }
                }

                if (columnMap != null && columnMap.size() > 0) {
                    colList = new List<String>(columnMap.keySet());

                    String query = 'SELECT Id, ';
                    query += String.join(colList, ',');
                    query += ' FROM ' + objectName;
                    query += ' WHERE ' + parentFieldName + ' = \'' + String.escapeSingleQuotes(parentId) + '\'';
                    List<Sobject> data = Database.query(query);

                    for (Sobject obj : data) {
                        RowWrapper rowWrap = new RowWrapper();
                        List<DataWrapper> dataWrapList = new List<DataWrapper>();

                        for (String key : columnMap.keySet()) {
                            if (columnMap.get(key).showOnUI == 'true') {
                                DataWrapper dataWrap = new DataWrapper();

                                dataWrap.id = obj.Id;
                                dataWrap.columnName = key;
                                dataWrap.isHyperLink = Boolean.valueOf(
                                    columnMap.get(key).isLink
                                );
                                String linkId = (Boolean.valueOf(
                                        columnMap.get(key).isLink
                                    ) == true &&
                                    columnMap.get(key).linkField != '')
                                    ? (String) obj.get(
                                          columnMap.get(key).linkField
                                      )
                                    : (String) obj.Id;
                                dataWrap.link = (Boolean.valueOf(
                                        columnMap.get(key).isLink
                                    ) == true)
                                    ? URL.getOrgDomainURL().toExternalForm() +
                                      '/' +
                                      linkId
                                    : null;

                                if (
                                    columnMap.get(key).isParentField == 'true'
                                ) {
                                    if (columnMap.get(key).type == 'date') {
                                        Datetime temp = obj.getSobject(
                                                columnMap.get(key)
                                                    .parentObjectName
                                            ) != null
                                            ? (DateTime) obj.getSobject(
                                                      columnMap.get(key)
                                                          .parentObjectName
                                                  )
                                                  .get(
                                                      columnMap.get(key)
                                                          .parentObjectField
                                                  )
                                            : null;
                                        dataWrap.data = converDateFormat(temp);
                                    } else {
                                        dataWrap.data = obj.getSobject(
                                                columnMap.get(key)
                                                    .parentObjectName
                                            ) != null
                                            ? (String) obj.getSobject(
                                                      columnMap.get(key)
                                                          .parentObjectName
                                                  )
                                                  .get(
                                                      columnMap.get(key)
                                                          .parentObjectField
                                                  )
                                            : null;
                                    }
                                } else {
                                    if (columnMap.get(key).type == 'date') {
                                        Datetime temp = (DateTime) obj.get(key);
                                        dataWrap.data = converDateFormat(temp);
                                    } else if (columnMap.get(key).type.toLowerCase() == 'currency'){
                                        dataWrap.data = '$'+String.valueOf(
                                            obj.get(key)
                                        );
                                    } else {
                                        dataWrap.data = String.valueOf(
                                            obj.get(key)
                                        );
                                    }
                                }
                                dataWrapList.add(dataWrap);
                            }
                        }

                        rowWrap.row = dataWrapList;
                        rowWrap.id = obj.Id;
                        rowWrapList.add(rowWrap);
                    }
                }
                result.put('columns', columnLabelList);
                result.put('data', rowWrapList);
            }
            return result;
        } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_RelatedListCmpController', 'getData', e);
            throw new AuraHandledException(e.getMessage() + e.getLineNumber());
        }
    }


    /**
    * @description This function will format the Date in MM/DD/YYYY.
    * @author Ayush Dev | 05-06-2024 
    * @param value 
    * @return String 
    **/
    public static String converDateFormat(Datetime value) {
        if (value != null) {
            Datetime dat = Datetime.newInstance(
                value.year(),
                value.month(),
                value.day()
            );
            return dat.format('MM/dd/yyyy');
        } else {
            return '';
        }
    }

    public class ColumnWrapper {
        @AuraEnabled
        public List<ColumnValueWrapper> columnsList;
    }

    public class ColumnValueWrapper {
        @AuraEnabled
        public String colNameLabel;
        @AuraEnabled
        public String colNameApi;
        @AuraEnabled
        public String isSortable;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public String showOnUI;
        @AuraEnabled
        public String isLink;
        @AuraEnabled
        public String linkField;
        @AuraEnabled
        public String isParentField;
        @AuraEnabled
        public String parentObjectName;
        @AuraEnabled
        public String parentObjectField;
    }

    public class ColumnDataWrapper {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String apiName;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public Boolean hasSorting;
        @AuraEnabled
        public Boolean isAsc;
        @AuraEnabled
        public Boolean isDesc;
        @AuraEnabled
        public Boolean sortIcon;
    }

    public class RowWrapper {
        @AuraEnabled
        public List<DataWrapper> row;
        @AuraEnabled
        public String id;
    }

    public class DataWrapper {
        @AuraEnabled
        public String data;
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String columnName;
        @AuraEnabled
        public Boolean isHyperLink;
        @AuraEnabled
        public String link;
    }
}