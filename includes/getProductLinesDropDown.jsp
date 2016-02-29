<%@ page errorPage="/errors/ExceptionPage.jsp" %><%response.addHeader("Content-Type" ,"text/xml"); %><?xml version="1.0" encoding="UTF-8"?>
<%@ page import="java.sql.*,java.util.*,com.marcomet.users.security.*, com.marcomet.jdbc.*,com.marcomet.tools.*, com.marcomet.environment.*;" %>
<%@ taglib uri="/WEB-INF/tld/formTagLib.tld" prefix="ft" %>
<%
	String brandCode=((request.getParameter("brandCode")==null)?"0":request.getParameter("brandCode"));
	String fieldName=((request.getParameter("fieldName")==null)?"prodLineId":request.getParameter("fieldName"));
	String selected=((request.getParameter("selected")==null)?"":request.getParameter("selected"));
	String extraCode=((request.getParameter("extraCode")==null)?"class=\"text-list\"":request.getParameter("extraCode"));
	String extraFirstOption=((request.getParameter("extraFirstOption")==null)?"<option value=\"\" selected>Select Product Line</option>":request.getParameter("extraFirstOption"));
	
	String sqlDD=((request.getParameter("sSTR")==null)?"select p.id as 'value',prod_line_name as 'text' from product_lines p left join brands b on p.brand_code=b.brand_code where b.active=1 and b.brand_code='"+brandCode+"' and p.status_id=2 order by prod_line_name":request.getParameter("sSTR"));
	Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
	Statement st = conn.createStatement();
	ResultSet rsDD=st.executeQuery(sqlDD);
	int x=0;
	String selStr="<![CDATA[&nbsp;]]>";
	while(rsDD.next()){
		if(rsDD.getString("value")!=null){
			selStr=rsDD.getString("value");
			x++;
		}
	}
	if(x==1){
		selected=selStr;
		extraFirstOption="";
	}
	if(x>0){
%><result><numChoices><%=x%></numChoices><selected><%=selStr%></selected><ddStr><![CDATA[<ft:SQLDropDownTag dropDownName="<%=fieldName%>" sql="<%=sqlDD%>" selected="<%=selected%>" extraCode="<%=extraCode%>" extraFirstOption="<%=extraFirstOption%>" />]]></ddStr>
</result><%}else{
	%><result><numChoices><%=x%></numChoices><selected><%=selStr%></selected><ddStr><![CDATA[&nbsp;]]></ddStr></result><%
}%>