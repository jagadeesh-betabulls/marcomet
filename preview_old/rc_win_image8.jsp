<%@page import="java.util.*,javax.servlet.*, com.marcomet.catalog.*, com.pdflib.*,org.jpedal.*,java.io.*,javax.imageio.*,java.awt.Graphics,java.awt.Image,java.awt.image.*" %><%

   /* Template for generating a pdf of the Wingate buiness card
    *
    * NOTE: Must be used with a pdf preview template defined on the product
    */
    
    ProjectObject po = (ProjectObject)session.getAttribute("currentProject");
	JobObject jo = po.getCurrentJob();
    int jobId=jo.getId();
    
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
    
    Random generator = new Random();
    int r = generator.nextInt();
	String pdfPreviewTemplate=((request.getParameter("pdfPreviewTemplate")==null)?"":request.getParameter("pdfPreviewTemplate"));
	String searchpath = "/home/webadmin/marcomet-test.virtual.vps-host.net/html/data";
    String tempPath = "/home/webadmin/marcomet-test.virtual.vps-host.net/html/tempFiles/";  
    String tempUrlPath = "/tempFiles";   
    String filePath = "/home/webadmin/marcomet-test.virtual.vps-host.net/html/data/bc_win.pdf";
   	String imageFileName="rcwin"+(String)session.getAttribute("contactId")+"_"+r+".jpg";
   	String pdfFileName="rcwin"+(String)session.getAttribute("contactId")+"_"+r+".pdf";
   	String imageBlockFileName="rcwin_image_1_"+(String)session.getAttribute("contactId")+".jpg";
   	String imageBlock="image_1";


