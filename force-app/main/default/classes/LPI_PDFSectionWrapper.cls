/**
 * @author                      : MTX Group Product Team
 * @since                       : march 22,2023
 * @description                 : This is a wrapper class for PDF Section
 *-------------------------------------------------------------------------------------------------------
 * Version      Date                Author                  Details
 *    1         22 Mar, 2023        MTX Group Product Team             Initial Developement
 * -------------------------------------------------------------------------------------------------------
 */
public with sharing class LPI_PDFSectionWrapper {
    public String sectionName { get; set; }
    public Boolean showHeadingAsRegularText { get; set; }
    public List<SectionRowWrapper> sectionRowList { get; set; }
    public Integer numberOfColumns { get; set; }
    public List<LPI_PDFSectionWrapper> subSectionList { get; set; }
    public List<LicenseQuestionWrapper> licenseQuestionsList { get; set; }
    public boolean isJSONStoredSection { get; set; }
    public final static Integer MAX_LENGTH = 114;

    /**
     * @author                      : MTX Group Product Team
     * @since                       : march 24,2023
     * @description                 : Default Contructor
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
    public LPI_PDFSectionWrapper() {
        this.sectionName = '';
        this.numberOfColumns = 3;
        this.sectionRowList = new List<SectionRowWrapper>();
        this.subSectionList = new List<LPI_PDFSectionWrapper>();
        this.isJSONStoredSection = false;
        this.showHeadingAsRegularText = false;
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : march 24,2023
     * @description                 : Most Commonly used contructor
     * @param sectionName           : String
     * @param numberOfColumns       : Integer
     * @param dataList              : List<DataWrapper>
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
    public LPI_PDFSectionWrapper(String sectionName, Integer numberOfColumns, List<DataWrapper> dataList) {
        this.sectionName = sectionName;
        this.sectionRowList = new List<SectionRowWrapper>();
        this.numberOfColumns = numberOfColumns;
        this.subSectionList = new List<LPI_PDFSectionWrapper>();
        this.isJSONStoredSection = false;
        this.showHeadingAsRegularText = false;
        if (dataList != null && !dataList.isEmpty()) {
            this.createRowsForSection(dataList);
        }
    }
    

    /**
     * @author                      : MTX Group Product Team
     * @since                       : march 30,2023
     * @description                 : Use this wrapper if you want to show section heading as a normal text
     * @param sectionName           : String
     * @param numberOfColumns       : Integer
     * @param dataList              : List<DataWrapper>
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
    public LPI_PDFSectionWrapper(
        String sectionName,
        Integer numberOfColumns,
        List<DataWrapper> dataList,
        Boolean showHeadingAsRegularText
    ) {
        this.sectionName = sectionName;
        this.sectionRowList = new List<SectionRowWrapper>();
        this.numberOfColumns = numberOfColumns;
        this.subSectionList = new List<LPI_PDFSectionWrapper>();
        this.isJSONStoredSection = false;
        this.showHeadingAsRegularText = showHeadingAsRegularText;
        if (dataList != null && !dataList.isEmpty()) {
            this.createRowsForSection(dataList);
        }
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : march 24,2023
     * @description                 : This Constructor we can use if we are creating section for license questions like steps
     * @param sectionName           : String
     * @param licenseQuestionsList  : List<LicenseQuestionWrapper>
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
    public LPI_PDFSectionWrapper(String sectionName, List<LicenseQuestionWrapper> licenseQuestionsList) {
        this.sectionName = sectionName;
        this.licenseQuestionsList = licenseQuestionsList;
        this.subSectionList = new List<LPI_PDFSectionWrapper>();
        this.isJSONStoredSection = true;
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : march 24,2023
     * @description                 : A Private method that will create rows for a section
     * @param dataList              : List<DataWrapper>
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
    @TestVisible
    private void createRowsForSection(List<DataWrapper> dataList) {
        SectionRowWrapper rowWrapper = new SectionRowWrapper();
        Integer counter = 1;
        for (DataWrapper data : dataList) {
            rowWrapper.addDataElement(data,this.numberOfColumns);
            if (Math.mod(counter, this.numberOfColumns) == 0) {
                this.sectionRowList.add(rowWrapper);
                rowWrapper = new SectionRowWrapper();
            }
            counter += 1;
        }

        if (!rowWrapper.rowDataList.isEmpty()) {
            this.sectionRowList.add(rowWrapper);
        }
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : march 24,2023
     * @description                 : A Private method that will add single subsection to a section
     * @param subSection            : LPI_PDFSectionWrapper
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
    public void addSubSection(LPI_PDFSectionWrapper subSection) {
        this.subSectionList.add(subSection);
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : march 24,2023
     * @description                 : A Private method that will add List of subsection to a section
     * @param subSection            : List<LPI_PDFSectionWrapper>
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
    public void addSubSection(List<LPI_PDFSectionWrapper> subSection) {
        this.subSectionList.addAll(subSection);
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : march 28,2023
     * @description                 : If you have used default contructor use this method to add section
     * @param sectionName           : String
     * @param numberOfColumns       : Integer
     * @param dataList              : List<DataWrapper>
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
    public void addSection(String sectionName, Integer numberOfColumns, List<DataWrapper> dataList) {
        this.sectionName = sectionName;
        this.sectionRowList = new List<SectionRowWrapper>();
        this.numberOfColumns = numberOfColumns;
        this.subSectionList = new List<LPI_PDFSectionWrapper>();
        this.isJSONStoredSection = false;
        if (dataList != null && !dataList.isEmpty()) {
            this.createRowsForSection(dataList);
        }
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : march 24,2023
     * @description                 : A Wrapper class that we will use only for JSON stored sections (Like License Questions etc)
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
    @TestVisible
    public class LicenseQuestionWrapper {
        @TestVisible
        public DataWrapper mainQuestion { get; set; }
        @TestVisible
        public List<SectionRowWrapper> dependentQRowList { get; set; }
        @TestVisible
        public Integer numberOfColumns { get; set; }
        @TestVisible
        private Integer numberOfRows;

        public LicenseQuestionWrapper(DataWrapper mainQuestion, Integer numberOfColumns) {
            this.mainQuestion = mainQuestion;
            this.numberOfColumns = numberOfColumns;
            this.dependentQRowList = new List<SectionRowWrapper>();
            if(mainQuestion != null)
                mainQuestion.transformLength(1);
            this.numberOfRows = 0;
        }

        public void addDependentQuestion(DataWrapper depQuestion) {
            if (
                this.dependentQRowList.isEmpty() ||
                this.dependentQRowList[this.numberOfRows - 1].numberOfElement == this.numberOfColumns
            ) {
                this.dependentQRowList.add(new SectionRowWrapper());
                this.numberOfRows += 1;
            }
            this.dependentQRowList[this.numberOfRows - 1].addDataElement(depQuestion,this.numberOfColumns);
        }
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : march 24,2023
     * @description                 : A Wrapper Class for each row that we are showing on pdf
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
    public class SectionRowWrapper {
        public List<DataWrapper> rowDataList { get; set; }
        public Integer numberOfElement;

        public SectionRowWrapper() {
            this.rowDataList = new List<DataWrapper>();
            this.numberOfElement = 0;
        }

        public void addDataElement(DataWrapper data, Integer numberOfColumns) {
            data.transformLength(numberOfColumns);
            this.rowDataList.add(data);
            this.numberOfElement += 1;
        }
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : march 22,2023
     * @description                 : A Wrapper Class to store information of each label and value on pdf
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
    public class DataWrapper {
        public string fieldLabel { get; set; }
        public String fieldValue { get; set; }
        public String classForField { get; set; }

        public DataWrapper(String fieldLabel, String fieldValue) {
            this.fieldLabel = fieldLabel;
            this.fieldValue = fieldValue;
            this.classForField = 'view-info-label';
        }

        public DataWrapper(String fieldLabel, String fieldValue, String classForField) {
            this.fieldLabel = fieldLabel;
            this.fieldValue = fieldValue;
            this.classForField = classForField;
        }

        public void transformLength(Integer numberofColumn){
            if(numberofColumn>0 && String.isNotBlank(this.fieldValue)){
                Integer lengthOfField = (MAX_LENGTH / numberofColumn)- 5;
                if(!this.fieldValue.contains(' ') && this.fieldValue.length() > lengthOfField){
                    this.fieldValue = this.fieldValue.substring(0,lengthOfField) +'\n'+this.fieldValue.substring(lengthOfField);
                }
            }
        }
    }
}