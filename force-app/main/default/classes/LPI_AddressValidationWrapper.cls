/**
 * @description       : 
 * @author            : MTX Group Inc
 * @group             : 
 * @last modified on  : 05-30-2024
 * @last modified by  : MTX Group Inc
**/
public class LPI_AddressValidationWrapper {
    
    public cls_spatialReference spatialReference;
	public cls_candidates[] candidates;
	class cls_spatialReference {
		public Integer wkid;	//4326
		public Integer latestWkid;	//4326
	}
	public class cls_candidates {
		public String address;	//2612 Spruce Dr, Columbia, Missouri, 65202
		public cls_location location;
		public Double score;	//98.14
		public cls_attributes attributes;
		public cls_extent extent;
	}
	public class cls_location {
		public Double x;	//-92.29868874271452
		public Double y;	//38.98247885232858
	}
	public class cls_attributes {
		public String Status;	//M
		public Double Score;	//98.14
		public String Match_addr;	//2612 Spruce Dr, Columbia, Missouri, 65202
		public String LongLabel;	//2612 Spruce Dr, Columbia, MO, 65202, USA
		public String ShortLabel;	//2612 Spruce Dr
		public String Addr_type;	//PointAddress
		public String Type;	//
		public String PlaceName;	//
		public String Place_addr;	//2612 Spruce Dr, Columbia, Missouri, 65202
		public String Phone;	//
		public String URL;	//
		public Double Rank;	//20
		public String AddBldg;	//
		public String AddNum;	//2612
		public String AddNumFrom;	//
		public String AddNumTo;	//
		public String AddRange;	//
		public String Side;	//
		public String StPreDir;	//
		public String StPreType;	//
		public String StName;	//Spruce
		public String StType;	//Dr
		public String StDir;	//
		public String BldgType;	//
		public String BldgName;	//
		public String LevelType;	//
		public String LevelName;	//
		public String UnitType;	//
		public String UnitName;	//
		public String SubAddr;	//
		public String StAddr;	//2612 Spruce Dr
		public String Block;	//
		public String Sector;	//
		public String Nbrhd;	//
		public String District;	//
		public String City;	//Columbia
		public String MetroArea;	//
		public String Subregion;	//Boone County
		public String Region;	//Missouri
		public String RegionAbbr;	//MO
		public String Territory;	//
		public String Zone;	//
		public String Postal;	//65202
		public String PostalExt;	//2247
		public String Country;	//USA
		public String CntryName;	//United States
		public String LangCode;	//ENG
		public Integer Distance;	//0
		public Double X;	//-92.29868874271452
		public Double Y;	//38.98247885232858
		public Double DisplayX;	//-92.29869
		public Double DisplayY;	//38.982303
		public Double Xmin;	//-92.29969
		public Double Xmax;	//-92.29768999999999
		public Double Ymin;	//38.981303000000004
		public Double Ymax;	//38.983303
		public String ExInfo;	//
	}
	public class cls_extent {
		public Double xmin;	//-92.29969
		public Double ymin;	//38.981303000000004
		public Double xmax;	//-92.29768999999999
		public Double ymax;	//38.983303
	}
    
    
    public static LPI_AddressValidationWrapper parse(String json) {
        return (LPI_AddressValidationWrapper) System.JSON.deserialize(json, LPI_AddressValidationWrapper.class);
    }
}