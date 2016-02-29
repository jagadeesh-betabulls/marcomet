package com.marcomet.tools;

public class StringTool
{

	public StringTool()
	{
		super();
	}
	
	public String mysqlFormatDate(String tempDate)
	throws Exception{
		//12/31/2001

		if(tempDate == null || tempDate.equals("")){
			return "";
		}
		try{
			int pos1 = tempDate.indexOf("/",0);
			String tempMonth = tempDate.substring(0,pos1);
			int pos2 = tempDate.indexOf("/",pos1+1);
			String tempDay = tempDate.substring(pos1 + 1 , pos2);
			String tempYear = tempDate.substring(pos2 + 1);
			return  tempYear+ "-" + tempMonth + "-" + tempDay;
			//2001-12-31
		}catch(StringIndexOutOfBoundsException sobe){
			throw new Exception("mysqlFormatDate(): |"+ tempDate + "|" + sobe.getMessage());
		}
	}
	public String replaceSubstring(String source, String target, String replacement){

		String returnstring = "";
		int size;
		int pos;

		size = target.length();

		while(source.indexOf(target) != -1){
			pos = source.indexOf(target);

			returnstring = returnstring + source.substring(0,pos) + replacement;
			source = source.substring(pos + size);
		}
		return returnstring + source;

	}
	static public String replaceSubstringSt(String source, String target, String replacement){

		String returnstring = "";
		int size;
		int pos;

		size = target.length();

		while(source.indexOf(target) != -1){
			pos = source.indexOf(target);

			returnstring = returnstring + source.substring(0,pos) + replacement;
			source = source.substring(pos + size);
		}
		return returnstring + source;

	}
	public String unMysqlFormatDate(String tempDate)
	throws Exception{
		//2001-12-31
		if(tempDate == null || tempDate.equals("")){
			return "";
		}

		try{
			int pos1 = tempDate.indexOf("-",0);
			String tempYear = tempDate.substring(0,pos1);
			int pos2 = tempDate.indexOf("-",pos1+1);
			String tempMonth = tempDate.substring(pos1 + 1 , pos2);
			String tempDay = tempDate.substring(pos2 + 1);

			return  tempMonth+ "/" + tempDay + "/" + tempYear;
			//12/31/2001
		}catch(StringIndexOutOfBoundsException sobe){
			throw new Exception("unMysqlFormatDate(): |"+ tempDate + "|" + sobe.getMessage());
		}	
	}
}
