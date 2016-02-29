<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.text.*,java.sql.*,java.util.*,com.marcomet.environment.*,com.marcomet.jdbc.*,com.marcomet.tools.*" %>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%
Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
String tempString ="";
StringTool str=new StringTool();
DecimalFormat nf = new DecimalFormat("#,###.00");
DecimalFormat decFormatter = new DecimalFormat("#,###.##");
int numLines=0;
String keyStr="";
int x=0;
String jobId=((request.getParameter("jobId")==null)?"":request.getParameter("jobId"));
String hRow="<table id='io' class='sortable' width='100%' cellpadding=2><tr>";
String ioSQL="Select i.io_number 'K:L:IO-Number',media_vehicle 'L:Media-Vehicle',Region 'L:Region',unit_size 'L:Unit~Size',DATE_FORMAT(creative_start_date,'%m/%d/%Y') 'L:Creative-Start-Date',i.ad_number 'L:Ad-Number' from io_ad_bridge io left join insertions i on io.io_number=i.io_number where job_id="+jobId;

%><link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<span class='subtitle'>Insertion Orders for this Job</span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:popw('/popups/AddIO.jsp?jobId=<%=jobId%>',800,200)" class='menuLink'>&raquo;Click here to Add</a><br><br><%

ResultSet rs = st.executeQuery(ioSQL);
ResultSetMetaData rsmd = rs.getMetaData();
int numberOfColumns = rsmd.getColumnCount();
tempString = null;
Vector headers  = new Vector(15);
for (int i=1 ;i <= numberOfColumns; i++){
	tempString = new String ((String) rsmd.getColumnLabel(i));
	headers.add(tempString);
tempString=str.replaceSubstring(str.replaceSubstring(str.replaceSubstring( str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(tempString,"H:", ""),"F:", ""),"B:", ""),"K:", ""),"C:", ""),"L:", ""),"^"," <br /> "),"-", "&nbsp;");
	hRow+="<td  class='tableheader' >"+tempString+"</td>";
}

hRow+="</tr>";
x=0;
numLines=0;
while (rs.next()){
	hRow+="<tr>";
	for (int i=0;i < numberOfColumns; i++){
		String columnName = (String) headers.get(i);
		String columnValue=((columnName.indexOf("F:")>-1)?nf.format(rs.getDouble(columnName)):((rs.getString(columnName)==null)?"":rs.getString(columnName) ));
		hRow+="<td class='body' align='"+((columnName.indexOf("L:")>-1)?"left":((columnName.indexOf("C:")>-1)?"center":"right"))+"'>";
		if(columnName.indexOf("K:")>-1){
			keyStr=columnValue;
	  		hRow+="<a href='javascript:popw(\"/popups/InsertionOrderPage3.jsp?ioNumber="+columnValue+"\",800,800)'>"+columnValue+"</a>";
		}else{
			hRow+=((columnName.indexOf("B:")>-1)?"<span id='accept"+keyStr+"'>"+columnValue+"</span>":columnValue);
		}
			hRow+="</td>";
		}
		x++;
		hRow+="</tr>";
} 
	hRow+="</table>";
if (x>0){
%><%=hRow%><%
}else{
	%><div class='subtitle'>No Insertions applied.</div><%
}  
	st.close();
	conn.close();
%>