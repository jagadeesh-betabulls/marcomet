//Use with the AdPricing.jsp popup form to populate an html tinymce edit box with an ad price table

chosen = 0;
var gt = 0;
var ti = 0;
var ticd = 0;
var ticdt = 0;
var rushamt = 0;
var cd = 0.0;

function count(f,n,u)
{
  f.line_sum[n].value = f.line[n].value * u;
  f.line_sum[n].value = Math.ceil(f.line_sum[n].value * 1000) /1000;
  f.line_sum[n].value = Math.floor(f.line_sum[n].value * 1000) /1000;
  f.line_sum[n].value = Math.round(f.line_sum[n].value * 100)/100;
  if(f.line_sum[n].value == "NaN")
  {
    alert("Error:\nYou may only enter numbers...\nPlease retry");
    f.line[n].value = f.line[n].value.substring(0, f.line[n].value.length-1);
    f.line_sum[n].value = f.line[n].value * u;
    if(f.line_sum[n].value == "0") f.line_sum[n].value = "";
  }
  else 
  {
	gt = 0;
    for(i=0; i < f.line_sum.length; i++)
    {
      gt += Math.ceil(f.line_sum[i].value * 1000) /1000;
    }
    gt = Math.round(gt * 1000)/1000;
    f.grand_total.value = "$ " + gt;
	rushamt = gt * chosen;
	ti = rushamt + gt;
	ticd = ti * (document.forms[0].coop_discount.value * .01);
	ticdt = ti - ticd;
	f.total_invoice.value = "$ " + ti;
	f.total_invoice_discount.value = ticdt;
    decimal(f);
   }
}

function get_data(f)
{
  var order_data = "This Order is ...\n";
  var sum_data = "The sums are... \n";
  for(i=0; i < f.line.length; i++)
  {
    if(f.line[i].value == "") f.line[i].value = "0";
    order_data += "Line " +i+ " = "+f.line[i].value +" Qty\n";
  }
  for(i=0; i < f.line_sum.length; i++)
  {
    if(f.line_sum[i].value == "") f.line_sum[i].value = "0";
    sum_data += "Sum of Line " +i+ " = "+f.line_sum[i].value +" Total\n";
  }
  if(f.grand_total.value == "") f.grand_total.value = "Nil";
  order_data += "Rush Percentage = " + chosen * 100 + "%" + "\n";
  order_data += "Work Total = " + f.grand_total.value + "\n";
  order_data += "Total Invoice = " + f.total_invoice.value + "\n";
  if(f.total_invoice.value != f.total_invoice_discount.value){
	order_data += "Coop Discount = " + document.forms[0].coop_discount.value + "\n";
  	order_data += "Total Invoice After Coop Discount = $" + f.total_invoice_discount.value;
  }
  decodeString();
}
function decodeString() {
valNum = new Array();
valData = new Array();
var string, length, dataCount, orderData, grandTotal;
orderData = "";
dataCount = 1;

orderData = "<table border=0 width=400>";
orderData += "<tr><td>Qty</td><td>Description</td><TD>Unit</TD><td>Price</td><td>Total</td></tr>";
grandTotal = 0;
  for(i=0; i<f.line_sum.length; i++)
{
/*
orderData += "<tr>";
orderData += "<input type=hidden name=item" + (i+1) + "num value='" + f.line[i].value + "'>";
orderData += "<input type=hidden name=item" + (i+1) + "dsc value='" + f.description[i].value + "'>";
orderData += "<input type=hidden name=item" + (i+1) + "cst value='$" + f.unit[i].value + "'>";
orderData += "<input type=hidden name=item" + (i+1) + "cst value='$" + f.price[i].value + "'>";
orderData += "<input type=hidden name=item" + (i+1) + "cst value='$" + f.line_sum[i].value + "'>";
*/
if (f.line_sum[i].value != '0'){
	orderData += "<tr>";
	orderData += "<td style='text-align:right'>" + f.line[i].value + "</td>";
	orderData += "<td>" + f.description[i].value + "</td>";
	orderData += "<td>" + f.unit[i].value + "</td>";
	orderData += "<td style='text-align:right'>" + "$ " + f.price[i].value + "</td>";
	orderData += "<td style='text-align:right'>" + "$ " + f.line_sum[i].value + "</td>";
	orderData += "</tr>";
	grandTotal += ticdt;
}
}
orderData += "<tr>";
orderData += "<td colspan=4>Rush Percentage</td><td style='text-align:right'>&nbsp;&nbsp;&nbsp;" + + chosen * 100 + "%" + "</td>";
orderData += "</tr>";
orderData += "<tr>";
orderData += "<td colspan=4>Work total</td><td style='text-align:right'>" + f.grand_total.value + "</td>";
orderData += "</tr>";
orderData += "<tr>";
orderData += "<td colspan=4>Total Invoice</td><td style='text-align:right'>" + f.total_invoice.value + "</td>";
orderData += "</tr>";
  if(document.forms[0].coop_discount.value != '0'){
  	orderData += "<tr>";
	orderData += "<td colspan=4>Coop Discount</td><td style='text-align:right'>&nbsp;&nbsp;&nbsp;" + document.forms[0].coop_discount.value + "%</td>";
	orderData += "</tr>";
  	orderData += "<tr>";
	orderData += "<td colspan=4>Total Invoice After Coop Discount</td><td style='text-align:right'>$ " + f.total_invoice_discount.value + "</td>";
	orderData += "</tr>";
  }
/*
orderData += "<tr>";
orderData += "<input type=hidden name=grandtotal value='$" + ticdt + "'>";
orderData += "</tr>";
*/
orderData += "</table>";
opener.orderData_Generate=orderData;
//opener.document.forms[0].proposedChangeReason.value = orderData;
tinyMCE.execCommand('mceSetContent', true, orderData);
opener.table_generate();
opener.document.forms[0].cost.value = f.total_invoice_discount.value;
opener.updatePrices(0, 1, 0, 0);
window.close();
}


