package com.marcomet.taglibs;
import java.io.IOException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Hashtable;
import java.util.Vector;
import java.text.*;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.TagSupport;

import com.marcomet.catalog.CatalogCalculator;
import com.marcomet.catalog.JobSpecObject;
import com.marcomet.catalog.ProjectObject;
import com.marcomet.jdbc.DBConnect;
import com.marcomet.tools.FormaterTool;


public class PricingGridTag extends TagSupport {
	
	private PricingObject po = null;
	private YaxisContainer yac = null;
	private XaxisContainer xac = null;
	private String catJobId = null;
	private String vendorId = null;
	private String contactId = null;
	private String siteHostId = null;
	private String tierId = null;
	private String catalogPage = null;
	private String productCode = null;
	private boolean proxyEnabled = false;
	private boolean productPricingTable = (productCode!=null && !(productCode.equals("") && !(productCode.equals("null") )));
	
	private class PricingObject {
		private StringBuffer NARow = null;
		private Vector pricingRows = null;
		PricingObject(Vector pricingRows, StringBuffer NARow) {
			this.pricingRows = pricingRows;
			this.NARow = NARow;
		}
		public final  Vector getPricingRows() {
			return pricingRows;
		}
		public final  StringBuffer getNARow() {
			return NARow;
		}
	}
	
	private class HighlightingObject {
		private int highlight = 0;
		private int highlightedColumn = 0;
		private int startHighlightRow = 0;
		private int endHighlightRow = 0;
		private ArrayList highlightedRows = null;
		public boolean xHighlight = false;
		public boolean yHighlight = false;
		public HighlightingObject(ProjectObject po, FilteringObject fo) {
			this.determineHighlightCriterion(po, fo);
		}
		public final  void setHighlight(int highlight) {
			this.highlight = highlight;
		}
		public final  int getHighlight() {
			return highlight;
		}
		public final  int getStartHighlightRow() {
			return startHighlightRow;
		}
		public final  void setStartHighlightRow(int startHighlightRow) {
			this.startHighlightRow = startHighlightRow;
		}
		public final  int getEndHighlightRow() {
			return endHighlightRow;
		}
		public final  void setEndHighlightRow(int endHighlightRow) {
			this.endHighlightRow = endHighlightRow;
		}
		public final  int getColumnToHighlight() {
			return highlightedColumn;
		}
		
		public final  ArrayList getRowsToHighlight() {
			return highlightedRows;
		}
		public final  void determineHighlightCriterion(ProjectObject po, FilteringObject fo) {
			Vector jobs = po.getJobs();
			Hashtable jobSpecs = po.getJobSpecs();
			// highlight for x axis
			int xRowCount = xac.getSequenceCount();
			int xColumnCount = xac.getTableSize();
			Hashtable xRowComponents = xac.getComponentsBySequence();
			Vector xColumnComponents = (Vector)xRowComponents.get("axis0");
			int xColumnCounter = 0;
			for (int i=0; i<xColumnComponents.size(); i++) {
				GridComponent gc = (GridComponent)xColumnComponents.elementAt(xColumnCounter);
				Object o = jobSpecs.get( new Integer(gc.getSpecId()).toString() );
				if (o != null) {
					JobSpecObject jso = (JobSpecObject)o;
					if (jso.getValue().equals(gc.getName())) {
						xHighlight = true;
						highlightedColumn = xColumnCounter;
					}
				}
				xColumnCounter++;
			}
			// highlight for y axis
			int startRow = 0;
			int endRow = yac.getTableSize();
			int yColumnCount = yac.getSequenceCount();
			int yRowCount = yac.getTableSize();
			Hashtable yColumnComponents = yac.getComponentsBySequence();
			highlightedRows = new ArrayList();
			int yFilterBlockSize = 0;
			for (int i=0; i<yColumnComponents.size(); i++) {
				Vector yRowComponents = (Vector)yColumnComponents.get("axis" + i);
				int yRowCounter = 0;
				int spanCounter = 0;
				for (int j=0; j<yRowComponents.size(); j++) {
					GridComponent gc = (GridComponent)yRowComponents.elementAt(yRowCounter);
					Object o = jobSpecs.get( new Integer(gc.getSpecId()).toString() );
					int span = gc.getSpan();
					if (span > yFilterBlockSize)
						yFilterBlockSize = span;
					if (o != null) {
						JobSpecObject jso = (JobSpecObject)o;
						//System.err.println(jso.getValue() +"--"+ gc.getName() +"--"+ yRowCounter +"--"+ span +"--"+ spanCounter +"--"+ startRow +"--"+ endRow +"--"+ jso.getValue().equals(gc.getName()));
						if (jso.getValue().equals(gc.getName())) {
							yHighlight = true;
							if ( (startRow == endRow && endRow == 0 && highlightedRows.size() == 0) || (spanCounter >= startRow && (spanCounter - 1) <= endRow) ) {
								startRow = spanCounter;
								if (span == 1) {
									if (endRow == 0) {
										endRow = spanCounter;
									} else {
										endRow = startRow;
									}
								} else {
									if (endRow == 0) {
										endRow = spanCounter + span;
									} else {
										endRow = spanCounter + span;
										if (startRow != endRow)
											endRow = endRow - 1;
									}
								}
								highlightedRows.clear();
								highlightedRows.add(new Integer(yRowCounter));
								this.setStartHighlightRow(startRow);
								this.setEndHighlightRow(endRow);
								fo.calculateFilter(yFilterBlockSize - 1, j, startRow, endRow);
							}
						}
						spanCounter = spanCounter + span;
						if (spanCounter > yac.getTableSize()) {
							spanCounter = 0;
						}
					}
					yRowCounter++;
				}
			}
		}
	}
	
