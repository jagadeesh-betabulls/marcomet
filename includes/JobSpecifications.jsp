<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.text.*,java.sql.*,java.util.*,com.marcomet.environment.*,com.marcomet.jdbc.*,com.marcomet.tools.*,com.marcomet.users.security.*" %>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%
Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
boolean editor=(((RoleResolver)session.getAttribute("roles")).roleCheck("editor"));
String jobId=((request.getParameter("jobId")==null)?"":request.getParameter("jobId"));
ResultSet rs1 = st.executeQuery("SELECT ls.value AS label, js.value AS value,js.id as id FROM job_specs js, lu_specs ls, catalog_specs cs WHERE ls.id != 88888 AND ls.id != 99999 AND ls.id = cs.spec_id AND cs.id = js.cat_spec_id AND js.job_id = " + jobId + " ORDER BY ls.sequence");
			%><table border="0">
			<tr><td class="tableheader">Specification</td><td class="tableheader">Spec Value</td></tr><%
			while (rs1.next()){  
	   			%><tr><td class="label" width=30%><%=rs1.getString("label")%></td>
	   			<td class="body"><%
	   			if (editor){
	   				%><a href='javascript:popw("/popups/QuickChangeForm.jsp?cols=60&rows=3&question=Change%20<%=rs1.getString("label")%>&primaryKeyValue=<%=rs1.getString("id")%>&columnName=value&tableName=job_specs&valueType=string",500,200)' class='minderLink'>&raquo;&nbsp;<%=rs1.getString("value")%></a><%	   			}else{
	   				%><%=rs1.getString("value")%></td></tr><%
	   			}
			}
%></table><%  
	st.close();
	conn.close();
%>