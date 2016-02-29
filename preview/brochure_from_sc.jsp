<%@page
	import="java.util.*,javax.servlet.*, com.marcomet.catalog.*, com.pdflib.*,org.ghost4j.*,java.io.*,javax.imageio.*,java.awt.Graphics,java.awt.Image,java.awt.image.*,com.marcomet.jdbc.*,java.sql.*,org.apache.commons.lang.*"%>
<jsp:useBean id="sl" class="com.marcomet.tools.SimpleLookups"
	scope="page" />
<%

   /* Template for generating a pdf for brochures
    * To be used with a job from the shopping cart.
   */
   
   
   	String catJobId=((request.getParameter("catJobId")==null)?"22":request.getParameter("catJobId"));
	String pdfPreviewTemplate=((request.getParameter("pdfPreviewTemplate")==null)?"":request.getParameter("pdfPreviewTemplate"));   
   
	ShoppingCart shoppingCart = (ShoppingCart)request.getSession().getAttribute("DIYshoppingCart");
	
	if(pdfPreviewTemplate.equals("")){
		JobSpecObject jso1 = (JobSpecObject)shoppingCart.getJobSpec(9100);
		if (jso1 != null ){
			pdfPreviewTemplate = (String)jso1.getValue();
		}else{
		 	pdfPreviewTemplate = "";
		}	
	}

	String savedFileType=((request.getParameter("savedFileType")==null)?"":request.getParameter("savedFileType"));
    session.setAttribute("saveFileType",savedFileType);
    
    Vector vBlocks = new Vector();
    Vector vOverflowFields = new Vector();
    Map<String,String> formValues = new HashMap<String,String>();
    ResourceBundle bundle = ResourceBundle.getBundle("com.marcomet.marcomet");
	String homeDir = bundle.getString("transfersPrefix");
	double pagecount = 1;
    ProjectObject po = (ProjectObject)session.getAttribute("currentProject");
	JobObject jo = po.getCurrentJob();
    int jobId=jo.getId();
    String pageButtons="";
    String fieldContent="";
    double pageSize=0.0;
    double pageWidth=0.0;
    double pageHeight=0.0;
    int m=0;
	int f=0;
	int indoc, pageno, endpage, iPage, iFont,pattern;
	boolean overFlow=false;

    //If there were prior files for this job delete them from the temp directory
    
    if (session.getAttribute("lastImage_"+jobId)!=null){
       File source = new File(session.getAttribute("lastImage_"+jobId).toString());
       if(source.exists()){
       	try{
       		source.delete();
		} catch(Exception ex) {}
       }
    }
    if (session.getAttribute("lastPDFImage_"+jobId)!=null){
       File source = new File(session.getAttribute("lastPDFImage_"+jobId).toString());
       if(source.exists()){
       	try{
       		source.delete();
		} catch(Exception ex) {}
       }
    }
    
    Connection conn = DBConnect.getConnection();
	Statement st = conn.createStatement();
    
    Random generator = new Random();
    int r = generator.nextInt();

	boolean saveFile=((request.getParameter("saveFile")==null)?false:true);
	
	// This is where font/image/PDF input files live. Adjust as necessary.
    //Note that this directory must also contain the font
    //outline and metrics files.

	String searchpath = homeDir+"html/data/";
    String lastBlockName="";
    String lastFillText="";
    String tempPath = homeDir+"html/tempFiles/";
    String tempUrlPath = "/tempFiles/";
   	String imageFileName=pdfPreviewTemplate+(String)session.getAttribute("contactId")+"_"+r+".jpg";
   	String pdfFileName=pdfPreviewTemplate+(String)session.getAttribute("contactId")+"_"+r+".pdf";
   	
	String pageNumber=((request.getParameter("pageNumber")==null)?"1":request.getParameter("pageNumber"));
	int previewWidth = Integer.parseInt(((request.getParameter("previewWidth")==null)?"800":request.getParameter("previewWidth")))-30;
	int previewHeight= Integer.parseInt(((request.getParameter("previewHeight")==null)?"400":request.getParameter("previewHeight")))-100;		

