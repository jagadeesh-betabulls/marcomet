<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*,com.marcomet.environment.*;" %>
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<jsp:useBean id="str" class="com.marcomet.tools.StringTool" scope="page" />
<%
	String ShowInactive=((request.getParameter("ShowInactive")==null || request.getParameter("ShowInactive").equals(""))?"":"&ShowInactive="+request.getParameter("ShowInactive")); 
	String ShowRelease=((request.getParameter("ShowRelease")==null || request.getParameter("ShowRelease").equals(""))?"":"&ShowRelease="+request.getParameter("ShowRelease"));
String sitehostId=((request.getParameter("siteHostId")==null || request.getParameter("siteHostId").equals(""))?"":request.getParameter("siteHostId"));
String campaignId=((request.getParameter("campaignId")==null || request.getParameter("campaignId").equals(""))?"":request.getParameter("campaignId"));
String pageName=((request.getParameter("pageName")==null || request.getParameter("pageName").equals(""))?"":request.getParameter("pageName"));
String domainName=((request.getParameter("domainName")==null || request.getParameter("domainName").equals(""))?"":request.getParameter("domainName"));
String siteHostName=((request.getParameter("siteHostName")==null || request.getParameter("siteHostName").equals(""))?"":request.getParameter("siteHostName"));
String sql = "Select * from email_campaigns where id="+campaignId;
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
ResultSet rsProds = st.executeQuery(sql);
int x=0;
int y=0;
if(rsProds.next()){
  %><%}%>