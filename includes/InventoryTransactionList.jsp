<%@ page import="java.sql.*,java.text.*,com.marcomet.jdbc.*;"%><% 
Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
DecimalFormat nf = new DecimalFormat("#,###");
String root_inv_prod_id=((request.getParameter("rootInvProdId")==null || request.getParameter("rootInvProdId").equals(""))?"0":request.getParameter("rootInvProdId"));
	%><table border=0 cellpadding=3 cellspacing=0><tr><td class='minderHeader'>Rec ID</td><td class='minderHeader'>Product ID</td><td class='minderHeader'>Root Inv Prod ID</td><td class='minderHeader'>Adj Action</td><td class='minderHeader'>Adj Type</td><td class='minderHeader'>Amount</td><td class='minderHeader'>Adj Date</td><td class='minderHeader'>Post Date</td><td class='minderHeader'>Running Total</td><td class='minderHeader'>Shipment #</td><td class='minderHeader'>Job #</td><td class='minderHeader'>Adj Notes</td></tr><%
	int runTotal=0;
	String query = "select inv_rec_id, inv_prod_id,inv_root_inv_prod_id,if(adjustment_action=1,'Initialized','Updated') adjustmentAction,if(adjustment_type_id=1,'Shipped',if(adjustment_type_id=2,'Increased','Decreased')) adjustmentType,format(amount,0) quantity,amount,DATE_FORMAT(adjustment_date,'%c/%e/%Y') adjDate,DATE_FORMAT(inv_post_date,'%c/%e/%Y') postDate,ship_id,job_id,adjustment_notes from v_inventory_w_postdates where inv_root_inv_prod_id="+root_inv_prod_id+" order by adjustment_date ";
	ResultSet rsInv = st.executeQuery(query);
	while (rsInv.next()) {
		%><tr><td class='lineitemsright'><%=rsInv.getString("inv_rec_id")%></td><td class='lineitemsright'><%=rsInv.getString("inv_prod_id")%></td><td class='lineitemsright'><%=rsInv.getString("inv_root_inv_prod_id")%></td><td class='lineitemsright'><%=rsInv.getString("adjustmentAction")%></td><td class='lineitemsright'><%=rsInv.getString("adjustmentType")%></td><td class='lineitemsright'><%=rsInv.getString("quantity")%></td><td class='lineitemsright'><%=rsInv.getString("adjDate")%></td><td class='lineitemsright'><%=rsInv.getString("postDate")%></td><td class='lineitemsright'><%=nf.format(runTotal+rsInv.getInt("amount"))%><%runTotal=runTotal+rsInv.getInt("amount");%></td> <td class='lineitemsright'><%=rsInv.getString("ship_id")%></td><td class='lineitemsright'><%=rsInv.getString("job_id")%></td><td class='lineitemsright'><%=rsInv.getString("adjustment_notes")%></td></tr><%
	}
	%></table><%
st.close();
conn.close();
%>
