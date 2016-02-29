<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">
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
	<FORM NAME="f" ENCTYPE="text/plain"><div class='subtitle'>Ad Price Calculator</div>
	<TABLE BORDER="0" WIDTH="320" CELLPADDING="5" CELLSPACING="0" SUMMARY=""><TBODY>
		<TR ><TD><U>Qty</U></TD><TD><U>Description</U></TD><TD><U>Unit</U></TD><TD><U>Price</U></TD><TD ALIGN="right"><U>Total</U></TD></TR>
	<TR><TD><INPUT NAME="line" TYPE="text" SIZE="5" VALUE="" onkeypress="return numbersonly(this, event)" ONKEYUP="count(this.form,0,40.00)"></TD><TD>Base Ad<input type="hidden" name="description" value="Base Ad"></TD>
	<TD>Each<input type="hidden" name="unit" value="Each"></TD><TD>$40.00<input type="hidden" name="price" value="40.00"></TD><TD ALIGN="right"><INPUT NAME="line_sum" TYPE="text" SIZE="10" READONLY></TD></TR>
	<TR >
	<TD><INPUT NAME="line" TYPE="text" SIZE="5" VALUE="" onkeypress="return numbersonly(this, event)" onkeypress="return numbersonly(this, event)"  ONKEYUP="count(this.form,1,125.00)">
	<TD>Resize/extra layout chgs<input type="hidden" name="description" value="Resize/extra layout chgs"></TD>
	</TD>
	<TD>Hour<input type="hidden" name="unit" value="Hour"></TD><TD>$125.00<input type="hidden" name="price" value="125.00"></TD>
	<TD ALIGN="right"><INPUT NAME="line_sum" TYPE="text" SIZE="10" READONLY></TD></TR>
	<TR><TD><INPUT NAME="line" TYPE="text" SIZE="5" VALUE="" onkeypress="return numbersonly(this, event)"  ONKEYUP="count(this.form,2,20.00)">
	</TD><TD>Convert to B/W<input type="hidden" name="description" value="Convert to B/W"></TD><TD>Each<input type="hidden" name="unit" value="Each"></TD><TD>$20.00<input type="hidden" name="price" value="20.00"></TD><TD ALIGN="right"><INPUT NAME="line_sum" TYPE="text" SIZE="10" READONLY></TD></TR>
	<TR ><TD><INPUT NAME="line" TYPE="text" SIZE="5" VALUE="" onkeypress="return numbersonly(this, event)"  ONKEYUP="count(this.form,3,125.00)">
	</TD><TD>Convert to Color<input type="hidden" name="description" value="Convert to Color"></TD><TD>Hour<input type="hidden" name="unit" value="Hour"></TD><TD>$125.00<input type="hidden" name="price" value="125.00"></TD><TD ALIGN="right"><INPUT NAME="line_sum" TYPE="text" SIZE="10" READONLY></TD></TR>
	<TR><TD><INPUT NAME="line" TYPE="text" SIZE="5" VALUE="" onkeypress="return numbersonly(this, event)"  ONKEYUP="count(this.form,4,125.00)">
	</TD><TD>New Creative<input type="hidden" name="description" value="New Creative"></TD><TD>Hour<input type="hidden" name="unit" value="Hour"></TD><TD>$125.00<input type="hidden" name="price" value="125.00"></TD><TD ALIGN="right"><INPUT NAME="line_sum" TYPE="text" SIZE="10" READONLY></TD></TR>
	<TR ><TD><INPUT NAME="line" TYPE="text" SIZE="5" VALUE="" onkeypress="return numbersonly(this, event)"  ONKEYUP="count(this.form,5,125.00)">
	</TD><TD>Alterations (AA)<input type="hidden" name="description" value="Alterations (AA)"></TD><TD>Hour<input type="hidden" name="unit" value="Hour"></TD><TD>$125.00<input type="hidden" name="price" value="125.00"></TD><TD ALIGN="right"><INPUT NAME="line_sum" TYPE="text" SIZE="10" READONLY></TD></TR>
	<TR><TD><INPUT NAME="line" TYPE="text" SIZE="5" VALUE="" onkeypress="return numbersonly(this, event)"  ONKEYUP="count(this.form,6,5.00)">
	</TD><TD>PDF proofs<input type="hidden" name="description" value="PDF proofs"></TD><TD>Each<input type="hidden" name="unit" value="Each"></TD><TD>$5.00<input type="hidden" name="price" value="5.00"></TD><TD ALIGN="right"><INPUT NAME="line_sum" TYPE="text" SIZE="10" READONLY></TD></TR>
	<TR ><TD><INPUT NAME="line" TYPE="text" SIZE="5" VALUE="" onkeypress="return numbersonly(this, event)"  ONKEYUP="count(this.form,7,10.00)">
	</TD><TD>Upload files to FTP<input type="hidden" name="description" value="Upload files to FTP"></TD><TD>Each<input type="hidden" name="unit" value="Each"></TD><TD>$10.00<input type="hidden" name="price" value="10.00"></TD><TD ALIGN="right"><INPUT NAME="line_sum" TYPE="text" SIZE="10" READONLY></TD></TR>
	<TR><TD><INPUT NAME="line" TYPE="text" SIZE="5" VALUE="" onkeypress="return numbersonly(this, event)"  ONKEYUP="count(this.form,8,40.00)">
	</TD><TD>Color Proof<input type="hidden" name="description" value="Color Proof"></TD><TD>Each<input type="hidden" name="unit" value="Each"></TD><TD>$40.00<input type="hidden" name="price" value="40.00"></TD><TD ALIGN="right"><INPUT NAME="line_sum" TYPE="text" SIZE="10" READONLY></TD></TR>
	<TR ><TD><INPUT NAME="line" TYPE="text" SIZE="5" VALUE="" onkeypress="return numbersonly(this, event)"  ONKEYUP="count(this.form,9,5.00)">
	</TD><TD>Disk<input type="hidden" name="description" value="Disk"></TD><TD>Each<input type="hidden" name="unit" value="Each"></TD><TD>$5.00<input type="hidden" name="price" value="5.00"></TD><TD ALIGN="right"><INPUT NAME="line_sum" TYPE="text" SIZE="10" READONLY></TD></TR>
	<TR><TD><INPUT NAME="line" TYPE="text" SIZE="5" VALUE="" onkeypress="return numbersonly(this, event)"  ONKEYUP="count(this.form,10,10.00)">
	</TD><TD>Shipping (FedEx)<input type="hidden" name="description" value="Shipping (FedEx)"></TD><TD>&nbsp;<input type="hidden" name="unit" value="N/A"></TD></TD><TD>$10.00<input type="hidden" name="price" value="10.00"></TD><TD ALIGN="right"><INPUT NAME="line_sum" TYPE="text" SIZE="10" READONLY></TD></TR>
	<TR ><TD><INPUT NAME="line" TYPE="text" SIZE="5" VALUE="" onkeypress="return numbersonly(this, event)"  ONKEYUP="count(this.form,11,10.00)">
	</TD><TD>Pickup Ads<input type="hidden" name="description" value="Pickup Ads"></TD><TD>Each<input type="hidden" name="unit" value="Each"></TD><TD>$10.00<input type="hidden" name="price" value="10.00"></TD><TD ALIGN="right"><INPUT NAME="line_sum" TYPE="text" SIZE="10" READONLY></TD></TR>
	<TR><TD><INPUT TYPE="button" VALUE="Reset" ONCLICK="init()"></TD>
	<TD COLSPAN="3" ALIGN="right"><B>Work Total :</B></TD>
	<TD ALIGN="right"><INPUT NAME="grand_total" TYPE="text" SIZE="10" READONLY></TD></TR>
	<TR ><TD COLSPAN="4"><INPUT NAME="r1" TYPE="radio" SIZE="5" VALUE="0.00" onClick=GetSelectedItem()>No Rush</TD><TD ALIGN="right">0%</TD></TR>
	<TR><TD COLSPAN="4"><INPUT NAME="r1" TYPE="radio" SIZE="5" VALUE="1.00" onClick=GetSelectedItem()>3-5 Day Rush</TD><TD ALIGN="right">100%</TD></TR>
	<TR ><TD COLSPAN="4"><INPUT NAME="r1" TYPE="radio" SIZE="5" VALUE="1.50" onClick=GetSelectedItem()>48 Hour Rush</TD><TD ALIGN="right">150%</TD></TR>
	<TR><TD COLSPAN="4"><INPUT NAME="r1" TYPE="radio" SIZE="5" VALUE="2.00" onClick=GetSelectedItem()>24 Hour Rush</TD><TD ALIGN="right">200%</TD></TR>
	<TR >
	<TD COLSPAN="4" ALIGN="right"><B>Total Invoice :</B></TD>
	<TD ALIGN="right"><INPUT NAME="total_invoice" TYPE="text" SIZE="10" ONKEYUP="counttotal(this.form,0,40.00)" READONLY class='lineitemsright'></TD></TR>
	<TR>
	<TD COLSPAN="4" ALIGN="right"><B>Coop Discount % :</B></TD>
	<TD ALIGN="right"><INPUT NAME="coop_discount" TYPE="text" SIZE="4" class='lineitemsright' value='0' onkeypress="return numbersonly(this, event)"  ONKEYUP="count(this.form,10,10.00)"	>%</TD></TR>
	<TR>
	<TD COLSPAN="4" ALIGN="right"><B>Total Invoice After Coop Discount :</B></TD>
	<TD ALIGN="right"><INPUT NAME="total_invoice_discount" TYPE="text" SIZE="10" READONLY class='lineitemsright'></TD></TR>
	<TR ><TD COLSPAN="5" ALIGN="center"><INPUT TYPE="button" VALUE="PRICE AD" ONCLICK="get_data(this.form)"></TD></TR></TBODY></TABLE></FORM>
</BODY>
</HTML>