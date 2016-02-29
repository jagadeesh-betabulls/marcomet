<%@page import="java.util.*,javax.servlet.*, com.marcomet.catalog.*, com.pdflib.*,org.jpedal.*,java.io.*,javax.imageio.*,java.awt.Graphics,java.awt.Image,java.awt.image.*,com.marcomet.jdbc.*,java.sql.*,org.apache.commons.lang.*" %><%

   /* Template for generating a pdf for brochures
    *
    * NOTE: Must be used with a pdf preview template defined on the product
   */

    Vector vBlocks = new Vector();
    Vector vOverflowFields = new Vector();
    ResourceBundle bundle = ResourceBundle.getBundle("com.marcomet.marcomet");
	String homeDir = bundle.getString("transfersPrefix");
	double pagecount = 1;
    ProjectObject po = (ProjectObject)session.getAttribute("currentProject");
	JobObject jo = po.getCurrentJob();
    int jobId=jo.getId();
    String pageButtons="";
    int m=0;
	int f=0;
	int indoc, pageno, endpage, iPage, iFont,pattern;
	boolean overFlow=false;

    //If there were prior files for this job delete them from the temp directory
    String savedFileType=((request.getParameter("savedFileType")==null)?"":request.getParameter("savedFileType"));;
    session.setAttribute("saveFileType",savedFileType);
    
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
	String pdfPreviewTemplate=((request.getParameter("pdfPreviewTemplate")==null)?"":request.getParameter("pdfPreviewTemplate"));
	boolean saveFile=((request.getParameter("saveFile")==null)?false:true);
	
	// This is where font/image/PDF input files live. Adjust as necessary.
    //Note that this directory must also contain the font
    //outline and metrics files.

	String searchpath = homeDir+"html/data/";
    String lastBlockName="";
    String lastFillText="";
    String p_lastFillText="";
    String tempPath = homeDir+"html/tempFiles/";
    String tempUrlPath = "/tempFiles/";
   	String imageFileName=pdfPreviewTemplate+(String)session.getAttribute("contactId")+"_"+r+".jpg";
   	String pdfFileName=pdfPreviewTemplate+(String)session.getAttribute("contactId")+"_"+r+".pdf";
   	String pagewidth=((request.getParameter("pPageWidth")==null)?"1":request.getParameter("pPageWidth"));
   	String pageheight=((request.getParameter("pPageHeight")==null)?"1":request.getParameter("pPageHeight"));
	String pageNumber=((request.getParameter("pageNumber")==null)?"1":request.getParameter("pageNumber"));
	int previewWidth = Integer.parseInt(((request.getParameter("previewWidth")==null)?"800":request.getParameter("previewWidth")))-25;
	int previewHeight= Integer.parseInt(((request.getParameter("previewHeight")==null)?"400":request.getParameter("previewHeight")))-25;		
    String infile = pdfPreviewTemplate;
