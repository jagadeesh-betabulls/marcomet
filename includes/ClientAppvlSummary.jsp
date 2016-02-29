<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*,com.marcomet.environment.*;" %>
<jsp:useBean id="connection" class="com.marcomet.jdbc.ConnectionBean" scope="session" />
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<% UserProfile up = (UserProfile)session.getAttribute("userProfile");
   SiteHostSettings shs = (SiteHostSettings)session.getAttribute("siteHostSettings"); 
%><script language="JavaScript" src="/javascripts/mainlib.js"></script><table width="100%"><%
      String appvlQuery = "SELECT a.group_id, a.job_id FROM jobs j, projects pr, orders o,form_messages a LEFT OUTER JOIN form_messages b on a.job_id = b.job_id AND a.group_id = b.group_id AND ((a.form_id = 1 OR a.form_id = 2) AND b.form_id = 8) WHERE (a.form_id = 1 OR a.form_id = 2) AND b.group_id IS NULL AND a.job_id = j.id AND j.project_id = pr.id AND pr.order_id = o.id AND o.buyer_contact_id = "+ up.getContactId() +" order by a.time_stamp";
int i = 0;
	String shTarget="mainFr";
		Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
		Statement st = conn.createStatement();
ResultSet appvlRS = st.executeQuery(appvlQuery); 
while (appvlRS.next()) { 
	if (i==0){
		%><tr> 
    <td align="center" valign='middle' class="leftNavBarItemOver2" height='25'><span class='leftNavBarItemHover2'>Your Approvals Pending:</span>
    </td>
  </tr><%}%>
  <tr> 
          <td class="leftNavBarItem2" onMouseOver="this.className='leftNavBarItemOver2';lnk<%=appvlRS.getInt("a.job_id")%>.className='leftNavBarItemHover2'" onMouseOut="this.className='leftNavBarItem2';lnk<%=appvlRS.getInt("a.job_id")%>.className='leftNavBarItem2'" height="18"><a class="leftNavBarItem2" href="/minders/workflowforms/AdHocApproveCompProof.jsp?groupId=<%=appvlRS.getInt("group_id")%>&jobId=<%=appvlRS.getInt("a.job_id")%>" id='lnk<%=appvlRS.getInt("a.job_id")%>' target="<%=shTarget%>">Appv Work on Job <%=appvlRS.getString("a.job_id")%></a></td>
        </tr>
        <% 
i = i + 1;
 }
if (i==0){%><tr><td></td></tr><%}%></table><%
conn.close();
%>
