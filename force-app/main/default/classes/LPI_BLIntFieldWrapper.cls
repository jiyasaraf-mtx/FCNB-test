/**
 * @description       :
 * @author            : MTX Group Product Team
 * @group             :
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
 **/
public class LPI_BLIntFieldWrapper {
    public List<LPI_BLIntFieldWrapper.Address> licenceAddress { get; set; }
    public List<LPI_BLIntFieldWrapper.Address> publicAddress { get; set; }
    public List<LPI_BLIntFieldWrapper.Address> primaryAddress { get; set; }
    public List<LPI_BLIntFieldWrapper.Address> mailingAddresses { get; set; }
    public List<LPI_BLIntFieldWrapper.Address> branchAddresses { get; set; }
    public List<LPI_BLIntFieldWrapper.Address> businessAddresses { get; set; }
    public List<LPI_BLIntFieldWrapper.Address> residenceAddresses {
        get;
        set;
    }
    public List<LPI_BLIntFieldWrapper.Entity> relatedEntity { get; set; }
    public List<LPI_BLIntFieldWrapper.perExam> personExam { get; set; }
    public List<LPI_BLIntFieldWrapper.perEdu> personEducation { get; set; }
    public List<LPI_BLIntFieldWrapper.Discipline> licenseDiscipline { get; set; }
    public LPI_BLIntFieldWrapper.Relation childEntity { get; set; }

    public class perExam {
        public Boolean isRetake { get; set; }
        public String exSection { get; set; }
        public Datetime exDate { get; set; }
        public String exSecResult { get; set; }
        public Integer exSecScore { get; set; }
        public String exName { get; set; }
    }

    public class perEdu {
        public String instName { get; set; }
        public String eduName { get; set; }
        public String degType { get; set; }
        public String eduCity { get; set; }
        public String eduState { get; set; }
        public String eduZip { get; set; }
        public String eduCountry { get; set; }
        public Datetime gradDt { get; set; }
    }

    public class Address {
        public String street { get; set; }
        public String city { get; set; }
        public String state { get; set; }
        public String stateCode { get; set; }
        public String zipCode { get; set; }
        public String country { get; set; }
        public String countryCode { get; set; }
        public String county { get; set; }
        public Date effDate { get; set; }
    }
    
    public class Violation {
        public String violationType { get; set; }
        public Datetime discStartDt { get; set; }
        public Datetime discEndDt { get; set; }
        public String discTerms { get; set; }
        public String reportFlag { get; set; }
        public String sfId { get; set; }
    }
    
    public class Codefandant {
        public String cid { get; set; }
    }

    public class Entity {
        public String busName { get; set; }
        public List<LPI_BLIntFieldWrapper.Address> mailingAddresses {
            get;
            set;
        }
        public List<LPI_BLIntFieldWrapper.Address> businessAddresses {
            get;
            set;
        }
        public List<LPI_BLIntFieldWrapper.Address> residenceAddresses {
            get;
            set;
        }
        public List<LPI_BLIntFieldWrapper.Address> branchAddresses { get; set; }
        public List<LPI_BLIntFieldWrapper.Address> licenceAddress { get; set; }
        public List<LPI_BLIntFieldWrapper.Address> primaryAddress { get; set; }
        public List<LPI_BLIntFieldWrapper.Address> publicAddress { get; set; }
        public String prcName { get; set; }
        public String licNo { get; set; }
    }
    
    public class Discipline {
        public String boardName { get; set; }
        public String primCategory { get; set; }
        public String secCategory { get; set; }
        public String status { get; set; }
        public List<LPI_BLIntFieldWrapper.Violation> rcv {
            get;
            set;
        }
        public List<LPI_BLIntFieldWrapper.Codefandant> cod {
            get;
            set;
        }
    }
    
    public class Relation {
        public String relType { get; set; }
        public String firstName { get; set; }
        public String midName { get; set; }
        public String lastName { get; set; }
        public String suffix { get; set; }
        public String prcName { get; set; }
        public String licNo { get; set; }
        public List<LPI_BLIntFieldWrapper.Address> mailingAddresses {
            get;
            set;
        }
        public List<LPI_BLIntFieldWrapper.Address> businessAddresses {
            get;
            set;
        }
        public List<LPI_BLIntFieldWrapper.Address> residenceAddresses {
            get;
            set;
        }
        public List<LPI_BLIntFieldWrapper.Address> branchAddresses { get; set; }
        public List<LPI_BLIntFieldWrapper.Address> licenceAddress { get; set; }
        public List<LPI_BLIntFieldWrapper.Address> primaryAddress { get; set; }
        public List<LPI_BLIntFieldWrapper.Address> publicAddress { get; set; }
    }
}