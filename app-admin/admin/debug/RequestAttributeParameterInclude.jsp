<%@ page import="java.util.*" %>
<table>
<tr><td colspan="2">Attributes</td></tr>
<% 
	Enumeration varNames = request.getAttributeNames();
	String varValue = "";
	String varName = "";
	if(varNames.hasMoreElements()){
		do{
			varName = (String)varNames.nextElement();
			try{
				if(request.getAttribute(varName) == null){
					varValue="HAS NO VALUE";		
				}else{
					//varValue = (String)session.getAttribute(varName);
					varValue = request.getAttribute(varName).toString();
				}	
			}catch(Exception e){
				varValue="IS AN OBJECT" + ": " + e.getMessage();	
			}
%>
<tr><td><%= varName%></td><td><%= varValue %></td></tr>
<%
		}while(varNames.hasMoreElements());
	}else{
%>
<tr><td colspan="2">No request attributes</td></tr>
<%	
	}
%>
<tr><td colspan="2">Parameters</td></tr>
<% 
	varNames = request.getParameterNames();
	varValue = "";
	varName = "";
	if(varNames.hasMoreElements()){
		do{
			varName = (String)varNames.nextElement();
			try{
				if(request.getParameter(varName) == null){
					varValue="HAS NO VALUE";		
				}else{
					//varValue = (String)session.getAttribute(varName);
					varValue = request.getParameter(varName).toString();
				}	
			}catch(Exception e){
				varValue="IS AN OBJECT" + ": " + e.getMessage();	
			}
%>
<tr><td><%= varName%></td><td><%= varValue %></td></tr>
<%
		}while(varNames.hasMoreElements());
	}else{
%>
<tr><td colspan="2">No request parameters</td></tr>
<%	
	}
%>

</table>
