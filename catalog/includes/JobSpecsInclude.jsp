<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="com.marcomet.catalog.*, com.marcomet.jdbc.*, java.sql.*, java.util.*;" %><%
  ProjectObject po = (ProjectObject)session.getAttribute("currentProject");
  if (po != null) {
     JobObject jo = (JobObject)po.getCurrentJob();
     if (jo != null) {
        Hashtable jobSpecs = (Hashtable)jo.getJobSpecs(); %>
<table width="100%">
  <tr> 
    <td colspan="3"> 
      <hr size="1">
    </td>
  </tr>
  <tr> 
    <td class="catalogTITLE" width="27%" height="22"> 
      <div align="right">Specifications Entered Thus Far:</div>
    </td>
    <td class="catalogTITLE" width="53%" height="22">&nbsp;</td>
    <td class="catalogTITLE" height="22" width="20%">&nbsp;</td>
  </tr>
  <%  
        
        Connection conn = DBConnect.getConnection();
        Statement st0 = conn.createStatement();
 //************************
                Enumeration eKeys = jobSpecs.keys();
                StringBuffer sbQuery = new StringBuffer();
                if(eKeys.hasMoreElements()){
                        sbQuery.append("SELECT id, value FROM lu_specs WHERE id = ");
                        sbQuery.append((String)eKeys.nextElement());
        
                        while(eKeys.hasMoreElements()){
                                sbQuery.append(" OR id = ");
                                sbQuery.append((String)eKeys.nextElement());
                        }
                        sbQuery.append(" ORDER BY sequence");

                        ResultSet rsJS = st0.executeQuery(sbQuery.toString());

                        while(rsJS.next()){
                                if(rsJS.getInt("id") != 99999 && rsJS.getInt("id") != 88888){
                                        JobSpecObject jso = (JobSpecObject)jobSpecs.get(rsJS.getString("id"));
        %>
  <tr> 
    <td class="catalogLABEL" align="right" width="27%"><%=rsJS.getString("value")%> 
    </td>
    <td class="catalogITEM" width="53%" bordercolor="#000000"><%=(String)jso.getValue()%></td>
    <td class="catalogITEM" width="20%" bordercolor="#000000">&nbsp;</td>
  </tr>
  <%
                                }
                        }
                }
%>
  <tr> 
    <td colspan="3"> 
      <hr size="1">
    </td>
  </tr>
</table>
<%
		st0.close();
		conn.close();
     }
  }
  
 
%>