if (pdfPreviewTemplate.equals("")){
	%><html><head><title>Template Not Found</title>
<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
<META HTTP-EQUIV="Expires" CONTENT="-1">
</head><body><h1>Error: No Template Defined for this product...</h1></body></html><%
}else{
	String name=((request.getParameter("^2036^10900")==null)?"":request.getParameter("^2036^10900"));
	String title=((request.getParameter("^2034^10892")==null)?"":request.getParameter("^2034^10892"));
	String propertyName=((request.getParameter("^6006^10893")==null)?"":request.getParameter("^6006^10893"));
	String address1=((request.getParameter("^1779^10894")==null)?"":request.getParameter("^1779^10894"));
	
	String city=((request.getParameter("^1781^10896")==null)?"":request.getParameter("^1781^10896"));
	String address_city=((request.getParameter("^1781^10896")==null)?"":request.getParameter("^1781^10896"));
	
	String state=((request.getParameter("state")==null)?"":request.getParameter("state"));
	String zip=((request.getParameter("zip")==null)?"":request.getParameter("zip"));
	String phone1=((request.getParameter("phone1")==null)?"":request.getParameter("phone1"));
	String phone=((request.getParameter("^1784^10897")==null)?"":request.getParameter("^1784^10897"));
		
	String phone2=((request.getParameter("phone2")==null)?"":request.getParameter("phone2"));
	String phone3=((request.getParameter("phone3")==null)?"":request.getParameter("phone3"));
	String phoneext=((request.getParameter("phoneext")==null)?"":request.getParameter("phoneext"));
	String fax1=((request.getParameter("fax1")==null)?"":request.getParameter("fax1"));
	String fax=((request.getParameter("^1785^10898")==null)?"":request.getParameter("^1785^10898"));
	String telFax=((phone.equals(""))?"":"Tel: "+phone)+((fax.equals("") || phone.equals(""))?"":"   ")+((fax.equals(""))?"":"Fax: "+fax);
	String fax2=((request.getParameter("fax2")==null)?"":request.getParameter("fax2"));
	String fax3=((request.getParameter("fax3")==null)?"":request.getParameter("fax3"));
	String faxext=((request.getParameter("faxext")==null)?"":request.getParameter("faxext"));
	String email=((request.getParameter("^1786^10899")==null)?"":request.getParameter("^1786^10899"));
	String labelEmail=((email.equals(""))?"":"Email: "+email);
	String webURL=((request.getParameter("^1787^10971")==null)?"":request.getParameter("^1787^10971"));
	String property_address_city_state_zip=propertyName+((propertyName.equals(""))?"":", ")+address1+((address1.equals(""))?"":", ")+city+((state.equals(""))?"":", ")+state+((zip.equals(""))?"":", ")+zip;

    int font;
    pdflib p = null ;
    int i, blockcontainer, pdipage;
    String infile = pdfPreviewTemplate;
    /* This is where font/image/PDF input files live. Adjust as necessary.
     *
     * Note that this directory must also contain the LuciduxSans font
     * outline and metrics files.
     */

    String[][] data = {
	{ "name.upper",                   name.toUpperCase() },
	{ "business.title.upper",         title.toUpperCase() },
	{ "name",                   name },
	{ "business.title",         title },
	{ "business.address.line1", address1 },
	{ "business.property.address.city.state.zip", property_address_city_state_zip },
	{ "business.address.city",  address_city },
	{ "business.telephone.voice", phone },//phone1+"."+phone2+"."+phone3+ ((phoneext.equals(""))?"":" "+phoneext) },
	{ "business.telephone.fax", fax }, //fax1+"."+fax2+"."+fax3+ ((faxext.equals(""))?"":" "+faxext) },
	{ "business.tel.fax",         telFax },
	{ "business.email",         email },
	{ "business.label.email",   labelEmail },
	{ "business.homepage",      webURL },
	};

    byte[] buf;
    ServletOutputStream output;

    p = new pdflib();
//    p.set_parameter("licensefile", "/home/webadmin/marcomet-test.virtual.vps-host.net/html/data/licensekeys.txt");
    // Generate a PDF in memory; insert a file name to create PDF on disk
    if (p.begin_document(tempPath+pdfFileName,"") == -1) {
        System.err.println("Error: " + p.get_errmsg());
	System.exit(1);
    }

    /* Set the search path for fonts and PDF files */
    p.set_parameter("SearchPath", searchpath);
    p.set_parameter("resourcefile", "/home/webadmin/marcomet-test.virtual.vps-host.net/html/data/pdflib.upr");

    p.set_info("Creator", "MarComet");
    p.set_info("Author", "MarComet");
    p.set_info("Title","Business Card");

    blockcontainer = p.open_pdi(infile, "", 0);
    if (blockcontainer == -1) {
        System.err.println("Error: " + p.get_errmsg());
	System.exit(1);
    }

    pdipage = p.open_pdi_page(blockcontainer, 1, "");
    if (pdipage == -1) {
        System.err.println("Error: " + p.get_errmsg());
	System.exit(1);
    }

    p.begin_page_ext(20, 20, "");              // dummy page size

    // This will adjust the page size to the block container's size.
    p.fit_pdi_page(pdipage, 0, 0, "adjustpage");

    // Fill all text blocks with dynamic data 
    for (i = 0; i < (int) data.length; i++) {
	if (p.fill_textblock(pdipage, data[i][0], data[i][1],
		"embedding encoding=unicode") == -1) {
	    System.err.println("Warning: " + p.get_errmsg());
	}
    }
    
    //Fill image blocks (if any) with images in the tempdirectory
    
    int impImage=p.load_image("auto", tempPath+imageBlockFileName,""); 
    if(p.fill_imageblock(pdipage, "image_1", impImage,"")==-1){
    	    System.err.println("Warning: " + p.get_errmsg());
    } 
    
    p.save();
    p.restore();
    p.end_page_ext("");                        // close page
    p.close_pdi_page(pdipage);
    p.end_document("");                           // close PDF document
    p.close_pdi(blockcontainer);
//    buf = p.get_buffer();
    
	PdfDecoder decoder = new PdfDecoder();
	decoder.openPdfFile(tempPath+pdfFileName);
	if (decoder.isFileViewable()){				
		//just grab the first page, and render it as an image.
		decoder.setPageParameters(2,1);				
		BufferedImage thisImage = decoder.getPageAsImage(1);
//		Graphics g = thisImage.getGraphics();
  //      int resizeWidth = 0;
    //    int resizeHeight = 0;
      //  resizeHeight = 400;
        //resizeWidth = (thisImage.getWidth() * resizeHeight) / thisImage.getHeight();
       // BufferedImage resizedImage = new BufferedImage(resizeWidth, resizeHeight, BufferedImage.TYPE_INT_RGB);
       // resizedImage.createGraphics().drawImage(thisImage, 0, 0, resizeWidth, resizeHeight, null);

		File fileToSave = new File(tempPath + imageFileName);
		ImageIO.write((RenderedImage)thisImage,"jpg", fileToSave);
		session.setAttribute("lastImage_"+jobId,fileToSave);
		session.setAttribute("lastPDFImage_"+jobId,tempPath+pdfFileName);
	}
}
  jo.setPreBuiltFile(tempPath+imageFileName);
  jo.setPreBuiltFileURL(tempUrlPath+"/"+imageFileName);
  jo.setPreBuiltPDFFile(tempPath+pdfFileName);
  jo.setPreBuiltPDFFileURL(tempUrlPath+"/"+pdfFileName);

%><html><head>
<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
<META HTTP-EQUIV="Expires" CONTENT="-1">
<title>Preview</title></head><body bgcolor="gray"><table width=100% height=100% cellpadding="0" cellspacing="0" border="0"><tr><td align="center" valign="middle"><span class='subtitle'><i> Click image for full-size preview<br>NOTE: Colors in preview image are approximate; final printed product colors may vary.</i></span><br><a href="<%=tempUrlPath+"/" +pdfFileName%>" target='_blank' ><img src="<%=tempUrlPath+"/" +imageFileName%>" border=1 ></a></td></tr></table></body><HEAD>
<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
<META HTTP-EQUIV="Expires" CONTENT="-1">
</HEAD></html>