	private class FilteringObject {
		private int startFilterRow = 0;
		private int endFilterRow = 0;
		private int filter = 0;		
		public final  void setFilter(int filter) {
			this.filter = filter;
		}
		public final  int getFilter() {
			return filter;
		}
		public final  void calculateFilter(int yFilterBlockSize, int currentRow, int startHighlightRow, int endHighlightRow) {
			int startRow = 0;
			int endRow = yFilterBlockSize;
			while (currentRow > endRow) {
				startRow = startRow + yFilterBlockSize + 1;
				endRow = endRow + yFilterBlockSize + 1;
			}
			if (startHighlightRow > startRow && endHighlightRow > endRow) {
				startRow = startHighlightRow;
				endRow = endHighlightRow;
			}
			startFilterRow = startRow;
			endFilterRow = endRow;
		}
		public final  int getStartFilterRow() {
			return startFilterRow;
		}
		public final  int getEndFilterRow() {
			return endFilterRow;
		}
	}
	
	private class XaxisContainer {
		private int sequenceCount = 0;
		private int tableSize = 0;
		private Hashtable componentsBySequence = null;
		private Vector specTypesVector = null;
		private Vector gridImagesVector = null;
		public final  int getSequenceCount() {
			return sequenceCount;
		}
		public final  void setSequenceCount(int sequenceCount) {
			this.sequenceCount = sequenceCount;
		}
		
		public final  int getTableSize() {
			return tableSize;
		}
		public final  void setTableSize(int tableSize) {
			this.tableSize = tableSize;
		}
		public final  Hashtable getComponentsBySequence() {
			return componentsBySequence;
		}
		public final  void setComponentsBySequence(Hashtable componentsBySequence) {
			this.componentsBySequence = componentsBySequence;
		}
		public final  Vector getSpecTypesVector() {
			return specTypesVector;
		}
		public final  void setSpecTypesVector(Vector specTypesVector) {
			this.specTypesVector = specTypesVector;
		}
		public final  Vector getGridImagesVector() {
			return gridImagesVector;
		}
		public final  void setGridImagesVector(Vector gridImagesVector) {
			this.gridImagesVector = gridImagesVector;
		}
	}
	
	private class YaxisContainer {
		private int sequenceCount = 0;
		private int tableSize = 0;
		private Hashtable componentsBySequence = null;
		private Vector specTypesVector = null;
		public final  int getSequenceCount() {
			return sequenceCount;
		}
		public final  void setSequenceCount(int sequenceCount) {
			this.sequenceCount = sequenceCount;
		}
		
		public final  int getTableSize() {
			return tableSize;
		}
		public final  void setTableSize(int tableSize) {
			this.tableSize = tableSize;
		}
		public final  Hashtable getComponentsBySequence() {
			return componentsBySequence;
		}
		public final  void setComponentsBySequence(Hashtable componentsBySequence) {
			this.componentsBySequence = componentsBySequence;
		}
		public final  Vector getSpecTypesVector() {
			return specTypesVector;
		}
		public final  void setSpecTypesVector(Vector specTypesVector) {
			this.specTypesVector = specTypesVector;
		}
	}
	
	public class GridComponent {
		private String name, axis;
		private int specId, span, axisSequence, spanSequence;
		public GridComponent(String name, int specId, int span, String axis, int axisSequence, int spanSequence) {
			this.name = name;
			this.specId = specId;
			this.span = span;
			this.axis = axis;
			this.axisSequence = axisSequence;
			this.spanSequence = spanSequence;
		}
		public final  String getAxis() {
			return axis;
		}
		public final  void setAxis(String axis) {
			this.axis = axis;
		}
		public final  int getAxisSequence() {
			return axisSequence;
		}
		public final  void setAxisSequence(int axisSequence) {
			this.axisSequence = axisSequence;
		}
		public final  String getName() {
			return name;
		}
		public final  void setName(String name) {
			this.name = name;
		}
		public final  int getSpecId() {
			return specId;
		}
		public final  void setSpecId(int specId) {
			this.specId = specId;
		}
		public final  int getSpan() {
			return span;
		}
		public final  void setSpan(int span) {
			this.span = span;
		}
		public final  int getSpanSequence() {
			return spanSequence;
		}
		public final  void setSpanSequence(int sequence) {
			this.spanSequence = spanSequence;
		}
	}
	
