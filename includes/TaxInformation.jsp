<%@ page import="com.marcomet.users.security.*" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<hr size="1">
<table width=100% class="body">
  <tr> 
    <td class="subtitle1" width="17%">Sales Tax:</td>
<%	if(((RoleResolver)session.getAttribute("roles")).isVendor()){%>
    <td width="83%" class="bodyBlack"><a href="javascript:popw('/popups/SalesTaxInformationForm.jsp?jobId=<%= request.getParameter("jobId")%>', 500, 200)" class="minderACTION">Edit</a></td>
<%	}	%>
    </tr>
</table>
<taglib:JobTaxInformationTag tableWidth="60%" jobId="<%= request.getParameter(\"jobId\")%>"/>