if (pdfPreviewTemplate.equals("")){
	%><html><head>
	        <title>Template Not Found</title>
<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
<META HTTP-EQUIV="Expires" CONTENT="-1">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head><body><h1>Error: No Template Defined for this product...</h1></body></html><%

}else{
  File fi = new File(homeDir+"html/data/"+infile);
  if (fi.exists()){
	String pdfPage=((request.getParameter("pdfPage")==null || request.getParameter("pdfPage").equals(""))?"1":request.getParameter("pdfPage"));

//Gather data for all the text-based form fields, excluding the images which will be handled separately.
	String sql = "SELECT cs.id as catSpecId, spec_id, cs.axis, ls.value AS spec_title, label, cs.field_type, reset_value, include_pic_url,preload_field,ctb.field_format,ctb.field_prefix,if(ctb.block_label='',ctb.field_label,ctb.block_label) as blockLabel,ctb.page as pdf_page,image_height_inches,image_width_inches,pdfblock_name,entry_hints,image_mask_file,multipart_block,multipart_separator,text_case,sc_font_size,sc_font_name,preview_font FROM catalog_specs cs left join catspec_template_bridge ctb on ctb.catspecid=cs.id and template_name='"+pdfPreviewTemplate.replace("_prepress","").replace("_laser","")+"', lu_specs ls WHERE  cat_job_id = " + request.getParameter("catJobId") + " AND cs.page = " + request.getParameter("currentCatalogPage") + " AND ls.id = cs.spec_id AND (axis = 724 or axis=725) and ctb.id is not null and ctb.page>0 ORDER BY pdf_page,ctb.sequence";
   ResultSet rsQuestions = st.executeQuery(sql);

   int x=0;
   int y=0;

	while(rsQuestions.next()){
		vBlocks.addElement(((rsQuestions.getString("pdfblock_name")==null)?"":rsQuestions.getString("pdfblock_name")));
		vBlocks.addElement(request.getParameter("^"+rsQuestions.getString("spec_id")+"^"+rsQuestions.getString("catSpecId")));
		vBlocks.addElement(rsQuestions.getString("field_format"));
		vBlocks.addElement(rsQuestions.getString("pdf_page"));
		vBlocks.addElement(rsQuestions.getString("field_type"));
		vBlocks.addElement(rsQuestions.getString("image_mask_file"));
		vBlocks.addElement(rsQuestions.getString("multipart_block"));
		vBlocks.addElement(((rsQuestions.getString("multipart_block").equals("1") || rsQuestions.getString("multipart_block").equals("2"))?rsQuestions.getString("multipart_separator"):""));
		vBlocks.addElement(((rsQuestions.getString("field_prefix")==null)?"":rsQuestions.getString("field_prefix")));
		vBlocks.addElement(((rsQuestions.getString("blockLabel")==null)?"":rsQuestions.getString("blockLabel")));
		vBlocks.addElement(((rsQuestions.getString("text_case")==null)?"":rsQuestions.getString("text_case")));
		vBlocks.addElement(((rsQuestions.getString("sc_font_size")==null || rsQuestions.getString("sc_font_size").equals(""))?"0":rsQuestions.getString("sc_font_size")));
		vBlocks.addElement(((rsQuestions.getString("sc_font_name")==null)?"":rsQuestions.getString("sc_font_name")));
		vBlocks.addElement(((rsQuestions.getString("preview_font")==null)?"":rsQuestions.getString("preview_font")));
	}
	x=0;
    int font;
    pdflib p = null ;
    pdflib pp = null ;
    int i, p_blockcontainer,blockcontainer,blockcontainer2, pdipage,p_pdipage,pdipage2;


    byte[] buf;
    ServletOutputStream output;

    p = new pdflib();
    pp = new pdflib();
    
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


    if (pp.begin_document(tempPath+"p_"+pdfFileName,"") == -1) {
        System.err.println("Error: " + p.get_errmsg());
		System.exit(1);
    }
    /* Set the search path for fonts and PDF files */
    pp.set_parameter("charref", "true"); 
    pp.set_parameter("preserveoldpantonenames", "true"); 
    pp.set_parameter("SearchPath", searchpath);
    pp.set_parameter("resourcefile", homeDir+"html/data/pdflib.upr");

    pp.set_info("Creator", "MarComet");
    pp.set_info("Author", "MarComet");
    pp.set_info("Title",pdfPreviewTemplate);

    p_blockcontainer = pp.open_pdi(infile, "", 0);
    if (p_blockcontainer == -1) {
        System.err.println("Error: " + pp.get_errmsg());
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
    p_pdipage = pp.open_pdi_page(p_blockcontainer, i, "");
    if (p_pdipage == -1) {
        System.err.println("Error: " + pp.get_errmsg());
		System.exit(1);
    }
    
    p.begin_page_ext(20, 20, "");              // dummy page size
    // This will adjust the page size to the block container's size.
    p.fit_pdi_page(pdipage, 0, 0, "adjustpage");
    pp.begin_page_ext(20, 20, "");              // dummy page size
    // This will adjust the page size to the block container's size.
    pp.fit_pdi_page(p_pdipage, 0, 0, "adjustpage");
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

	  */

	m=0;
	f=0;
	x=0;

    for (int z=0; z<vBlocks.size(); z=z+14) {
    	if(vBlocks.get(z+3).toString().equals(""+i)){
	    	if(vBlocks.get(z+4).toString().equals("800")){//if this is an image field
	    		if(vBlocks.get(z+5)!=null && !vBlocks.get(z+5).toString().equals("")){ //if there is an image mask specified
	    			int mask = p.load_image("auto",searchpath+"/"+vBlocks.get(z+5).toString(), "mask"); 
					if (mask == -1)
						throw new Exception("Error: " + p.get_errmsg()); 
					String optlist = "masked " + mask; 
					int impImage = p.load_image("auto", ((vBlocks.get(z+1).toString().indexOf("transfers")>0)?homeDir:tempPath) +vBlocks.get(z+1).toString(), optlist);
					if (impImage == -1) 
						throw new Exception("Error: " + p.get_errmsg()); 
					if(p.fill_imageblock(pdipage, vBlocks.get(z).toString(), impImage,"")==-1)
	    	    		System.err.println("Warning: " + p.get_errmsg());
	    		}else{    	
		    	    int impImage=p.load_image("auto", ((vBlocks.get(z+1).toString().indexOf("transfers")>0)?homeDir:tempPath)+vBlocks.get(z+1).toString(),""); 
					if(p.fill_imageblock(pdipage, vBlocks.get(z).toString(), impImage,"")==-1)
	    		    	System.err.println("Image Block Warning: " + p.get_errmsg());
	    		}
	    		x++;
    	    }else if(vBlocks.get(z+4).toString().equals("801")){//if this is a prepopulated pdf field, e.g. maps
				//int impImage = p.load_image("auto", ((vBlocks.get(z+1).toString().indexOf("transfers")>0)?homeDir:tempPath) +vBlocks.get(z+1).toString(), "");
				
				blockcontainer2 = p.open_pdi(((vBlocks.get(z+1).toString().indexOf("transfers")>0)?homeDir:tempPath) +vBlocks.get(z+1).toString(), "", 0);
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
	    				pp.fit_pdi_page(p_pdipage, 0, 0, "");
	    				f++;
	    			}
		    		String fillText=vBlocks.get(z+1).toString();
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
			    		}

			    	}
			    	String p_fillText=fillText;
			    	if(!fillText.equals("")){
			    		fillText=vBlocks.get(z+8).toString()+fillText;
 			    		p_fillText=vBlocks.get(z+8).toString()+p_fillText;	
			    		String newString="";
			    		String pnewString="";
			    		int fontSize=Integer.parseInt(vBlocks.get(z+11).toString());
			    		String fontName=vBlocks.get(z+12).toString();
			    		String previewFontName=vBlocks.get(z+13).toString();
			    		System.out.println(vBlocks.get(z+10).toString());
			    		if(vBlocks.get(z+10).toString().toUpperCase().equals("SMALL CAPS") && fontSize>0){
				    		for (int ii = 0; ii < fillText.length(); ii++){
								if((fillText.charAt(ii)+"").toUpperCase().equals(fillText.charAt(ii)+"")){
									newString+="<fontsize="+fontSize+" fontname="+fontName+" encoding=unicode>"+fillText.charAt(ii)+"<fontsize="+(fontSize*.75)+" fontname="+fontName+" encoding=unicode>";
									pnewString+="<fontsize="+fontSize+" fontname="+((previewFontName.equals(""))?fontName:previewFontName)+" encoding=unicode>"+p_fillText.charAt(ii)+"<fontsize="+(fontSize*.75)+" fontname="+fontName+" encoding=unicode>";
								}else{
									newString+=(fillText.charAt(ii)+"").toUpperCase();
									pnewString+=(p_fillText.charAt(ii)+"").toUpperCase();
								}
							}
							fillText=newString+"<fontsize="+fontSize+" fontname="+fontName+" encoding=unicode>";
							p_fillText=pnewString+"<fontsize="+fontSize+" fontname="+fontName+" encoding=unicode>";
			    		}else{
				    		if(!previewFontName.equals("")){
				    			p_fillText="<fontname="+previewFontName+" encoding=unicode>"+p_fillText;
				    		}else{
				    			p_fillText=fillText;
				    		}
			    		}
			    	}
			    	
			    	if(lastBlockName.equals(vBlocks.get(z).toString())){
			    		fillText=lastFillText+((fillText.equals(""))?"":vBlocks.get(z+7).toString()+ fillText);
			    		p_fillText=p_lastFillText+((p_fillText.equals(""))?"":vBlocks.get(z+7).toString()+ p_fillText);
			    	}
					int tf=-1;
					String optlist ="fitmethod=clip embedding encoding=unicode textflowhandle=" + tf;
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


						tf=pp.fill_textblock(p_pdipage, vBlocks.get(z).toString(), p_fillText,optlist );
						if (tf==-1) {
			    			System.err.println("Text Block Warning2("+z+")" + pp.get_errmsg());
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
					lastFillText=fillText;
					p_lastFillText=p_fillText;
					lastBlockName=vBlocks.get(z).toString();
			}
		}
    }
    
 
    p.save();
    p.restore();
    p.end_page_ext("");                        // close page
    p.close_pdi_page(pdipage);
    
    pp.save();
    pp.restore();
    pp.end_page_ext("");                        // close page
    pp.close_pdi_page(pdipage);
}      
    p.end_document("");                           // close PDF document
    p.close_pdi(blockcontainer);  
    
    pp.end_document("");                           // close PDF document
    pp.close_pdi(blockcontainer);    
    //Prepare the preview jpg for presentation
    
	PdfDecoder decoder = new PdfDecoder();
	decoder.openPdfFile(tempPath+"p_"+pdfFileName);
	//Vector dim;
	float scale;
	int width = previewWidth;
	if (decoder.isFileViewable()){	
		//decoder.decodePage(1);
		//dim = decoder.getSize();
		if(pagewidth.equals("1")){
			decoder.setPageParameters(1,1);	
		}else{
			scale = (float)( width/Double.valueOf(pagewidth.trim()).doubleValue());	
			decoder.setPageParameters(scale, 1);	
		}
		BufferedImage thisImage = decoder.getPageAsImage(ipdfPage);
		Graphics g = thisImage.getGraphics();
        int resizeWidth = 0;
        int resizeHeight = 0;
        resizeHeight = thisImage.getHeight(); //previewHeight;
        resizeWidth = thisImage.getWidth();//(thisImage.getWidth() * resizeHeight) / thisImage.getHeight();
        BufferedImage resizedImage = new BufferedImage(resizeWidth, resizeHeight, BufferedImage.TYPE_INT_RGB);
        resizedImage.createGraphics().drawImage(thisImage, 0, 0, resizeWidth, resizeHeight, null);

		File dir = new File(tempPath);
		if (dir.isDirectory()) {
			File fileToSave = new File(tempPath + imageFileName);
			ImageIO.write((RenderedImage)resizedImage,"jpg", fileToSave);
			session.setAttribute("lastImage_"+jobId,tempPath + imageFileName);
			session.setAttribute("lastPDFImage_"+jobId,tempPath+pdfFileName);
		}else{
			%>There was a problem saving the PDF file.<%
		}
	}
	
	///put a watermark on the pdf file.
	
	    double w;
        double ret;
        String res;
        int image;

        /* data set for our halftoning bitmap */
        int data[][] = {
        {   0x00, 0x00,  /* 30% */
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
        {   0x00, 0x00, /* 20% */
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
    
        int ht = 1; /* index in halftone array */

	
	pdflib pb = null;
    pb = new pdflib();
    pb.set_parameter("resourcefile", homeDir+"html/data/pdflib.upr");
    pb.set_parameter("SearchPath", searchpath);
    pb.set_parameter("errorpolicy", "return");
	if (pb.begin_document(tempPath+pdfFileName.replace(".pdf","_proof.pdf"),"optimize=true ") == -1)
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
            if (iPage == -1)
                throw new Exception("Error: " + pb.get_errmsg());
            pb.begin_page_ext(10, 10, "");
            pb.fit_pdi_page(iPage, 0, 0, "adjustpage");
            iFont = pb.load_font("Helvetica-BlackOblique", "unicode", "");
			
            if (iFont == -1)
                throw new Exception("Error: " + pb.get_errmsg());

                /* Place the stamp, filled with the pattern color */
                pb.setcolor("fill", "pattern", pattern, 0, 0, 0);

                pb.fit_textline("P R O O F", 0, 0, "font=" + iFont
                        + " fontsize=1 boxsize={"+pagewidth+" "+pageheight+"} stamp=ul2lr");

            pb.close_pdi_page(iPage);
            pb.end_page_ext("");
        }
        pb.end_document("");
        if (pb != null) {
           pb.delete();
        }

if(saveFile){
  jo.setPreBuiltFile(tempPath+imageFileName);
  jo.setPreBuiltFileURL(tempUrlPath+imageFileName);
  jo.setPreBuiltPDFFile(tempPath+pdfFileName);
  jo.setPreBuiltPDFFileURL(tempUrlPath+pdfFileName);
}
%><html><head>
<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
<META HTTP-EQUIV="Expires" CONTENT="-1">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<link rel="stylesheet" href="/styles/marcomet.css" type="text/css">
<title>Preview</title></head><body bgcolor="#c8c8c8"><%
if (saveFile){
	%></head><body bgcolor="#c8c8c8"><script>parent.document.forms[0].submit();</script></body><%
}else{
	%></head><body bgcolor="#c8c8c8"><%
	if(overFlow){
		
		%><div class="errorText">Note: Some of your information is too large to fit within the template and is being cut off. Please change the text or call 888-777-9832 for assistance:<ul class="errorText"><%
		for (int zz=0; zz<vOverflowFields.size(); zz=zz+1) {
			%><li class="errorText"><%=vOverflowFields.get(zz).toString()%></li><%
		}
		%></ul></div><%
	}%><table width=100% height=100% cellpadding="0" cellspacing="0" border="0"><tr><td align="center" valign="top"><span class='subtitle'><i> Preview image is an approximation, click image to view actual proof.<br><%=((pageButtons.equals(""))?"":pageButtons+"<br>")%><a href="<%=tempUrlPath+pdfFileName.replace(".pdf","_proof.pdf")%>" target='_blank' ><img src="<%=tempUrlPath +imageFileName%>" border=1 ></a></td></tr></table>
	<script>
	<%=((overFlow)?"parent.hideContinue()":"parent.showContinue()")%>;
	</script>
	</body><%
}%></html><%
}else{
%><html><head>
<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
<META HTTP-EQUIV="Expires" CONTENT="-1">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<link rel="stylesheet" href="/styles/marcomet.css" type="text/css">
<title>Preview</title></head><body bgcolor="#c8c8c8">
</head><body><div class=subtitle>ERROR: The template file for this product does not exist -- please report this error to customer service.</div></body></html>
<%

}
}%>