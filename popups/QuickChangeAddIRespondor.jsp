<%@ page import="java.io.*,java.lang.Object.*,java.sql.*,java.util.*,java.util.Enumeration,java.text.*,com.marcomet.users.security.*, com.marcomet.jdbc.*, com.marcomet.environment.*;" %>


<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ taglib uri="/WEB-INF/tld/formTagLib.tld" prefix="formtaglib" %>
<jsp:useBean id="sl" class="com.marcomet.tools.SimpleLookups" scope="page" />
<%

Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();

String query="";
String headerStr="";

String contactId=session.getAttribute("contactId").toString();
String surveyId=request.getParameter("surveyId");
String surveyURL="";
String surveyWidth="400";
String surveyHeight="400";

int changed=0;
int x=1;
int y=1;
boolean closeThis=false;

if (request.getParameter("submitted")!=null && request.getParameter("submitted").equals("true")){
	try{
		surveyURL=((request.getParameter("responseVal")!=null && request.getParameter("responseVal").equals("responded"))?sl.getValue("surveys","id",surveyId, "survey_link"):"");
	
		query="insert into survey_responses (invite_response, contact_id, survey_id,ip_address,response_header) values ( '"+request.getParameter("responseVal")+"', '"+contactId+"', '"+request.getParameter("surveyId")+"','"+request.getRemoteAddr()+"','"+headerStr+"')";
		st.executeUpdate(query);
		closeThis=true;
	}catch (Exception e){
		%><br><%=query%><br><%
	}
}else{
%><html>
<head>
  <title>Respond to Survey Request</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<body>
<form method="post" action=""><br><br>
<blockquote>
<div class="subtitle"><%=sl.getValue("surveys","id",surveyId, "invitation_text")%></div></td>
<br>
<div align="center">
<input type="button" onClick="respondNow('never')" name="btnNever" value="I'd rather not respond at all." id="btnNever" />&nbsp;&nbsp;
<input type="button" onClick="respondNow('later')" name="btnLater" value="Please ask me later." id="btnLater"  />&nbsp;&nbsp;
<input type="button" onClick="respondNow('responded')" name="btnNow" value="OK, Let's start." id="btnNow"  /></div>
</blockquote>
<input type="hidden" name="responseVal" value="">
<input type="hidden" name="submitted" value="">
<input type="hidden" name="surveyId" value="<%=surveyId%>">

<script>
	function respondNow(responseValStr){
		document.forms[0].responseVal.value=responseValStr;
		document.forms[0].submitted.value='true';
		document.forms[0].submit();
	}
</script>
</form>
</body>
</html><%}
	st.close();
	conn.close();
%><%if (!surveyURL.equals("")){
	%><html><head><script>parent.popSurveyLink("<%=surveyURL%>","<%=sl.getValue("surveys","id",surveyId, "survey_width")%>","<%=sl.getValue("surveys","id",surveyId, "survey_height")%>")</script></head></html><%
}else if (closeThis){
	%><html><head><link rel="stylesheet" href="/styles/modalbox.css" type="text/css">
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<script type="text/javascript" src="/javascripts/prototype1.js"></script>
<script type="text/javascript" src="/javascripts/scriptaculous1.js"></script>
<script type="text/javascript" src="/javascripts/modalbox1.js"></script><script>parent.AjaxModalBox.close();</script></head></html><%
}%>
