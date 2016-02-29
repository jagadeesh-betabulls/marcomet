<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="com.marcomet.mail.*,com.marcomet.files.*,com.marcomet.jdbc.*,java.util.*,java.io.*,java.sql.*;" %>
<%
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
	ResourceBundle bundle = ResourceBundle.getBundle("com.marcomet.marcomet");
	String transfers = bundle.getString("transfers");
	String host = bundle.getString("host");
	
	int userid = Integer.parseInt((String)session.getAttribute("Login"));    
	int companyid = Integer.parseInt((String)session.getAttribute("companyid"));
	
	String filePath = transfers + companyid + File.separatorChar;
	MultipartRequest mr = new MultipartRequest(request, filePath, 5242880);
	Enumeration formFileNames = mr.getFileNames();

	String body = "";
		body += "Reference";
		body += "\nJob Number: " + mr.getParameter("jobNumber");
		body += "\nOrder Number: " + mr.getParameter("orderNumber");
		body += "\nContact Id: " + session.getAttribute("Login");
		body += "\nMessage:\n\n" + mr.getParameter("message");
		body += "\n\nAttachments:\n";

	// Get and prcocess the file attributes
	String fileName = "none";
	String fileFormName = "";
	String fileExtension = "xxx";
	File fileObject = null;
	float fileSize = 0;
	Vector fileVector = new Vector();
	FileMetaDataContainer container = null;
	
	for (; formFileNames.hasMoreElements() ;) {
		fileFormName = (String)formFileNames.nextElement();
		fileObject = mr.getFile(fileFormName);
		if (fileObject != null) {
			fileName = fileObject.getName();
			fileSize = fileObject.length() / 1000;
			StringTokenizer st = new StringTokenizer(fileName, ".");
			while ( st.hasMoreElements() ) {
				fileExtension = (String)st.nextElement();
			}
			container = new FileMetaDataContainer(fileName, fileExtension, fileSize, filePath);
			fileVector.add(container);
			body += "\nhttp://" + host + "/" + filePath + fileName + " (" + fileSize + " k)";
		}
	}
	
	SimpleMailer sm = new SimpleMailer();
	sm.setTo(mr.getParameter("to"));
	sm.setFrom(mr.getParameter("from"));
	sm.setSubject(mr.getParameter("subject"));
	sm.setBody(body);
	sm.send();

	
	for (Enumeration metaFiles = fileVector.elements(); metaFiles.hasMoreElements(); ) {
		container = (FileMetaDataContainer) metaFiles.nextElement();
		fileName = container.getFileName();
		fileExtension = container.getFileExtension();
		fileSize = container.getFileSize();
		filePath = container.getFilePath();
			
		String query = "insert into file_meta_data (companyid, jobid, file_name, file_type, file_size, path) ";
				query +=  "values (1, 1, '" + fileName + "', '" + fileExtension + "', " + fileSize + ", '" + filePath + "')";
		ResultSet rs = st.executeQuery(query);
	}
%>

<html>
<head>
  <title>Email Submitted</title>
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>  
<body class="Title">
<p>Email sent successfully. 
</body>
</html>