package com.marcomet.tools;

/**********************************************************************
Description:	This class will used on jsp pages/classes for simple 
				formating of information.

History:
	Date		Author			Description
	----		------			-----------
	4/19/2001	Thomas Dietrich	Created
	5/14/2001	td				added ablity to unmysql a date.

**********************************************************************/

import java.text.*;
import java.util.*;


public class FormaterTool {


	public FormaterTool() {
	}
	public String formatMysqlDate(String tempDate) throws Exception{
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
			//removed so that it exits gracfully
			//throw new Exception("formater failed: |"+ tempDate + "|" + sobe.getMessage());
			return tempDate;
		}	
	}
	public String formatTimeStamp(String tempDate) {
		//20010514110458
		if(tempDate == null || tempDate.equals("")){
			return "";
		}
				
		String tempYear = tempDate.substring(0,4);
		String tempMonth = tempDate.substring(4,6);
		String tempDay = tempDate.substring(6,8);
		
		return tempMonth + "/" + tempDay + "/" + tempYear;
		//05/14/2001
	}
	public String getCurrency(double cash) {
		NumberFormat nf = NumberFormat.getCurrencyInstance(Locale.US); 
		return  nf.format(cash); 
	}
	public String getCurrency(String cash) {
		try {
			return getCurrency(Double.parseDouble(cash));
		}catch(NumberFormatException nfe) {
			return "$0.00";
		}catch(NullPointerException npe) {
			return "$0.00";
		}	
	}
}
