<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,java.util.*,com.marcomet.users.security.*, com.marcomet.jdbc.*, com.marcomet.environment.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<jsp:useBean id="cjc" class="com.marcomet.workflow.actions.InventoryUpdater" scope="session" />
<html><head><title>Remove Duplicate products</title>
<link rel="stylesheet" href="/htdocs/commerce/styles/marcomet.css" type="text/css"></head><body><p class='Title'>Remove Duplicate Products</p><%
int x=0;
int y=0;
String productId=((request.getParameter("productId")==null || request.getParameter("productId").equals(""))?"0":request.getParameter("productId"));

String prodIdStr=((productId.equals("0"))?"":" AND id= "+productId);

String query="Select * from products where id>4000 "+prodIdStr;

Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
Statement st2 = conn.createStatement();
ResultSet rs = st.executeQuery(query);

while (rs.next()) {
	//If there is aduplicate record, delete it. 
	query = "delete from products where prod_code='"+rs.getString("prod_code")+"' and prod_name='"+rs.getString("prod_name")+"' and prod_line_id='"+rs.getString("prod_line_id")+"' and id <>"+rs.getString("id");
	st2.executeQuery(query);
	y++;
}	

try { st.close(); } catch (Exception e) {}
try { st2.close(); } catch (Exception e) {}
try { conn.close(); } catch (Exception e) {}

%><hr><%=y%> Dupe products removed.</body></html>