if (pdfPreviewTemplate.equals("")){
	%><html>
<head>
<title>Template Not Found</title>
<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
<META HTTP-EQUIV="Expires" CONTENT="-1">
<link rel="stylesheet"
	href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css"
	type="text/css">
</head>
<body>
	<h1>Error: No Template Defined for this product...</h1>
</body>
</html>
<%

}else{
	String pdfPage=((request.getParameter("pdfPage")==null || request.getParameter("pdfPage").equals(""))?"1":request.getParameter("pdfPage"));

//Gather data for all the text-based form fields, excluding the images which will be handled separately.
	String sql = "SELECT cs.id as catSpecId, spec_id, cs.axis, ls.value AS spec_title, label, cs.field_type, reset_value, include_pic_url,preload_field,ctb.field_format,ctb.field_prefix,if(ctb.block_label='',ctb.field_label,ctb.block_label) as blockLabel,ctb.page as pdf_page,image_height_inches,image_width_inches,pdfblock_name,entry_hints,image_mask_file,multipart_block,multipart_separator,text_case,sc_font_size,sc_font_name,preview_font,ctb.content_catspecid as contentHolder FROM catalog_specs cs left join catspec_template_bridge ctb on ctb.catspecid=cs.id and template_name='"+pdfPreviewTemplate.replace("_prepress","").replace("_laser","")+"', lu_specs ls WHERE  cat_job_id = " + request.getParameter("catJobId") + " AND  ls.id = cs.spec_id AND (axis = 724 or axis=725) and ctb.id is not null and ctb.page>0 ORDER BY pdf_page,ctb.sequence";
	ResultSet rsQuestions = st.executeQuery(sql);
	int x=0;
	int y=0;
	String specValue="";
	while(rsQuestions.next()){
		JobSpecObject jso = (JobSpecObject)shoppingCart.getJobSpec(rsQuestions.getInt("spec_id"));
		  if (jso != null){
		  	specValue = (String)jso.getValue();
		  }else{
		  	specValue = "";
		  }
		vBlocks.addElement(((rsQuestions.getString("pdfblock_name")==null)?"":rsQuestions.getString("pdfblock_name")));
		fieldContent=((request.getParameter("^"+rsQuestions.getString("spec_id")+"^"+rsQuestions.getString("catSpecId")) == null)?"":request.getParameter("^"+rsQuestions.getString("spec_id")+"^"+rsQuestions.getString("catSpecId"))); //1
		vBlocks.addElement(fieldContent);//2
		vBlocks.addElement(rsQuestions.getString("field_format"));//3
		vBlocks.addElement(rsQuestions.getString("pdf_page"));//4
		vBlocks.addElement(rsQuestions.getString("field_type"));//5
		vBlocks.addElement(rsQuestions.getString("image_mask_file"));//6
		vBlocks.addElement(rsQuestions.getString("multipart_block"));//7
		vBlocks.addElement(((rsQuestions.getString("multipart_block").equals("1") || rsQuestions.getString("multipart_block").equals("2"))?rsQuestions.getString("multipart_separator"):""));//8
		vBlocks.addElement(((rsQuestions.getString("field_prefix")==null)?"":rsQuestions.getString("field_prefix")));//9
		vBlocks.addElement(((rsQuestions.getString("blockLabel")==null)?"":rsQuestions.getString("blockLabel")));//10
		vBlocks.addElement(((rsQuestions.getString("text_case")==null)?"":rsQuestions.getString("text_case")));//11
		vBlocks.addElement(((rsQuestions.getString("sc_font_size")==null || rsQuestions.getString("sc_font_size").equals(""))?"0":rsQuestions.getString("sc_font_size"))); //12
		vBlocks.addElement(((rsQuestions.getString("sc_font_name")==null)?"":rsQuestions.getString("sc_font_name")));//13
		vBlocks.addElement(((rsQuestions.getString("preview_font")==null)?"":rsQuestions.getString("preview_font")));//14
		vBlocks.addElement(rsQuestions.getString("catSpecId"));//15
		if(rsQuestions.getString("contentHolder")==null || rsQuestions.getString("contentHolder").equals("0") || rsQuestions.getString("contentHolder").equals("")){
			formValues.put(rsQuestions.getString("catSpecId"),specValue);	//16	
		}else if(formValues.containsKey(rsQuestions.getString("contentHolder"))){
			formValues.put(rsQuestions.getString("catSpecId"),formValues.get(rsQuestions.getString("contentHolder")));
		}else{
			formValues.put(rsQuestions.getString("catSpecId"),specValue);		
		}
	}
	x=0;
    int font;
    pdflib p = null ;
    int i, p_blockcontainer,blockcontainer,blockcontainer2, pdipage,p_pdipage,pdipage2;


    byte[] buf;
    ServletOutputStream output;

    String infile = pdfPreviewTemplate;

    p = new pdflib();
    
    // Generate a PDF in memory; insert a file name to create PDF on disk
    if (p.begin_document(tempPath+pdfFileName,"") == -1) {
        System.err.println("Error: " + p.get_errmsg());
		System.exit(1);
    }
    /* Set the search path for fonts and PDF files */
    p.set_parameter("charref", "true"); 
    p.set_parameter("preserveoldpantonenames", "true"); 
    p.set_parameter("SearchPath", searchpath);
    p.set_parameter("resourcefile", homeDir+"html/data/pdflib.upr");

    p.set_info("Creator", "MarComet");
    p.set_info("Author", "MarComet");
    p.set_info("Title",pdfPreviewTemplate);

    blockcontainer = p.open_pdi(infile, "", 0);
    if (blockcontainer == -1) {
        System.err.println("Error: " + p.get_errmsg());
		System.exit(1);
    }
    
    pagecount = p.pcos_get_number(blockcontainer, "length:pages"); 

	int ipdfPage=Integer.parseInt(pdfPage);

	for (i = 1; i <= pagecount; i++) {

		if(pagecount>1){
			pageButtons+="<a href=\"javascript:parent.setPage('"+i+"');\" class='greybutton'>Page "+i+"</a>";
		}
	
    	pdipage = p.open_pdi_page(blockcontainer, i, "");
    	if (pdipage == -1) {
    	    System.err.println("Error: " + p.get_errmsg());
			System.exit(1);
    	}
    	p.begin_page_ext(20, 20, "");              // dummy page size
    	// This will adjust the page size to the block container's size.
    	p.fit_pdi_page(pdipage, 0, 0, "adjustpage");

	//pagewidth=p.get_value("pagewidth",);
    // Fill all text blocks with dynamic data 
    
	    /* Field Formats:
	1	Plain Text
	2	Rich Text
	3	Plain Text Bullets
	4	Rich Text Bullets
	5	Plain Text Tabbed Bullets
	6	Rich Text Tabbed Bullets
	7	Phone with dash
	8	Phone with Parens
	9	Phone with Periods
	10	Phone with Colon Dash	
	11	Fax with Colon Dash	
	12	City, State  Zip	
	13	Full Phone Bullet Full Fax with Periods	
	14	Full Toll-Free Phone	
	15	All Caps	
	16	Wingate by Wyndham Prefix, All Caps	
	17	Wingate by Wyndham Prefix, Title	
	18	Uppercase	
	19	Title Case	
	25 Phone Parens with period
	26 'Amount' - formatting for currency or % with raised symbols and decimal

	  */


	m=0;
	f=0;
	x=0;
    for (int z=0; z<vBlocks.size(); z=z+15) {
    	if(vBlocks.get(z+3).toString().equals(""+i)){
	    	if(vBlocks.get(z+4).toString().equals("800")){//if this is an image field
	    		if(vBlocks.get(z+5)!=null && !vBlocks.get(z+5).toString().equals("")){ //if there is an image mask specified
	    			int mask = p.load_image("auto",searchpath+"/"+vBlocks.get(z+5).toString(), "mask"); 
					if (mask == -1) throw new Exception("Error: " + p.get_errmsg()); 
					String optlist = "masked " + mask; 
					int impImage = p.load_image("auto", ((formValues.get(vBlocks.get(z+14).toString()).indexOf("transfers")>0)?homeDir:tempPath) +formValues.get(vBlocks.get(z+14).toString()), optlist);
					if (impImage == -1) 
						throw new Exception("Error: " + p.get_errmsg()); 
					if(p.fill_imageblock(pdipage, vBlocks.get(z).toString(), impImage,"")==-1)
	    	    		System.err.println("Warning: " + p.get_errmsg());
	    		}else{    	
		    	    int impImage=p.load_image("auto", ((formValues.get(vBlocks.get(z+14).toString()).indexOf("transfers")>0)?homeDir:tempPath)+formValues.get(vBlocks.get(z+14).toString()),""); 
					if(p.fill_imageblock(pdipage, vBlocks.get(z).toString(), impImage,"")==-1)
	    		    	System.err.println("Image Block Warning: " + p.get_errmsg());
	    		}
	    		x++;
    	    }else if(vBlocks.get(z+4).toString().equals("801")){//if this is a prepopulated pdf field, e.g. maps
				//int impImage = p.load_image("auto", ((vBlocks.get(z+1).toString().indexOf("transfers")>0)?homeDir:tempPath) +vBlocks.get(z+1).toString(), "");
				
				blockcontainer2 = p.open_pdi(((formValues.get(vBlocks.get(z+14).toString()).indexOf("transfers")>0)?homeDir:tempPath) +formValues.get(vBlocks.get(z+14).toString()), "", 0);
				if (blockcontainer2 == -1) {
        			blockcontainer2 = p.open_pdi(homeDir+"transfers/maps/nomap.pdf", "", 0);
			        if (blockcontainer == -1) {
			        	System.err.println("Error: " + p.get_errmsg());
						System.exit(1);
			    	}
    			}
				pdipage2 = p.open_pdi_page(blockcontainer2, 1, "");
				if (pdipage2 == -1) {
					throw new Exception("Error: " + p.get_errmsg()); 
				}else{
					if(p.fill_pdfblock(pdipage, vBlocks.get(z).toString(), pdipage2,"")==-1)
						System.err.println("Warning: " + p.get_errmsg());
					p.close_pdi_page(pdipage2);
					p.close_pdi(blockcontainer2);
				}
	    	}else{
	    			if(f==0){
	    				p.fit_pdi_page(pdipage, 0, 0, "");
	    				f++;
	    			}
		    		String fillText=((formValues.containsKey(vBlocks.get(z+14).toString()) )?formValues.get(vBlocks.get(z+14).toString()):vBlocks.get(z+1).toString());
		    		fillText=((fillText==null)?"":fillText);
		    		
		    	    if(!fillText.equals("")){
			    		if(vBlocks.get(z+2).toString().equals("13")){
			    			fillText="Tel&nbsp;"+fillText.replaceAll(" ","").replaceAll("-","\\.").replace(",","&nbsp;&bull;&nbsp;Fax&nbsp;");
			    		}else if(vBlocks.get(z+2).toString().equals("14")){
			    			fillText="Toll-Free&nbsp;1."+fillText.replaceAll(" ","").replaceAll("-","\\.").replace("Ext-","Ext\\.");
			    		}else if(vBlocks.get(z+2).toString().equals("15")){
			    			fillText=fillText.toUpperCase();
			    		}else if(vBlocks.get(z+2).toString().equals("16")){
			    			fillText="WINGATE BY WYNDHAM<textrise=50% fontsize=70% >&#174;<textrise=0% fontsize=150% > "+fillText.toUpperCase();
			    		}else if(vBlocks.get(z+2).toString().equals("17")){
			    			fillText="Wingate by Wyndham<textrise=50% fontsize=70% >&#174;<textrise=0% fontsize=150% > "+WordUtils.capitalizeFully(fillText);
			    		}else if(vBlocks.get(z+2).toString().equals("18")){
			    			fillText=fillText.toUpperCase();
			    		}else if(vBlocks.get(z+2).toString().equals("19")){
			    			fillText="Email: "+fillText;
			    		}else if(vBlocks.get(z+2).toString().equals("20")){
			    			fillText=WordUtils.capitalizeFully(fillText);
			    		}else if(vBlocks.get(z+2).toString().equals("21")){
			    			fillText="Tel: "+fillText.replaceAll(" ","").replaceAll("\\.","-").replace("Ext-","Ext\\.");
			    		}else if(vBlocks.get(z+2).toString().equals("11")){
			    			fillText="Fax: "+fillText.replaceAll(" ","").replaceAll("\\.","-").replace("Ext-","Ext\\.");
			    		}else if(vBlocks.get(z+2).toString().equals("10")){
			    			fillText="Phone: "+fillText.replaceAll(" ","").replaceAll("\\.","-").replace("Ext-","Ext\\.");
			    		}else if(vBlocks.get(z+2).toString().equals("23")){
			    			fillText=fillText.replaceAll(" ","").replaceAll("-","\\.").replace("Ext-","Ext\\.")+" fax";
			    		}else if(vBlocks.get(z+2).toString().equals("22")){
			    			fillText=fillText.replaceAll(" ","").replaceAll("-","\\.").replace("Ext-","Ext\\.")+" tel";
			    		}else if(vBlocks.get(z+2).toString().equals("9")){
			    			fillText=fillText.replaceAll(" ","").replaceAll("-","\\.");
			    		}else if(vBlocks.get(z+2).toString().equals("8")){
			    			fillText="("+fillText.replaceAll(" ","").replaceAll("\\.","-").replaceFirst("-",") ");
			    		}else if(vBlocks.get(z+2).toString().equals("7")){
			    			fillText=fillText.replaceAll(" ","").replaceAll("\\.","-").replaceAll("\\(","").replace(")","-");
			    		}else if(vBlocks.get(z+2).toString().equals("6")){
			    			fillText="&bull;&nbsp;"+fillText;
				    		fillText=fillText.replaceAll("\r","\t&bull;&nbsp;").replaceAll("\n","");
			    		}else if(vBlocks.get(z+2).toString().equals("5")){
			    			fillText="&bull;&nbsp;"+fillText;
				    		fillText=fillText.replaceAll("\r","\t&bull;&nbsp;").replaceAll("\n","");
			    		}else if(vBlocks.get(z+2).toString().equals("4")){
			    			fillText="&bull; "+fillText.replaceAll("\n","\n&bull; "); 	
			    		}else if(vBlocks.get(z+2).toString().equals("24")){
			    			fillText="<fillcolor={cmyk 0 0.4 0.9 0} strokecolor={cmyk 0 0 0 0.5} >&bull;<fillcolor={cmyk 0 0 0 0.6} strokecolor={cmyk 0 0 0 0.5} > "+fillText.replaceAll("\n","\n<fillcolor={cmyk 0 0.4 0.9 0} strokecolor={cmyk 0 0 0 0.5} >&bull;<fillcolor={cmyk 0 0 0 0.6} strokecolor={cmyk 0 0 0 0.5} > ");
			    		}else if(vBlocks.get(z+2).toString().equals("25")){
				    		fillText="("+fillText.replaceAll(" ","").replaceAll("\\.","-").replaceFirst("-",") ");
			    			fillText=fillText.replaceAll("-","\\.");
			    		}else if(vBlocks.get(z+2).toString().equals("3")){
			    			fillText="&bull; "+fillText.replaceAll("\n","\n&bull; "); 	
			    		}else if(vBlocks.get(z+2).toString().equals("26")){
			    		//If there's a % sign reduce the size by 40% and raise it to the top of the block
			    			if(fillText.indexOf("%")>-1){
			    				fillText=fillText.replaceAll("%","");
			    				fillText=fillText+"<textrise=25% fontsize=70% >%<textrise=0% fontsize=150% >";
			    			}else if(fillText.indexOf(".")>-1){ //if there's no % sign treat it as currency. Check for a decimal, if one is there raise the decimal amount
			    				fillText=fillText.replaceAll("\\$","");
			    				String fillTextLeft=fillText.substring(0,fillText.indexOf("."));
			    				String fillTextRight=fillText.substring(fillText.indexOf("."),fillText.length());
			    				fillText="<textrise=25% fontsize=70% >$<textrise=0 fontsize=150% >"+fillTextLeft+"<textrise=25% fontsize=70% >"+fillTextRight;
			    			}else{ //if there's no decimal raise the dollar sign and add on the decimal, raised.
			    				fillText=fillText.replaceAll("\\$","");
			    				fillText="<textrise=25% fontsize=70% >$<textrise=0 fontsize=150% >"+fillText+"<textrise=25% fontsize=70% >.00";
			    			}
			    			
			    		}

			    	}
			    	
			    	if(!fillText.equals("")){
			    		fillText=vBlocks.get(z+8).toString()+fillText;
 			    		
			    		String newString="";

			    		int fontSize=Integer.parseInt(vBlocks.get(z+11).toString());
			    		String fontName=vBlocks.get(z+12).toString();
			    		String previewFontName=vBlocks.get(z+13).toString();

			    		if(vBlocks.get(z+10).toString().toUpperCase().equals("SMALL CAPS") && fontSize>0){
				    		for (int ii = 0; ii < fillText.length(); ii++){
								if((fillText.charAt(ii)+"").toUpperCase().equals(fillText.charAt(ii)+"")){
									newString+="<fontsize="+fontSize+" fontname="+fontName+" encoding=unicode>"+fillText.charAt(ii)+"<fontsize="+(fontSize*.75)+" fontname="+fontName+" encoding=unicode>";
																	}else{
									newString+=(fillText.charAt(ii)+"").toUpperCase();

								}
							}
							fillText=newString+"<fontsize="+fontSize+" fontname="+fontName+" encoding=unicode>";
			    		}
			    	}
			    	
			    	if(lastBlockName.equals(vBlocks.get(z).toString())){
			    		fillText=lastFillText+((fillText.equals(""))?"":vBlocks.get(z+7).toString()+ fillText);

			    	}
			    	if(fillText.equals("")){
			    	
			    	}else{
						int tf=-1;
						String optlist ="fitmethod=clip embedding=true encoding=unicode textflowhandle=" + tf;
						//fillText=((fillText.equals(""))?" ":fillText);
						if(vBlocks.get(z+6).toString().equals("0") || vBlocks.get(z+6).toString().equals("2")){
							tf=p.fill_textblock(pdipage, vBlocks.get(z).toString(), fillText,optlist );
							if (tf==-1) {
				    			System.err.println("Text Block Warning("+z+")" + p.get_errmsg());
							}
							int reason = (int) p.info_textflow(tf, "returnreason");
	            			String result = p.get_parameter("string", (float) reason);
	            			if (result.equals("_boxfull")){
	            				optlist=optlist+" bordercolor={rgb 1 0 0} linewidth=.25 ";
	            				tf=p.fill_textblock(pdipage, vBlocks.get(z).toString(), fillText,optlist );
	            				overFlow=true;
	            				vOverflowFields.addElement(vBlocks.get(z+9));
	            			}
	
							
							/*reason = (int) pp.info_textflow(tf, "returnreason");
	            			result = pp.get_parameter("string", (float) reason);
	            			if (result.equals("_boxfull")){
	            				optlist=optlist+" bordercolor={rgb 1 0 0} linewidth=.25 ";
	            				tf=pp.fill_textblock(p_pdipage, vBlocks.get(z).toString(), p_fillText,optlist );
	            				overFlow=true;
	            				//vOverflowFields.addElement(vBlocks.get(z+9));
	            			} */
	
						}
					}
					lastFillText=fillText;

					lastBlockName=vBlocks.get(z).toString();
			}
		}
    }
    
  
    p.save();

    p.restore();
    p.end_page_ext("");                        // close page
    p.close_pdi_page(pdipage);
}    
    
    p.end_document("");                           // close PDF document
    p.close_pdi(blockcontainer);
    
    
    //Prepare the preview jpg for presentation
    Process p1=Runtime.getRuntime().exec("gs -q -dNOPAUSE -dBATCH -dFirstPage="+pdfPage+" -dLastPage="+pdfPage+" -sDEVICE=jpeg -r"+((pageSize<15)?"400":((pageSize<30)?"300":((pageSize<70)?"200":"150")))+"  -sOutputFile="+tempPath + imageFileName+" "+tempPath+pdfFileName);
    p1.waitFor();
    Process p11=Runtime.getRuntime().exec("convert "+tempPath + imageFileName+" -filter Lanczos -resize "+previewWidth+"x"+previewHeight+" -quality 90 "+ tempPath + imageFileName);
    p11.waitFor();
    
	///put a watermark on the pdf file.
	
    try{
    	double w;
        double ret;
        String res;
        int image;

        // data set for our halftoning bitmap 
        int data[][] = {
        {   0x00, 0x00,  // 30%
            0x00, 0x00,
            0x00, 0x00,
            0x03, 0xC0,
            0x07, 0xE0,
            0x0F, 0xF0,
            0x1F, 0xF8,
            0x1F, 0xF8,
    
            0x1F, 0xF8,
            0x1F, 0xF8,
            0x0F, 0xF0,
            0x07, 0xE0,
            0x03, 0xC0,
            0x00, 0x00,
            0x00, 0x00,
            0x00, 0x00,
        },
        {   0x00, 0x00, // 20% 
            0x00, 0x00,
            0x00, 0x00,
            0x00, 0x00,
            0x03, 0xC0,
            0x07, 0xE0,
            0x0F, 0xF0,
            0x0F, 0xF0,
    
            0x0F, 0xF0,
            0x0F, 0xF0,
            0x07, 0xE0,
            0x03, 0xC0,
            0x00, 0x00,
            0x00, 0x00,
            0x00, 0x00,
            0x00, 0x00,
        }};
    
        int ht = 1; // index in halftone array 
			
		pdflib pb = new pdflib();
	    pb.set_parameter("resourcefile", homeDir+"html/data/pdflib.upr");
	    pb.set_parameter("SearchPath", searchpath);
	    pb.set_parameter("errorpolicy", "return");
		if (pb.begin_document(tempPath+pdfFileName.replace(".pdf","_proof.pdf"),"optimize=false ") == -1)
	            throw new Exception("Error: " + pb.get_errmsg());
	    pb.set_info("Creator", "MarComet");
	    pb.set_info("Author", "MarComet");
	    pb.set_info("Title",pdfPreviewTemplate);
	
		indoc = pb.open_pdi_document(tempPath+pdfFileName, "");
	    if (indoc == -1)
	            throw new Exception("Error: " + pb.get_errmsg());
	    endpage = (int)pagecount;
	    
	    res = pb.pcos_get_string(indoc, "type:/Root/OutputIntents");
	    if (res.equals("array")) {
	        ret = pb.process_pdi(indoc, -1, "action=copyoutputintent");
	        if (ret == -1)
	            throw new Exception("Error: " + pb.get_errmsg());
	    }
	
	    byte[] bitmap = new byte[data[ht].length];
	    for (int j = 0; j < data[ht].length; j++)
	        bitmap[j] = (byte) data[ht][j];
	
	    pb.create_pvf("/pvf/image/bitmap", bitmap, "");
	
	    image = pb.load_image("raw", "/pvf/image/bitmap",
	            "bpc=1 components=1 height=16 width=16 invert mask");
	
	    if (image == -1)
	        throw new Exception("Error: " + pb.get_errmsg());
	
	    w = (double) 16 / 32;
	    pattern = pb.begin_pattern(w, w, w, w, 1);
	
	    pb.fit_image(image, 0, 0, "scale=" + (double) 1 / 32);
	
	    pb.end_pattern();
	
	    pb.close_image(image);
		    
	    for (pageno = 1; pageno <= endpage; pageno++){
	            iPage = pb.open_pdi_page(indoc, pageno, "");
	            if (iPage == -1) throw new Exception("Error: " + pb.get_errmsg());
	            pb.begin_page_ext(10, 10, "");
	            pb.fit_pdi_page(iPage, 0, 0, "adjustpage");
	            
	            iFont = pb.load_font("Helvetica-BlackOblique", "unicode", "");
	            if (iFont == -1)  throw new Exception("Error: " + pb.get_errmsg());
	            pb.close_pdi_page(iPage);
	            pb.end_page_ext("");
	     }
	     
	     pb.end_document("");
	     if (pb != null) {
	       pb.delete();
	     } 
       }catch (IOException e) {
       		System.out.println("ERROR: " + e.getMessage());
       }
       
  jo.setPreBuiltFile(tempPath+imageFileName);
  jo.setPreBuiltFileURL(tempUrlPath+imageFileName);
  jo.setPreBuiltPDFFile(tempPath+pdfFileName);
  jo.setPreBuiltPDFFileURL(tempUrlPath+pdfFileName);


%><html>
<head>
<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
<META HTTP-EQUIV="Expires" CONTENT="-1">
<link rel="stylesheet"
	href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css"
	type="text/css">
<title>Preview</title>
</head>
<body bgcolor="#c8c8c8">
	<%
if (saveFile){
	%><script type="text/javascript">parent.document.forms[0].submit();</script>
</body>
<%
}else{
	%><body bgcolor="#c8c8c8">
	<table width=100% height=100% cellpadding="0" cellspacing="0"
		border="0">
		<tr>
			<td align="center" valign="top"><span class='subtitle'><i>
						Click image for full-size preview<!--<br>NOTE: Colors in preview image are approximate; final printed product colors may vary.</i></span>-->
						<br><%=((pageButtons.equals(""))?"":pageButtons+"<br>")%><a
						href="<%=tempUrlPath+pdfFileName%>" target='_blank'><img
							src="<%=tempUrlPath +imageFileName%>" border=1 alt=""></a>
				</i></span></td>
		</tr>
	</table>
</body>
<%
}
%>
</html><%}%>