	public final  StringBuffer buildGrid(ProjectObject po) throws JspException {
		try{
		FilteringObject fo = new FilteringObject();
		HighlightingObject ho = new HighlightingObject(po, fo);
		String tagline = this.getTagline(ho, fo);
		StringBuffer gridBody = this.buildGridBody(ho, fo);
		StringBuffer header = this.buildHeader();
		StringBuffer output = new StringBuffer();
		output.append("<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"98%\">\n");
		output.append("  <tr><td class=\"catalogLABEL\" colspan=\"").append(yac.getSequenceCount() + xac.getTableSize()).append("\">").append(tagline).append("</td></tr>\n");
		output.append(header);
		output.append(gridBody);
		output.append("</table>");
		return output;
		} catch (Exception ex) {
			throw new JspException("PricingGridTag.doEndTag Error: " + ex.getMessage());
		}
	}
	
	public final StringBuffer buildGridBody(HighlightingObject ho, FilteringObject fo) {
		
		int highlight = ho.getHighlight();
		
		StringBuffer gridBody = new StringBuffer();
		StringBuffer NARow = po.getNARow();
		Hashtable columnCounters = new Hashtable();
		Vector pricingVector = po.getPricingRows();
		Vector vec = null;
		int colNumToSkip = 0;
		int nextElementIndex = 0;
		int yTableSize = yac.getTableSize();
		int ySequenceCount = yac.getSequenceCount();
		int tempYaxisSequenceCount = ySequenceCount;
//		try {
//			com.marcomet.tools.MessageLogger.logMessage("filter " + fo.getFilter() + " StartRow " + fo.getStartFilterRow() + " EndRow " + fo.getEndFilterRow());
//			com.marcomet.tools.MessageLogger.logMessage("highlight " + ho.getHighlight() + " StartRow " + ho.getStartHighlightRow() + " EndRow " + ho.getEndHighlightRow() + " Column to highlight " + ho.getColumnToHighlight());
//			com.marcomet.tools.MessageLogger.logMessage("Table Size " + yTableSize);
//		} catch (Exception ex) {
//		}
		boolean needNewStartTr = false;
		boolean needNewEndTr = false;
		for (int i=0; i<yTableSize; i++) {
			if (needNewStartTr == true) {
				gridBody.append("  <tr>\n");
				needNewStartTr = false;
			}
			for (int j=0; j<ySequenceCount; j++) {
				vec = (Vector)columnCounters.get("" + j);
				if (vec == null) {
					vec = new Vector();
					nextElementIndex = 0;
					vec.insertElementAt(new Integer(nextElementIndex), 0);
					columnCounters.put("" + j, vec);
				} else {
					try {
						colNumToSkip = ((Integer)vec.remove(1)).intValue();
					} catch (Exception ex) {
						colNumToSkip = 0;
						vec.insertElementAt(new Integer(colNumToSkip), 1);
					}
					if (colNumToSkip != 0)
						vec.insertElementAt(new Integer(colNumToSkip - 1), 1);
				}
				Vector yComponentVector = null;
				GridComponent gc = null;
				if (j <= tempYaxisSequenceCount && colNumToSkip <= j) {
					if (i != 0) {
						nextElementIndex = ((Integer)vec.remove(0)).intValue();
						nextElementIndex++;
						vec.insertElementAt(new Integer(nextElementIndex), 0);
					}
					Hashtable yComponentsBySequence = yac.getComponentsBySequence();
					yComponentVector = (Vector)yComponentsBySequence.get("axis" + (j));
					gc = (GridComponent)yComponentVector.elementAt(nextElementIndex);
					if (fo.getFilter() == 0 || (fo.getStartFilterRow() <= i && i <= fo.getEndFilterRow())) {
						needNewStartTr = true;
						needNewEndTr = true;
//						gridBody.append("    <td rowspan=\"").append(gc.getSpan()).append("\" class=\"planheader2\" width=\"\">").append(((gc.getName().equals("0"))?"Custom":gc.getName())).append("</td>\n");
						if (j == tempYaxisSequenceCount || ( ((j+1) == tempYaxisSequenceCount)) && (ySequenceCount == tempYaxisSequenceCount) ) {
							Vector priceDisplays = (Vector)pricingVector.elementAt(i);
							if (i >= pricingVector.size()) {
								gridBody.append(NARow);
							} else {
								for (int k=0; k<priceDisplays.size(); k++) {
									Vector priceLinks = (Vector)priceDisplays.elementAt(k);
									String cellValue = (String)priceLinks.elementAt(1);
									String cellValueLink = (String)priceLinks.elementAt(0);
									if (highlight == 0) {
										gridBody.append("    <td class=\"lineitems\" align=\"center\" onMouseOver=this.className=\"lineitemsselected\" onMouseOut=this.className=\"lineitems\" >").append(cellValueLink).append("</td>\n");
									} else {
										ArrayList yHighlightRows = ho.getRowsToHighlight();
										if (ho.xHighlight == true && ho.yHighlight == true) {
											if (k == ho.getColumnToHighlight() && ho.startHighlightRow <= i  && i <= ho.endHighlightRow) {											
												gridBody.append("    <td class=\"lineitemsselected\" align=\"center\">").append(cellValueLink).append("</td>\n");
											} else {
												gridBody.append("    <td class=\"lineitemsgrey\" align=\"center\">").append(cellValue).append("</td>\n");
											}
										} else if (ho.xHighlight == true) {
											if (k == ho.getColumnToHighlight()) {
												gridBody.append("    <td class=\"lineitemsselected\" align=\"center\">").append(cellValueLink).append("</td>\n");
											} else {
												gridBody.append("    <td class=\"lineitemsgrey\" align=\"center\">").append(cellValue).append("</td>\n");
											}
										} else if (ho.yHighlight == true) {
											if (yHighlightRows.contains(new Integer(i))) {
												gridBody.append("    <td class=\"lineitemsselected\" align=\"center\">").append(cellValueLink).append("</td>\n");
											} else {
												gridBody.append("    <td class=\"lineitemsgrey\" align=\"center\">").append(cellValue).append("</td>\n");
											}
										} else {
											if (cellValue.equals("RFQ")) {
												gridBody.append("    <td class=\"lineitems\" align=\"center\">").append(cellValueLink).append("</td>\n");
											} else {
												gridBody.append("    <td class=\"lineitemsselected\" align=\"center\">").append(cellValueLink).append("</td>\n");
											}
										}
									}
								}
							}
						}
					}
				}
				if (yComponentVector != null && yComponentVector.size() < ySequenceCount) {
					tempYaxisSequenceCount = yComponentVector.size();
				}
				if (gc != null && gc.getSpan() > 1) {
					int span = gc.getSpan();
					if (j == 0)
						span = gc.getSpan() - 1;
					vec.insertElementAt(new Integer(span), 1);
					columnCounters.put("" + j, vec);
				}
			}
			
			if (needNewEndTr == true)
				gridBody.append("  </tr>\n");
		}
		return gridBody;
	}
	public final  StringBuffer buildHeader() {
		// Build the grid header
		StringBuffer header = new StringBuffer();
		Vector gridImagesVector = xac.getGridImagesVector();
		String rowspan = "1";
		StringBuffer imageHeader = new StringBuffer();
		if (gridImagesVector.size() > 0) {
			rowspan = "2";
			for (int i=0; i< gridImagesVector.size(); i++) {
				imageHeader.append("    <td class=\"planheader2\" align=\"center\">\n");
				imageHeader.append("      <img src=\"").append(gridImagesVector.elementAt(i)).append("\"/>\n");
				imageHeader.append("    </td>\n");
			}
			imageHeader.append("  </tr>\n");
			imageHeader.append("  <tr>\n");
		}
		for (int i=0; i<xac.getSequenceCount(); i++) {
			header.append("  <tr>\n");
			//header.append("    <td class=\"planheader2\" rowspan=\"").append(rowspan).append("\" colspan=\"").append(yac.getSequenceCount()).append("\">&nbsp;</td>\n");
			Vector xSpecTypesVector = xac.getSpecTypesVector();
			for (int j=0; j<xSpecTypesVector.size(); j++) {
				header.append("    <td class=\"tableheader\" colspan=\"").append(xac.getTableSize()).append("\">").append((String)xSpecTypesVector.elementAt(j)).append("</td>\n");
			}
			header.append("  </tr>\n");
			header.append(imageHeader);
			header.append("  <tr>\n");
			Vector ySpecTypesVector = yac.getSpecTypesVector();
			//for (int j=0; j<ySpecTypesVector.size(); j++) {
				//header.append("    <td class=\"tableheader\">").append((String)ySpecTypesVector.elementAt(j)).append("</td>\n");
			//}
			Hashtable xComponentsBySequence = xac.getComponentsBySequence();
			Vector componentVector = (Vector)xComponentsBySequence.get("axis" + 0);
			for (int j=0; j<xac.getTableSize(); j++) {
				GridComponent gc = (GridComponent)componentVector.elementAt(j);
				header.append("    <td class=\"planheader2\" align=\"center\">").append(((gc.getName().equals("0"))?"Custom":gc.getName())).append("</td>\n");
			}
			header.append("  </tr>\n");
		}
		return header;
	}
	
