<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.text.*,java.sql.*,java.util.*,com.marcomet.environment.*,com.marcomet.jdbc.*,com.marcomet.tools.*" %>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%
Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
String prodPriceCode=((request.getParameter("prodPriceCode")==null)?"":request.getParameter("prodPriceCode"));
String SQLPrices ="Select ppc.description as 'Title',pp.notes as 'description', format(pp.price,2) as 'pricePer',pp.qty_type as 'Units' from product_price_codes ppc left join product_prices pp on pp.prod_price_code=ppc.prod_price_code where pp.prod_price_code='"+prodPriceCode+"'";
String SQLRush ="Select notes as 'description', concat(format(price*100,0),'%') as 'PercentText',pp.qty_type as 'Units',price as 'percentage' from product_prices pp where prod_price_code='"+prodPriceCode+"-RUSH'";
String SQLDiscount ="Select notes as 'description', concat(format(price*100,0),'%') as 'PercentText',pp.qty_type as 'Units',price as 'percentage' from product_prices pp where prod_price_code='"+prodPriceCode+"-DISCOUNT'";
StringTool str=new StringTool();
DecimalFormat nf = new DecimalFormat("#,###.00");
%><!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">
<HTML lang="en">
<HEAD>
	<script language="javascript" type="text/javascript" src="/javascripts/tiny_mce/tiny_mce_popup.js"></script>
	<script language="javascript" type="text/javascript" src="/javascripts/tiny_mce/utils/mctabs.js"></script>
	<script language="javascript" type="text/javascript" src="/javascripts/tiny_mce/utils/form_utils.js"></script>
	<script language="javascript" type="text/javascript" src="/javascripts/AdPricePopup.js"></script>
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css"><%
  %></HEAD>
<BODY>
	<p ALIGN="RIGHT" style="padding: 0px; margin: 0px;"><a href="javascript:if (newwindow) newwindow.close()">Close</a></p>
	<FORM NAME="f" ENCTYPE="text/plain"><div class='subtitle'>Price Calculator</div>
	<TABLE BORDER="0" WIDTH="320" CELLPADDING="5" CELLSPACING="0" SUMMARY=""><TBODY>
		<TR ><TD><U>Qty</U></TD><TD><U>Description</U></TD><TD><U>Unit</U></TD><TD><U>Price</U></TD><TD ALIGN="right"><U>Total</U></TD></TR><%
		
	ResultSet rs = st.executeQuery(SQLPrices);
	int x=0;
	while(rs.next()){
	
		%><TR><TD><INPUT NAME="line" TYPE="text" SIZE="5" VALUE="" onkeypress="return numbersonly(this, event)" ONKEYUP="count(this.form,<%=x++%>,<%=rs.getString("pricePer")%>)"></TD><TD> <%=rs.getString("description")%> <input type="hidden" name="description" value="<%=rs.getString("description")%>"></TD>
		<TD><%=rs.getString("Units")%><input type="hidden" name="unit" value="<%=rs.getString("Units")%>"></TD><TD>$<%=rs.getString("pricePer")%><input type="hidden" name="price" value="<%=rs.getString("pricePer")%>"></TD>
		<TD ALIGN="right"><INPUT NAME="line_sum" TYPE="text" SIZE="10" READONLY class='lineitemsright'></TD>
		</TR><%
	}
	%>
	<TR><TD><INPUT TYPE="button" VALUE="Reset" ONCLICK="init()"></TD>
	<TD COLSPAN="3" ALIGN="right"><B>Work Total :</B></TD>
	<TD ALIGN="right"><INPUT NAME="grand_total" TYPE="text" SIZE="10" READONLY  class='lineitemsright'></TD></TR><%
	
	rs = st.executeQuery(SQLRush);
	while(rs.next()){
		%><TR ><TD COLSPAN="4"><INPUT NAME="r1" TYPE="radio" SIZE="5" VALUE="<%=rs.getString("percentage")%>" onClick=GetSelectedItem()><%=rs.getString("description")%></TD><TD ALIGN="right"><%=rs.getString("PercentText")%></TD></TR><%
	}
	%><TR >
	<TD COLSPAN="4" ALIGN="right"><B>Total Invoice :</B></TD>
	<TD ALIGN="right"><INPUT NAME="total_invoice" TYPE="text" SIZE="10" READONLY class='lineitemsright'></TD></TR><%
	
	rs = st.executeQuery(SQLDiscount);
	int idCount=0;
	while(rs.next()){
		idCount++;
		%><TR><TD COLSPAN="4" ALIGN="right"><B><%=rs.getString("description")%> % :</B></TD>
	<TD ALIGN="right"><INPUT NAME="<%=rs.getString("Units")%>" TYPE="text" SIZE="4" class='lineitemsright' value='0' onkeypress="return numbersonly(this, event)"  ONKEYUP="count(this.form,<%=x-1%>,this.value)" >%</TD></TR>
	<TR><%
	}%>
	<TD COLSPAN="4" ALIGN="right"><B>Total Invoice After Coop Discount :</B></TD>
	<TD ALIGN="right"><INPUT NAME="total_invoice_discount" TYPE="text" SIZE="10" READONLY class='lineitemsright'></TD></TR>
	<TR ><TD COLSPAN="5" ALIGN="center"><INPUT TYPE="button" VALUE="PRICE AD" ONCLICK="get_data(this.form)"></TD></TR></TBODY></TABLE></FORM>
</BODY>
</HTML>