function decimal(f)
{
  for(i=0; i<f.line_sum.length; i++)
  {
    var d = f.line_sum[i].value.indexOf(".");
    if(d == -1 && f.line[i].value != 0) f.line_sum[i].value += ".00";
    if(d == (f.line_sum[i].value.length-2)) f.line_sum[i].value += "0";
    if(f.line_sum[i].value == "00") f.line_sum[i].value="";
  }
  d = f.grand_total.value.indexOf(".");
  if(d == -1) f.grand_total.value += ".00";
  if(d == (f.grand_total.value.length-2)) f.grand_total.value += "0";
  d2 = f.total_invoice.value.indexOf(".");
  if(d2 == -1) f.total_invoice.value += ".00";
  if(d2 == (f.total_invoice.value.length-2)) f.total_invoice.value += "0";
  d3 = f.total_invoice_discount.value.indexOf(".");
  if(d3 == -1) f.total_invoice_discount.value += ".00";
  if(d3 == (f.total_invoice_discount.value.length-2)) f.total_invoice_discount.value += "0";
}

function init()
{
  document.f.reset();
  document.f.line[0].select();
  document.f.line[0].focus();
}

window.onload=init;

function numbersonly(myfield, e, dec) {
  var key;
  var keychar;

  if (window.event)
    key = window.event.keyCode;
  else if (e)
    key = e.which;
  else
    return true;
  keychar = String.fromCharCode(key);

  // control keys
  if ((key==null) || (key==0) || (key==8) || (key==9) || (key==13) || (key==27) )
    return true;

  // numbers
  else if ((("0123456789.").indexOf(keychar) > -1))
    return true;

  // decimal point jump
  else if (dec && (keychar == ".")) {
    myfield.form.elements[dec].focus();
    return false;
  } else
    return false;
}

function GetSelectedItem() {

chosen = ""
len = document.f.r1.length

for (i = 0; i <len; i++) {
if (document.f.r1[i].checked) {
chosen = document.f.r1[i].value;
gt = Math.round(gt * 1000)/1000;
f.grand_total.value = "$ " + gt;
rushamt = gt * chosen;
ti = rushamt + gt;
ticd = ti * cd;
ticdt = ti - ticd;
f.total_invoice.value = "$ " + ti;
f.total_invoice_discount.value = ticdt;
decimal(f);

}
}
}
