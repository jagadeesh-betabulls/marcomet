/**********************************************************************
Description:	This tag produces a set of drop downs representing a date
				this propulates a hidden field for insertion into the db.
**********************************************************************/

package com.marcomet.taglibs;

import java.io.IOException;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.TagSupport;

public class DropDownDateTag extends TagSupport {

	private String selectedDay = "01";
	private String selectedMonth = "01";
	private String selectedYear = "2001";
	private String dropDownMonthName = "dateMonth";
	private String dropDownDayName = "dateDay";
	private String dropDownYearName = "dateYear";
	private String extraCode = ""; //"onChange=\"popDateField('shipdate')\"";

	public final int doEndTag() throws JspException {

		StringBuffer output = new StringBuffer();
		
		//Build month drop down section
		output.append("<select name=\"");
		output.append(dropDownMonthName);
		output.append("\" ");
		output.append(extraCode);
		output.append(" >");
		
		output.append("<option value=\"01\"");
		output.append((selectedMonth.equals("01"))?" selected ":"");
		output.append(">January</option>");
		
		output.append("<option value=\"02\"");
		output.append((selectedMonth.equals("02"))?" selected ":"");
		output.append(">Feburary</option>");
		
		output.append("<option value=\"03\"");
		output.append((selectedMonth.equals("03"))?" selected ":"");
		output.append(">March</option>");
		
		output.append("<option value=\"04\"");
		output.append((selectedMonth.equals("04"))?" selected ":"");
		output.append(">April</option>");
		
		output.append("<option value=\"05\"");
		output.append((selectedMonth.equals("05"))?" selected ":"");
		output.append(">May</option>");
		
		output.append("<option value=\"06\"");
		output.append((selectedMonth.equals("06"))?" selected ":"");
		output.append(">June</option>");
		
		output.append("<option value=\"07\"");
		output.append((selectedMonth.equals("07"))?" selected ":"");
		output.append(">July</option>");
		
		output.append("<option value=\"08\"");
		output.append((selectedMonth.equals("08"))?" selected ":"");
		output.append(">August</option>");
		
		output.append("<option value=\"09\"");
		output.append((selectedMonth.equals("09"))?" selected ":"");
		output.append(">September</option>");
		
		output.append("<option value=\"10\"");
		output.append((selectedMonth.equals("10"))?" selected ":"");
		output.append(">October</option>");
		
		output.append("<option value=\"11\"");
		output.append((selectedMonth.equals("11"))?" selected ":"");
		output.append(">November</option>");
		
		output.append("<option value=\"12\"");
		output.append((selectedMonth.equals("12"))?" selected ":"");
		output.append(">December</option>");		
		
		output.append("</select>");
		
		//build day section
		output.append("<select name=\"");
		output.append(dropDownDayName);
		output.append("\" ");
		output.append(extraCode);
		output.append(" >");
		
		output.append("<option value=\"01\"");
		output.append((selectedDay.equals("01"))?" selected ":"");
		output.append(">1</option>");

		output.append("<option value=\"02\"");
		output.append((selectedDay.equals("02"))?" selected ":"");
		output.append(">2</option>");

		output.append("<option value=\"03\"");
		output.append((selectedDay.equals("03"))?" selected ":"");
		output.append(">3</option>");

		output.append("<option value=\"04\"");
		output.append((selectedDay.equals("04"))?" selected ":"");
		output.append(">4</option>");

		output.append("<option value=\"05\"");
		output.append((selectedDay.equals("05"))?" selected ":"");
		output.append(">5</option>");

		output.append("<option value=\"06\"");
		output.append((selectedDay.equals("06"))?" selected ":"");
		output.append(">6</option>");

		output.append("<option value=\"07\"");
		output.append((selectedDay.equals("07"))?" selected ":"");
		output.append(">7</option>");

		output.append("<option value=\"08\"");
		output.append((selectedDay.equals("08"))?" selected ":"");
		output.append(">8</option>");

		output.append("<option value=\"09\"");
		output.append((selectedDay.equals("09"))?" selected ":"");
		output.append(">9</option>");

		output.append("<option value=\"10\"");
		output.append((selectedDay.equals("10"))?" selected ":"");
		output.append(">10</option>");

		output.append("<option value=\"11\"");
		output.append((selectedDay.equals("11"))?" selected ":"");
		output.append(">11</option>");

		output.append("<option value=\"12\"");
		output.append((selectedDay.equals("11"))?" selected ":"");
		output.append(">12</option>");			

		output.append("<option value=\"13\"");
		output.append((selectedDay.equals("13"))?" selected ":"");
		output.append(">13</option>");

		output.append("<option value=\"14\"");
		output.append((selectedDay.equals("14"))?" selected ":"");
		output.append(">14</option>");

		output.append("<option value=\"15\"");
		output.append((selectedDay.equals("15"))?" selected ":"");
		output.append(">15</option>");

		output.append("<option value=\"16\"");
		output.append((selectedDay.equals("16"))?" selected ":"");
		output.append(">16</option>");

		output.append("<option value=\"17\"");
		output.append((selectedDay.equals("17"))?" selected ":"");
		output.append(">17</option>");

		output.append("<option value=\"18\"");
		output.append((selectedDay.equals("18"))?" selected ":"");
		output.append(">18</option>");

		output.append("<option value=\"19\"");
		output.append((selectedDay.equals("19"))?" selected ":"");
		output.append(">19</option>");

		output.append("<option value=\"20\"");
		output.append((selectedDay.equals("20"))?" selected ":"");
		output.append(">20</option>");

		output.append("<option value=\"21\"");
		output.append((selectedDay.equals("21"))?" selected ":"");
		output.append(">21</option>");

		output.append("<option value=\"22\"");
		output.append((selectedDay.equals("22"))?" selected ":"");
		output.append(">22</option>");

		output.append("<option value=\"23\"");
		output.append((selectedDay.equals("23"))?" selected ":"");
		output.append(">23</option>");

		output.append("<option value=\"24\"");
		output.append((selectedDay.equals("24"))?" selected ":"");
		output.append(">24</option>");			

		output.append("<option value=\"25\"");
		output.append((selectedDay.equals("25"))?" selected ":"");
		output.append(">25</option>");

		output.append("<option value=\"26\"");
		output.append((selectedDay.equals("26"))?" selected ":"");
		output.append(">26</option>");

		output.append("<option value=\"27\"");
		output.append((selectedDay.equals("27"))?" selected ":"");
		output.append(">27</option>");

		output.append("<option value=\"28\"");
		output.append((selectedDay.equals("28"))?" selected ":"");
		output.append(">28</option>");

		output.append("<option value=\"29\"");
		output.append((selectedDay.equals("29"))?" selected ":"");
		output.append(">29</option>");

		output.append("<option value=\"30\"");
		output.append((selectedDay.equals("30"))?" selected ":"");
		output.append(">30</option>");

		output.append("<option value=\"31\"");
		output.append((selectedDay.equals("31"))?" selected ":"");
		output.append(">31</option>");

		output.append("</select>");	
		
		//build year section
		output.append("<select name=\"");
		output.append(dropDownYearName);
		output.append("\" ");
		output.append(extraCode);
		output.append(" >");
		
		output.append("<option value=\"2001\"");
		output.append((selectedYear.equals("2001"))?" selected ":"");
		output.append(">2001</option>");

		output.append("<option value=\"2002\"");
		output.append((selectedYear.equals("2002"))?" selected ":"");
		output.append(">2002</option>");

		output.append("<option value=\"2003\"");
		output.append((selectedYear.equals("2003"))?" selected ":"");
		output.append(">2003</option>");

		output.append("<option value=\"2004\"");
		output.append((selectedYear.equals("2004"))?" selected ":"");
		output.append(">2004</option>");

		output.append("<option value=\"2005\"");
		output.append((selectedYear.equals("2005"))?" selected ":"");
		output.append(">2005</option>");

		output.append("<option value=\"2006\"");
		output.append((selectedYear.equals("2006"))?" selected ":"");
		output.append(">2006</option>");

		output.append("<option value=\"2007\"");
		output.append((selectedYear.equals("2007"))?" selected ":"");
		output.append(">2007</option>");

		output.append("<option value=\"2008\"");
		output.append((selectedYear.equals("2008"))?" selected ":"");
		output.append(">2008</option>");

		output.append("<option value=\"2009\"");
		output.append((selectedYear.equals("2009"))?" selected ":"");
		output.append(">2009</option>");

		output.append("<option value=\"2010\"");
		output.append((selectedYear.equals("2010"))?" selected ":"");
		output.append(">2010</option>");		

		output.append("</select>");
			
		dropDownMonthName = "dateMonth";
		dropDownDayName = "dateDay";
		dropDownYearName = "dateYear";	
		
		try {
	
			pageContext.getOut().print(output);
					
		} catch (IOException ex) {
			throw new JspException(ex.getMessage());	
		}
		return EVAL_PAGE;
	}
	public final void release() {
		super.release();
	}
	public final void setExtraCode(String temp){
		this.extraCode = temp;
	}
	public final void setSelectedDay(String temp){
		this.selectedDay = temp;
	}
	public final void setSelectedMonth(String temp){
		this.selectedMonth = temp;
	}
	public final void setSelectedYear(String temp){
		this.selectedYear = temp;
	}
	public final void setDropDownMonthName(String temp){
		this.dropDownMonthName = temp;
	}
	public final void setDropDownDayName(String temp){
		this.dropDownDayName = temp;
	}
	public final void setDropDownYearName(String temp){
		this.dropDownYearName = temp;
	}	
		
}