	public final boolean buildPricingRows() throws Exception {
		boolean gridExists = false;
		StringBuffer NARow = new StringBuffer();
		Vector pricingVector = new Vector();
		Connection conn = null;	
		try {
			int pricePage = 1;
			int colNumber=0;
			String query0 = "SELECT price_page FROM catalog_pages WHERE cat_job_id = " + catJobId + " AND page = " + catalogPage;
			String query1="";
			String query1a="";
			int maxrows=0;
			conn = DBConnect.getConnection();
			Statement st0 = conn.createStatement();
			ResultSet rs0 = st0.executeQuery(query0);
			if (rs0.next()) {
				pricePage = rs0.getInt("price_page");
			}
			rs0.close();
			// Get all of the relevant pricing info
			Hashtable pricingHash = new Hashtable();
			Hashtable perItemHash = new Hashtable();
			int maxRow = 0, maxColumn = 0;						
			if (productCode!=null && !productCode.equals("null") && !(productCode.equals("") )){ 
				//Check to see if site0host specific pricing exists, if not use default pricing
				query1= "Select * from product_prices where prod_price_code='" + productCode + "' AND site_id = " + siteHostId;
				Statement st0a = conn.createStatement();
				ResultSet rs0a = st0a.executeQuery(query1);
				if (rs0a.next()){
					query1 = "Select price, if(pricing_type=2 or pricing_type=3 and price>.01,concat(pt.value,'<br>Estimated: $',format(price,2)),if(price<.01 and pt.value<>'',pt.value,if((rfq>0) and pt.value='','RFQ',if((price<.01) and pt.value='','No Charge',price)))) as cell_label, rfq, '999' as column_number, '0' as row_number,pricing_type,quantity,'each' as units FROM product_prices pp left join product_price_codes pc on pp.prod_price_code=pc.prod_price_code,lu_pricing_types pt WHERE pp.pricing_type=pt.id and pp.site_id='" + siteHostId +"' AND pp.prod_price_code='"+productCode+"'  ORDER BY price desc, quantity desc, row_number DESC, column_number DESC";
					query1a="SELECT  count(*)-1 as  column_number FROM product_prices pp WHERE pp.site_id='" + siteHostId +"' AND  pp.prod_price_code='"+productCode+"'";
				}	else {
					query1 = "Select price, if(pricing_type=2 or pricing_type=3  and price>.01,concat(pt.value,'<br>Estimated: $',format(price,2)),if(price<.01 and pt.value<>'',pt.value,if((rfq>0) and pt.value='','RFQ',if((price<.01) and pt.value='','No Charge',price)))) as cell_label, rfq, '999' as column_number, '0' as row_number,pricing_type,quantity,'each' as units FROM product_prices pp  left join product_price_codes pc on pp.prod_price_code=pc.prod_price_code,lu_pricing_types pt WHERE pp.pricing_type=pt.id and pp.site_id='0' AND pp.prod_price_code='"+productCode+"'  ORDER BY price desc, quantity desc, row_number DESC, column_number DESC";
					query1a="SELECT  count(*)-1 as  column_number FROM product_prices pp WHERE pp.site_id='0' AND  pp.prod_price_code='"+productCode+"'";
				}
				
				rs0a.close();
				Statement st1a = conn.createStatement();
				ResultSet rs1a = st1a.executeQuery(query1a);
				if (rs1a.next()){
					maxColumn=rs1a.getInt("column_number");	
				}else{
					maxColumn=999;
				}
				rs1a.close();
			}else{
				query1 = "SELECT price, cell_label, rfq, 0 as pricing_type,column_number, row_number, '' as units FROM catalog_prices cp, catalog_price_definitions cpd WHERE cat_job_id = " + catJobId + " AND vendor_id = " + vendorId + " AND catalog_page = " + catalogPage + " AND row_number < 99999 AND cpd.id = cp.catalog_price_definition_id AND price_tier_id = " + tierId + " ORDER BY row_number DESC, column_number DESC";
			}
			Statement st1 = conn.createStatement();
			ResultSet rs1 = st1.executeQuery(query1);
			if (rs1.next()) {
				maxRow = rs1.getInt("row_number");
				maxColumn = ((maxColumn==999)?rs1.getInt("column_number"):maxColumn);
				colNumber=maxColumn+1;
				pageContext.setAttribute("gridExists","1");
				gridExists = true;
				do {
					if ((rs1.getInt("column_number")!=999)){
						colNumber=rs1.getInt("column_number");
					}else{
						colNumber=colNumber-1;
					}
					
					int rfq = rs1.getInt("rfq");
					if (pricePage == 1) {
						if (rfq == 0) {
							pricingHash.put(rs1.getString("row_number") + "," + colNumber, new Double(rs1.getDouble("price")));
							if (rs1.getInt("pricing_type")>0 || rs1.getDouble("price")<.01){
								pricingHash.put(rs1.getString("row_number") + "," + colNumber, new String(rs1.getString("cell_label")));
							}
							if (rs1.getDouble("price")>0 && rs1.getInt("quantity")>0){
								perItemHash.put(rs1.getString("row_number") + "," + colNumber+",1", new Double(rs1.getInt("quantity")));
								perItemHash.put(rs1.getString("row_number") + "," + colNumber+",2", new String(rs1.getString("units")));
							}
						} else {
							pricingHash.put(rs1.getString("row_number") + "," + colNumber, (String)rs1.getString("cell_label"));
							if (rs1.getDouble("price")>0 && rs1.getInt("quantity")>0){
								perItemHash.put(rs1.getString("row_number") + "," + colNumber+",1", new Double(rs1.getInt("quantity")));
								perItemHash.put(rs1.getString("row_number") + "," + colNumber+",2", new String(rs1.getString("units")));
							}
						}
					} else if (pricePage == 0) {
						pricingHash.put(rs1.getString("row_number") + "," + colNumber, (String)rs1.getString("cell_label"));
					}
				} while(rs1.next());
			} else {
				pageContext.setAttribute("gridExists","0");
			}
			rs1.close();
			double vendorMarkup = 0; double marcometMarkup = 0;
			String query2 = "SELECT marcomet_global_fee, site_host_global_markup FROM site_hosts WHERE id = " + siteHostId;
			Statement st2 = conn.createStatement();
			ResultSet rs2 = st2.executeQuery(query2);
			if (rs2.next()) {
				vendorMarkup = rs2.getDouble("site_host_global_markup");
				marcometMarkup = rs2.getDouble("marcomet_global_fee");
			}
			rs2.close();
			int siteHostContactId = -1;
			if (!proxyEnabled) {
				String hostQuery = "SELECT cont.id FROM site_hosts sh, companies comp, contacts cont WHERE sh.company_id = comp.id AND comp.id = cont.companyid AND sh.id = " + siteHostId;
				Statement st3 = conn.createStatement();
				ResultSet rs3 = st3.executeQuery(hostQuery);
				if (rs3.next()) {
					siteHostContactId = rs3.getInt("id");
					try {
						if (siteHostContactId == Integer.parseInt(contactId)) vendorMarkup = 0;
					} catch (Exception ex) {
						//
					}
				}
				rs3.close();
			}
			FormaterTool formater = new FormaterTool();
			NumberFormat format3 = new DecimalFormat("0.000");
			for (int x=0; x<=maxRow; x++) {
				Vector pricingRow = new Vector();				
				Vector priceCell = new Vector();
				for (int y=0; y<=maxColumn; y++) {
					priceCell = new Vector();
					String price = "";
					String pricePerItem="";
					if (pricePage == 1) {
						try {
							price = (pricingHash.get(x + "," + y) == null) ? "N/A" : formater.getCurrency(CatalogCalculator.getPriceForGrid(((Double)pricingHash.get(x + "," + y)).doubleValue(), vendorMarkup, marcometMarkup));
							pricePerItem="0";
						} catch (Exception ex) {
							price = (pricingHash.get(x + "," + y) == null) ? "N/A" : (String)pricingHash.get(x + "," + y);
						}
						if(pricePerItem.equals("0")){
							try {
								pricePerItem = (pricingHash.get(x + "," + y) == null) ? "" : "&nbsp;<span class=\"pricePerItem\"> [$"+format3.format( CatalogCalculator.getPriceForGrid(((Double)pricingHash.get(x + "," + y)).doubleValue(), vendorMarkup, marcometMarkup)/(Double)perItemHash.get(x + "," + y+",1") )+" "+perItemHash.get(x + "," + y+",2").toString()+"]</span>";
							} catch (Exception ex) {
								pricePerItem = "";
							}
						}	
					} else {
						price = (pricingHash.get(x + "," + y) == null) ? "N/A" : (String)pricingHash.get(x + "," + y);
					}
					StringBuffer priceLink = new StringBuffer();
					priceLink.append("<a class=\"lineitemslink\" href=\"javascript:makeSelection(").append(x).append(",").append(y).append(")\">").append(price).append(pricePerItem).append("</a>");
					priceCell.addElement(priceLink.toString());
					priceCell.addElement(price);
					if (x == 0)
						NARow.append("    <td class=\"lineitems\" align=\"center\">N/A</td>\n");
					pricingRow.addElement(priceCell);
				}
				pricingVector.addElement(pricingRow);
			}
		} catch (Exception ex) {
			throw new Exception("buildPricingRows error: " + ex.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
			
		po = new PricingObject(pricingVector, NARow);
		return gridExists;
	}
	
	public final int doEndTag() throws JspException {		
		String test="";
		
		try {			
			if (this.buildPricingRows()) {
				test="beforeExtractY";
				this.extractYaxis();
				test="beforeExtractX";
				this.extractXaxis();
				test="before PO";
				ProjectObject po = (ProjectObject) pageContext.getSession().getAttribute("currentProject");
				test="before buildgrid";
				StringBuffer tableData = this.buildGrid(po);
				test="before Getout";
				pageContext.getOut().print(tableData);
			}
			
		} catch (IOException ex) {
			throw new JspException("PricingGridTag.doEndTag IO Error: " + ex.getMessage());
		} catch (Exception ex) {
			throw new JspException(test+"<br>PricingGridTag.doEndTag Error: " + ex.getMessage());
		}
		return EVAL_PAGE;
	}
	
	public final void extractXaxis() throws Exception {
		
		Connection conn = null;
		try {
			// Grab the x axis components
			int xSequenceCount = 0;
			int xTableSize = 0;
			String query0="";
			Vector gridImageVector = new Vector();
			Hashtable xComponentsBySequence = new Hashtable();
			Vector specTypesVector = new Vector();
			conn = DBConnect.getConnection();
			if (productCode!=null && !(productCode.equals("") && !(productCode.equals("null") ))){
				//Check to see if site0host specific pricing exists, if not use default pricing
				query0= "Select * from product_prices where prod_price_code='" + productCode + "' AND site_id = " + siteHostId;
				
				Statement st0a = conn.createStatement();
				ResultSet rs0a = st0a.executeQuery(query0);
				if (rs0a.next()){
					query0="Select '1' as span, if(grid_label is null or grid_label='',format(quantity,0),grid_label) as value, '705' as spec_id, '722' as axis, '0' AS axis_sequence, '0' AS span_sequence,quantity FROM product_prices pp WHERE pp.site_id='" + siteHostId +"' AND pp.prod_price_code='"+productCode+"'  group by value ORDER BY quantity ASC";
				}	else {
					query0="Select '1' as span, if(grid_label is null or grid_label='',format(quantity,0),grid_label) as value, '705' as spec_id, '722' as axis, '0' AS axis_sequence, '0' AS span_sequence,quantity FROM product_prices pp WHERE pp.site_id='0' AND pp.prod_price_code='"+productCode+"'  group by value ORDER BY quantity ASC";
				}
			}else{
				query0 = "SELECT span, value, spec_id, axis, cs.sequence AS axis_sequence, cr.sequence AS span_sequence FROM catalog_rows cr, catalog_specs cs WHERE hidden_field = 0 AND cr.cat_job_id = " + catJobId + " AND cr.cat_spec_id = cs.id AND cr.cat_job_id = cs.cat_job_id AND catalog_page = " + catalogPage + " AND cr.catalog_page = cs.page AND span < 1000000 AND axis = 722 ORDER BY axis, axis_sequence, span_sequence"; 
			}
			Statement st0 = conn.createStatement();
			ResultSet rs0 = st0.executeQuery(query0);
			if (rs0.next()) {
				String query1 = "SELECT pic_url FROM catalog_pic_urls cpu, catalog_rows cr, catalog_specs cs WHERE hidden_field = 0 AND cpu.value = cr.value AND cr.cat_job_id = cs.cat_job_id AND cr.cat_job_id = " + catJobId + " AND cs.spec_id = cpu.cat_spec_id AND cs.id = cr.cat_spec_id AND cpu.cat_spec_id = " + rs0.getString("spec_id") + " AND catalog_page = " + catalogPage + " ORDER BY cr.sequence";
				Statement st1 = conn.createStatement();
				ResultSet rs1 = st1.executeQuery(query1);
				int spanSequence=0;
				if (rs1.next()) {
					do {
						gridImageVector.addElement(rs1.getString("pic_url"));
					} while (rs1.next());
				}
				do {
					if (rs0.getInt("span_sequence")!=spanSequence){
						spanSequence=rs0.getInt("span_sequence");
					}else{
						spanSequence=spanSequence+1;
					}
					GridComponent gc = new GridComponent(rs0.getString("value"), rs0.getInt("spec_id"), rs0.getInt("span"), rs0.getString("axis"), rs0.getInt("axis_sequence"), spanSequence);
					String xAxisNumber = "axis" + rs0.getString("axis_sequence");
					String query2="";
					Vector xExistingComponents = (Vector)xComponentsBySequence.get(xAxisNumber);
					if (xExistingComponents == null) {
						xExistingComponents = new Vector();
						xComponentsBySequence.put(xAxisNumber, xExistingComponents);
						xSequenceCount = xSequenceCount + 1;
							 if(productCode!=null && !(productCode.equals("") && !(productCode.equals("null") ))){
								 query2 = "select concat('Quantity',' (',unit,')') as value from product_price_codes where prod_price_code='"+productCode+"'";
							 }else{
								 query2 = "SELECT value FROM lu_specs WHERE id = " + rs0.getString("spec_id");
							 }
							 
						Statement st2 = conn.createStatement();
						ResultSet rs2 = st2.executeQuery(query2);
						if (rs2.next()) {
							specTypesVector.addElement(rs2.getString("value"));
						}
					}
					xExistingComponents.addElement(gc);
					if (xExistingComponents.size() > xTableSize)
						xTableSize = xExistingComponents.size();
				} while(rs0.next());
			}
			xac = new XaxisContainer();
			xac.setTableSize(xTableSize);
			xac.setSequenceCount(xSequenceCount);
			xac.setComponentsBySequence(xComponentsBySequence);
			xac.setSpecTypesVector(specTypesVector);
			xac.setGridImagesVector(gridImageVector);
		} catch(Exception ex) {
			throw new Exception("extractXaxis error: " + ex.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}
	
	public final  void extractYaxis() throws Exception {
		
		Connection conn = null;
		try {
			// Grab the y axis components
			int ySequenceCount = 0;
			int yTableSize = 0;
			String query0="";
			Hashtable yComponentsBySequence = new Hashtable();
			Vector specTypesVector = new Vector();
			conn = DBConnect.getConnection();
			if (productCode!=null && !(productCode.equals("") && !(productCode.equals("null") ))){
				//Check to see if site0host specific pricing exists, if not use default pricing
				query0= "Select * from product_prices where prod_price_code='" + productCode + "' AND site_id = " + siteHostId;
				Statement st0a = conn.createStatement();
				ResultSet rs0a = st0a.executeQuery(query0);
				if (rs0a.next()){
					query0= "SELECT Distinct '1' as span, ' ' as value, '705' as spec_id, '723' as axis, '0' AS axis_sequence, '1' AS span_sequence FROM product_prices pp, product_price_codes ppc WHERE pp.prod_price_code=ppc.prod_price_code AND pp.site_id=" + siteHostId +" AND pp.prod_price_code='"+productCode+"'  group by price ORDER BY price desc";
				}	else {
					query0= "SELECT Distinct '1' as span, ' ' as value, '705' as spec_id, '723' as axis, '0' AS axis_sequence, '1' AS span_sequence FROM product_prices pp,product_price_codes ppc WHERE pp.prod_price_code=ppc.prod_price_code AND pp.site_id='0' AND pp.prod_price_code='"+productCode+"'  group by price ORDER BY price desc";
				}	
			}else{
				query0 = "SELECT span, value, spec_id, axis, cs.sequence AS axis_sequence, cr.sequence AS span_sequence FROM catalog_rows cr, catalog_specs cs WHERE hidden_field = 0 AND cr.cat_job_id = " + catJobId + " AND cr.cat_spec_id = cs.id AND cr.cat_job_id = cs.cat_job_id AND catalog_page = " + catalogPage + " AND cr.catalog_page = cs.page AND span < 1000000 AND axis = 723 ORDER BY axis_sequence, span_sequence";
			}
			Statement st0 = conn.createStatement();
			ResultSet rs0 = st0.executeQuery(query0);
			if (rs0.next()) {
				do {
					GridComponent gc = new GridComponent(rs0.getString("value"), rs0.getInt("spec_id"), rs0.getInt("span"), rs0.getString("axis"), rs0.getInt("axis_sequence"), rs0.getInt("span_sequence"));
					String yAxisNumber = "axis" + rs0.getString("axis_sequence");
					Vector yExistingComponents = (Vector)yComponentsBySequence.get(yAxisNumber);
					String query1="";
					if (yExistingComponents == null) {
					yExistingComponents = new Vector();
						yComponentsBySequence.put(yAxisNumber, yExistingComponents);
						ySequenceCount = ySequenceCount + 1;
						if(productCode!=null && !(productCode.equals("") && !(productCode.equals("null") ))){
							 query1 = "Select ' '  as value FROM product_price_codes  WHERE prod_price_code='"+productCode+"'";
						}else{
							 query1 = "SELECT value FROM lu_specs WHERE id = " + rs0.getString("spec_id");
						}
						Statement st1 = conn.createStatement();
						ResultSet rs1 = st1.executeQuery(query1);
						if (rs1.next()) {
								specTypesVector.addElement(rs1.getString("value"));
						}
					}
					yExistingComponents.addElement(gc);
					if (yExistingComponents.size() > yTableSize)
						yTableSize = yExistingComponents.size();
				} while(rs0.next());
			}
			yac = new YaxisContainer();
			yac.setTableSize(yTableSize);
			yac.setSequenceCount(ySequenceCount);
			yac.setComponentsBySequence(yComponentsBySequence);
			yac.setSpecTypesVector(specTypesVector);
		} catch (Exception ex) {
			throw new Exception("extractYaxis error: " + ex.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}
	
	public final  String getTagline(HighlightingObject ho, FilteringObject fo) {
		String tagline = "";
		Connection conn = null;
		try {
			String query0 = "SELECT grid_tagline, highlight, filter FROM catalog_pages WHERE cat_job_id = " + catJobId + " AND page = " + catalogPage;
			conn = DBConnect.getConnection();
			Statement st0 = conn.createStatement();
			ResultSet rs0 = st0.executeQuery(query0);
			if (rs0.next()) {
				tagline = rs0.getString("grid_tagline");
				ho.setHighlight(rs0.getInt("highlight"));
				fo.setFilter(rs0.getInt("filter"));
			}
		
		} catch (Exception x) {
			System.err.println(x.getMessage());
			x.printStackTrace();
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
		return tagline;
	}
	public final  void setCatalogPage(String catalogPage) {
		this.catalogPage = catalogPage;
	}
	public final  void setCatJobId(String catJobId) {
		this.catJobId = catJobId;
	}
	public final  void setContactId(String contactId) {
		this.contactId = contactId;
	}
	public final void setProxyEnabled(boolean proxyEnabled) {
		this.proxyEnabled = proxyEnabled;
	}
	public final  void setSiteHostId(String siteHostId) {
		this.siteHostId = siteHostId;
	}
	public final  void setTierId(String tierId) {
		this.tierId = tierId;
	}
        public final  void setProductCode(String productCode) {
                this.productCode = productCode;
        }
	public final  void setVendorId(String vendorId) {
		this.vendorId = vendorId;
	}
}
