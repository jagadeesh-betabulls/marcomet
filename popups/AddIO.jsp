<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.text.*,java.io.*,java.sql.*,java.util.*,com.marcomet.jdbc.*,com.marcomet.users.security.*,com.marcomet.workflow.actions.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%@ taglib uri="/WEB-INF/tld/formTagLib.tld" prefix="formtaglib" %>
<%
Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
boolean closeOnExit=((request.getParameter("closeOnExit")!=null && request.getParameter("closeOnExit").equals("true"))?true:false);
String errMsg="";
String showPage="true";

String jobId=((request.getParameter("jobId")==null)?"":request.getParameter("jobId"));
String ioNumber=((request.getParameter("ioNumber")==null)?"":request.getParameter("ioNumber"));
String adNumber=((request.getParameter("adNumber")==null)?"":request.getParameter("adNumber"));

if(request.getParameter("submitted")!=null && request.getParameter("submitted").equals("true")){
	ResultSet rsIO = st.executeQuery("Select io_number from io_ad_bridge where io_number='"+ioNumber+"' and job_id="+jobId);
	if (rsIO.next()){
		errMsg="This insertion order number is already associated with job #"+jobId+".";
	}else{
		String insertIOB="insert into io_ad_bridge (job_id, ad_number, io_number) values ( '"+jobId+"', '"+adNumber+"','"+ioNumber+"' )";
		PreparedStatement stIOB = conn.prepareStatement(insertIOB);
		stIOB.executeUpdate();
		showPage="false";
	}
}

if (showPage.equals("true")){
String ioSQL="Select concat('IO #',io_number,' | Media: ',media_vehicle,': ',Region,', ',unit_size,'| , Creative Start:',creative_start_date,'| ','Ad #',ad_number) as 'text', concat(io_number,'|',ad_number) as 'value' from insertions where io_number is not null and io_number <> '0' and io_number <> '' and io_number <> '0.00' and io_number <> '#N/A' and material_close_date > now() and plan_status <> 'Cancelled'";
%><html>
<head>
<title>Add Insertion Order</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<script>
	function submitThis(){
		if (document.forms[0].ioNumber.value=='' || document.forms[0].ioNumber.value=='~'){
			alert('Please choose an Insertion Order.');
		}else{
			document.forms[0].submit();
		}
	}
	function parseThis(el){
			var args=el.value.split("|");
			document.forms[0].ioNumber.value=args[0];
			document.forms[0].adNumber.value=args[0];
	}
</script>
</head>
<body bgcolor="#FFFFFF" text="#000000">
<form method="post" action="/popups/AddIOt.jsp">
<div class='title'>Choose an Insertion Order:</div>
<%=((errMsg.equals(""))?"":"<div class='subtitle' style='color:red'>"+errMsg+"</div>")%>
 <formtaglib:SQLDropDownTag dropDownName="ioNumberChoice" sql="<%= ioSQL %>" selected="~|~"  extraCode="onChange='parseThis(this)'" extraFirstOption="<option value='~|~'>- Select Insertion Order -</option>" /> 
<table width='100%'><tr><td align="center">
  		<input type="button" value="Add" onClick="submitThis();">
	</td>
	<td align="center">
		<input type="button" value="Cancel" onClick="self.close()">
	</td>	
  </tr>
</table>
<input type='hidden' name='jobId' value='<%=jobId%>'>
<input type='hidden' name='adNumber' value='<%=adNumber%>'>
<input type='hidden' name='ioNumber' value='<%=ioNumber%>'>
<input type='hidden' name='submitted' value='true'>
</form>
</body>
</html><%}else{
%><html><head><script>parent.window.opener.location.reload();setTimeout('close()',500);</script></head></html><%
}
	st.close();
	conn.close();
%>
