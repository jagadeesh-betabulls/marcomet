package com.marcomet.files;

/**********************************************************************
Description:	This class contains all the methods needed by the file 
				manager.
**********************************************************************/

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.DecimalFormat;
import java.util.Enumeration;
import java.util.ResourceBundle;
import java.util.StringTokenizer;
import java.util.Vector;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.marcomet.environment.SiteHostSettings;
import com.marcomet.jdbc.DBConnect;
import com.marcomet.mail.JavaMailer1;
import com.marcomet.tools.Indexer;
import com.marcomet.tools.StringTool;
import com.marcomet.users.security.RoleResolver;

public class FileManipulator {

	private String transfers = "";
	private int companyId = 0;
	private int userid = 0;

	public FileManipulator() {
		ResourceBundle bundle = ResourceBundle.getBundle("com.marcomet.marcomet");
		transfers = bundle.getString("transfers");
	}
	public void associateFiles(HttpServletRequest request, HttpServletResponse response, MultipartRequest mr) throws ServletException, Exception {
		
		Connection conn = DBConnect.getConnection();

		try {

			int companyId = Integer.parseInt((String)request.getSession().getAttribute("companyId"));
			
			String[] associatedFileIds;
			String category;
			String jobId;
			String projectId;
			if (mr == null) {
				associatedFileIds = request.getParameterValues("associatedFileList");
				category = request.getParameter("category");
				jobId = request.getParameter("jobId");
				
				projectId = request.getParameter("projectId");
			} else {
			    associatedFileIds = mr.getParameterValues("associatedFileList");
				category = "Working";
				jobId = mr.getParameter("jobId");
				projectId = mr.getParameter("projectId");
			}

			if (associatedFileIds != null) {

				String getInfoQuery = "select * from file_meta_data where id = ?";
				String insertInfoQuery = "insert into file_meta_data (company_id, job_id, file_name, file_type, file_size, path, description, comments, user_id, project_id, status, category) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

				PreparedStatement getInfo = conn.prepareStatement(getInfoQuery);
				PreparedStatement insertInfo = conn.prepareStatement(insertInfoQuery);
				
				for(int i = 0; i < associatedFileIds.length; i++) {
					String associatedFileId = associatedFileIds[i];
					getInfo.clearParameters();
					getInfo.setString(1, associatedFileId);
					ResultSet rsInfo = getInfo.executeQuery();
					while (rsInfo.next()) {
					
						String status = "";
						if (category.equals("Comp")) {
							status = "Submitted";
						} else {
							status = "n/a";
						}
				
						insertInfo.clearParameters();
						insertInfo.setString(1, rsInfo.getString("company_id"));
						insertInfo.setString(2, jobId);
						insertInfo.setString(3, rsInfo.getString("file_name"));
						insertInfo.setString(4, rsInfo.getString("file_type"));
						insertInfo.setString(5, rsInfo.getString("file_size"));
						insertInfo.setString(6, rsInfo.getString("path"));
						insertInfo.setString(7, rsInfo.getString("description"));
						insertInfo.setString(8, rsInfo.getString("comments"));
						insertInfo.setString(9, rsInfo.getString("user_id"));
						insertInfo.setString(10, projectId);
						insertInfo.setString(11, status);
						insertInfo.setString(12, category);
						insertInfo.execute();
					}
				}
		 
			}
		}
		
		catch(Exception ex) {
			throw new ServletException("FileManipulator associateFiles exception: " + ex.getMessage());
		} finally {
			try { conn.close(); } catch (Exception x ) {}
		}

	} // associateFiles
	public void downloadArchive(String[] fileIds, HttpServletRequest req, HttpServletResponse res) throws ServletException {
		
		Connection conn = null;
		try {
			conn = DBConnect.getConnection();
			String zipName = "archive.zip";
			ServletOutputStream outStream = res.getOutputStream();
			res.setContentType("application/zip");
			res.setHeader("Content-Disposition", "inline; filename=\"" + zipName + "\"");
				
			byte[] buffer = new byte[2 * 1024 * 1024];
			int bytes_read;
			
			ZipOutputStream zos = new ZipOutputStream(outStream);

			Statement st = conn.createStatement();
			String companyId = "";
			String fileName = "";
				
			for(int i = 0; i < fileIds.length; i++) {

				ResultSet rs = st.executeQuery("select file_name, company_id from file_meta_data where id = " + fileIds[i]);
				while (rs.next()) {
					companyId = rs.getString("company_id");
					fileName = rs.getString("file_name");
				}	

				File file = new File(transfers + companyId + File.separatorChar + fileName);
				FileInputStream in = new FileInputStream(file);
				ZipEntry entry = new ZipEntry(fileName);
				zos.putNextEntry(entry);

				while((bytes_read = in.read(buffer))!=-1)zos.write(buffer,0,bytes_read);
				in.close();
			}
			
			zos.close();

		} catch(Exception ex) {
			throw new ServletException("FileManipulator downloadArchive exception: " + ex.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }			
		}

	} // downloadArchive
	public void downloadFile(String[] fileNames, HttpServletRequest req, HttpServletResponse res) throws ServletException {		

		try {

			int companyId = Integer.parseInt((String)req.getSession().getAttribute("companyId"));
			
			String fileName = fileNames[0];
			File file = new File(transfers + companyId + File.separatorChar + fileName);

			//res.setContentType("application/octet-stream");
			res.setContentType("application/unknown");
			res.setHeader("Content-Disposition", "inline; filename=\"" + file.getName() + "\"");
			//res.setHeader("Content-Disposition", "attachment; filename=\"" + file.getName() + "\"");
			
			PrintWriter outFile = res.getWriter();
	  		FileReader theFile = new FileReader(file);
	  		int i;
	  		while ((i = theFile.read()) != -1) {
	   			outFile.print((char) i);
	  		}
	  		theFile.close();

		}

		catch(Exception ex) {
			throw new ServletException("FileManipulator downloadFile exception: " + ex.getMessage());
		}

	} // downloadFile
	public FileMetaDataContainer extractAttributes(MultipartRequest mr, int userid, int fileNumber, int groupId) throws Exception {

		FileMetaDataContainer container = null;
		
		try {

			if (mr.getFile("file" + fileNumber) != null) {

				String description = (String)mr.getParameter("description" + fileNumber);
				String comments = (String) mr.getParameter("comments" + fileNumber);
				int jobid = Integer.parseInt((String)mr.getParameter("jobId"));
				int companyId = Integer.parseInt((String)mr.getParameter("companyId"));
				String filePath = (String)mr.getParameter("filePath");

				File fileObject = mr.getFile("file" + fileNumber);
				UploadedFile uf = mr.getUploadedFile("file" + fileNumber);
				
				String fileName = fileObject.getName();

				String newFileName = "";
						
				try {
					newFileName = mr.getParameter("newFileName");
					if (((String)mr.getParameter("write")).equals("rename"))
						fileName = newFileName;	
				} catch(Exception ex) {}

				//double fileSize = fileObject.length();
				long fileSize = uf.getFileSize();				
				String fileExtension = "";
			
				StringTokenizer st = new StringTokenizer(fileName, ".");
				while ( st.hasMoreElements() ) {
					fileExtension = (String)st.nextElement();
				}

				String status = "";
				try {
					status = mr.getParameter("status");
				} catch(Exception ex) {}
				if (status == null)
					status = "n/a";
			
				int projectid;
				try {
					projectid = Integer.parseInt(mr.getParameter("projectId"));
				} catch(Exception ex) {
					projectid = Integer.parseInt((String)mr.getParameter("jobId"));
				}

				String category = "";
				try {
					category = mr.getParameter("category");
				} catch(Exception ex) {}
				if (category == null) 
					category = "Working";
			
				container = new FileMetaDataContainer(userid, companyId, jobid, projectid, fileName, fileExtension, fileSize, filePath, description, comments, status, category, groupId);

			}

		} catch (Exception ex) {
			throw new Exception("FileManipulator.extractAttributes error: " + ex.getMessage());
		}
		return container;
	
	}
	public int getNextGroupId() throws SQLException{

		int groupId = 0;
		Statement st = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			st = conn.createStatement();
			//lock table
			st.execute("LOCK TABLES file_material_groups WRITE");	
					
			String query = "select IF( max(id) IS NULL, 0, max(id))+1  from file_material_groups;";
			ResultSet rs = st.executeQuery(query);
			if (rs.next())
				groupId = rs.getInt(1);

			query = "insert into file_material_groups(id) values (?)";
			PreparedStatement insert = conn.prepareStatement(query);
			insert.clearParameters();
			insert.setInt(1,groupId);
			insert.execute();
	
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { st.execute("UNLOCK TABLES"); } catch ( Exception x) { st = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
			
		return groupId;	

	}
	public void insertMetaData(FileMetaDataContainer container, String queryType) throws SQLException {

		Statement st = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			st = conn.createStatement();
			String fileName = container.getFileName();
			String fileExtension = container.getFileExtension();
			String description = container.getDescription();
			String comments = container.getComments();
			double fileSize = container.getFileSize();
			String filePath = container.getFilePath();
			int companyId = container.getCompanyid();
			int jobId = container.getJobid();
			int userId = container.getUserid();
			String category = container.getCategory();
			String status = container.getStatus();
			String source = container.getSource();
			int projectId = container.getProjectid();
			int groupId = container.getGroupid();

			if (projectId == jobId) {
				String getProject = "select project_id from jobs where id = " + jobId;
				ResultSet res = st.executeQuery(getProject);
				while (res.next()) {
					projectId = res.getInt("project_id");
				}
			}		

			String query0 = "insert into file_meta_data (user_id, company_id, job_id, file_name, file_type, file_size, path, description, comments, project_id, status, category, group_id,source) values (?,?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
			String query1 = "update file_meta_data set user_id = ?, company_id = ?, job_id = ?, file_name = ?, file_type = ?, file_size = ?, path = ?, description = ?, comments = ?, project_id = ?, status = ? where company_id = ? and path = ? and file_name = ?";

			PreparedStatement insert = conn.prepareStatement(query0);
			PreparedStatement update = conn.prepareStatement(query1);

			String query = "";
			if (queryType.equals("insert")) {
				insert.clearParameters();
				insert.setInt(1, userId);
				insert.setInt(2, companyId);
				insert.setInt(3, jobId);
				insert.setString(4, fileName);
				insert.setString(5, fileExtension);
				insert.setDouble(6, fileSize);
				insert.setString(7, filePath);
				insert.setString(8, description);
				insert.setString(9, comments);
				insert.setInt(10, projectId);
				insert.setString(11, status);
				insert.setString(12, category);
				insert.setInt(13, groupId);
				insert.setString(14, ((source==null  || source.equals(""))?"0":source));
				insert.execute();
			} else {
				update.clearParameters();
				update.setInt(1, userId);
				update.setInt(2, companyId);
				update.setInt(3, jobId);
				update.setString(4, fileName);
				update.setString(5, fileExtension);
				update.setDouble(6, fileSize);
				update.setString(7, filePath);
				update.setString(8, description);
				update.setString(9, comments);
				update.setInt(10, projectId);
				update.setString(11, status);
				update.setInt(12, companyId);
				update.setString(13, filePath);
				update.setString(14, fileName);
				update.execute();
			}
			
		} catch(SQLException ex) {
			throw new SQLException("FileManipulator.insertMetaData error: " + ex.getMessage());
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { st.close(); } catch ( Exception x) { st = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	
	} // insertMetaData
	public void moveCommerceFiles(HttpServletRequest request, MultipartRequest mr, File dir, File tempDir) throws IOException {

		String fileName = "";
		int number = mr.getNumberOfFiles();
		boolean newDir = false;
		Statement st = null;
		Connection conn = null; 
		
		try {
			//If the file is being uploaded by a vendor, figure out which directory to upload to
			if(request.getSession().getAttribute("roles")!= null && ((RoleResolver)request.getSession().getAttribute("roles")).isVendor()){
				String jobId = mr.getParameter("jobId");
				conn = DBConnect.getConnection();
				st = conn.createStatement();
				ResultSet rs = st.executeQuery("SELECT o.buyer_company_id FROM orders o, projects p, jobs j WHERE o.id = p.order_id AND p.id = j.project_id AND j.id = " + jobId);
				while (rs.next()) {
					companyId = Integer.parseInt(rs.getString("buyer_company_id"));
				}
				dir = new File(transfers + companyId + File.separatorChar);
				newDir = true;
			}
		} catch(Exception ex) {
			throw new IOException("uh-oh " + ex.getMessage());
		} finally {
			try { st.close(); } catch ( Exception x) { st = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

		Vector v1 = new Vector();
		v1.addElement(dir.getAbsolutePath());
		mr.setParameter("filePath", v1);

		Vector v2 = new Vector();
		v2.addElement(new Integer(companyId).toString());
		mr.setParameter("companyId", v2);

		for (int i = 0; i < number; i++) {

			if (newDir == true) {
				if (!dir.isDirectory()) {
					dir.mkdir();
				}
				UploadedFile fileToBeReplaced = (UploadedFile)mr.getUploadedFile("file"+i);
				String newFileName = fileToBeReplaced.getFilesystemName();
				String contentType = fileToBeReplaced.getContentType();
				long fileSize = fileToBeReplaced.getFileSize();

				mr.putFile("file" + i, new UploadedFile(dir.toString(), newFileName, contentType, fileSize));
			}

			fileName = mr.getFileNameByVectorPosition(i);
			
			int available = 0;
			try {
				File file = new File(dir, fileName);
				FileInputStream fip = new FileInputStream(file);
				available = fip.available();
			} catch(Exception ex) {}
			
			String write = "";
			try {
				write = mr.getParameter("write");
			} catch (Exception ex) {}

			if (((write == null) || (write.equals(""))) && (available != 0)) {
				throw new IOException("exists");
			}

			if ((write == null) || (write.equals("")) || (write.equals("replace"))) {

				File fromFile = new File(tempDir, fileName);
				File toFile = new File(dir, fileName);
				FileInputStream fileIn = new FileInputStream(fromFile);
				FileOutputStream fileOut = new FileOutputStream(toFile);


				try {
					byte b[] = new byte[4096];
					int length;
					while ((length = fileIn.read(b)) != -1) {
						fileOut.write(b, 0, length);
					}

				} catch(IOException ex) {
					throw new IOException("Error reading/writing.");
				}

				fileOut.close();
				fileIn.close();

				boolean deleted = fromFile.delete();

			} else if (write.equals("rename")) {

				String newName = "";
				try {
					newName = mr.getParameter("newFileName");
				} catch (Exception ex) {}

				File fromFile = new File(tempDir, fileName);
				File toFile = new File(dir, newName);
				FileInputStream fileIn = new FileInputStream(fromFile);
				FileOutputStream fileOut = new FileOutputStream(toFile);

				try {
					byte b[] = new byte[4096];
					int length;
					while ((length = fileIn.read(b)) != -1) {
						fileOut.write(b, 0, length);
					}

				} catch(IOException ex) {
					throw new IOException("Error reading/writing.");
				}

				fileOut.close();
				fileIn.close();

				boolean deleted = fromFile.delete();

			}
		}

	}
	public void processEmail(HttpServletRequest request, MultipartRequest mr, String filePath, Vector fileVector) throws Exception {

		StringTool st = new StringTool();                 //added to remove blanks from links.
		try {

			String body = "";
				body += "Reference";
				body += "\nJob Number: " + mr.getParameter("jobId");
				body += "\nOrder Number: " + mr.getParameter("orderNumber");
				body += "\nContact Id: " + userid;

				body += "\n\nMessage:";
				body += "\n------------------------------------------------";
				body += "\n   " + mr.getParameter("message");

				body += "\n\nAttachments:";
				body += "\n------------------------------------------------";

			String fileName;
			String fileExtension;
			String description;
			double fileSize;
			FileMetaDataContainer container;
			
			int attachments = Integer.parseInt(mr.getParameter("emailFileTotal"));
			String attachmentName = "";
			String attachmentDescription = "";
			for (int i=0; i < attachments; i++) {
				attachmentName = mr.getParameter("emailFileName" + i);
				attachmentDescription = mr.getParameter("emailFileDescription" + i);
				body += "\n   Description: " + attachmentDescription;
				body += "\n      ";
				body += "<a href=\"http://" + st.replaceSubstring(((SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getDomainName() + "/" + filePath + attachmentName," ","%20") + "\">http://" + ((SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getDomainName() + "/" + filePath + attachmentName + "</a>"; 

			}
			
			for (Enumeration metaFiles = fileVector.elements(); metaFiles.hasMoreElements(); ) {
				container = (FileMetaDataContainer) metaFiles.nextElement();
				fileName = container.getFileName();
				fileExtension = container.getFileExtension();
				fileSize = container.getFileSize();
				description = container.getDescription();

				String tag = "bytes";
				if (fileSize > 1024) {
					fileSize = fileSize / 1024;
					tag = "Kb";
				} else if (fileSize > 1024*1024) {
					fileSize = fileSize / 1024*1024;
					tag = "Mb";
				}

				DecimalFormat precisionTwo = new DecimalFormat("0.00");
				String formattedFileSize = precisionTwo.format(fileSize);


				body += "\n   Description: " + description;
				body += "\n      ";
				body += "<a href=\"http://" + st.replaceSubstring(((SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getDomainName() + "/" + filePath + fileName," ","%20") + "\">http://" + ((SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getDomainName() + "/" + filePath + fileName+ "</a>   (" + formattedFileSize + " " + tag + ")";
			}
			
			//SimpleMailer sm = new SimpleMailer();
			JavaMailer1 sm = new JavaMailer1();
			sm.setTo(mr.getParameter("to"));
			sm.setFrom(mr.getParameter("from"));
			sm.setSubject(mr.getParameter("subject"));
			sm.setBody("<pre>"+body+"</pre>");                       //***** for quick fixing message not ready for html formating
			sm.send();

		} catch(Exception ex) {
			throw new Exception("Exception in handleEmail: " + ex.getMessage());
		}
		
	} // processEmail
	public void swapCompany(int oldCompanyId, int newCompanyId) throws FileNotFoundException, SQLException, IOException {

		Statement st = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			st = conn.createStatement();

			String oldCompanyDir = transfers + File.separatorChar + oldCompanyId + File.separatorChar;
			String newCompanyDir = transfers + File.separatorChar + newCompanyId + File.separatorChar;

			File oldCompanyDirectory = new File(oldCompanyDir);
			File oldCompanyTemp = new File(oldCompanyDir + File.separatorChar + "temp");

			String[] list	= oldCompanyDirectory.list(new DirectoryFilter());

			File dir = new File(newCompanyDir);
			if (!dir.isDirectory()) {
				dir.mkdir();
			}

			String fileName = "";

			for (int i=0; i<list.length; i++) {
				fileName = list[i].toString();

				File fromFile = new File(oldCompanyDir, fileName);
				
				if (!fromFile.isDirectory()) {
					File toFile = new File(newCompanyDir, fileName);
					FileInputStream fileIn = new FileInputStream(fromFile);
					FileOutputStream fileOut = new FileOutputStream(toFile);

					try {
						byte b[] = new byte[4096];
						int length;
						while ((length = fileIn.read(b)) != -1) {
							fileOut.write(b, 0, length);
						}
						
					} catch(IOException ex) {
						throw new IOException("Error reading/writing " + fileName);
					}

					fileOut.close();
					fileIn.close();
					
					fromFile.delete();
				}
			}

			oldCompanyTemp.delete();
			oldCompanyDirectory.delete();
			
		} catch (FileNotFoundException ex) {
			throw new FileNotFoundException("FileManipulator.swapCompany " + ex.getMessage());
		} catch (SQLException ex) {
			throw new SQLException("FileManipulator.swapCompany " + ex.getMessage());
		} catch (IOException ex) {
			throw new IOException("FileManipulator.swapCompany " + ex.getMessage());
		} catch (Exception e) {
			throw new IOException("FileManipulator.swapCompany " + e.getMessage());
		} finally {
			try { st.close(); } catch ( Exception x) { st = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	
	} // swapCompany
	
	public void insertCustomMetaData(FileMetaDataContainer container, String xtableName,String xidField,String xidFieldValue, String xfileNameField,String xfileDirectory) throws SQLException {

		Statement st = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			st = conn.createStatement();
			String fileName = container.getFileName();
			String query = "update "+xtableName+" set "+xfileNameField+"=? where "+xidField+"='"+xidFieldValue+"'";

			PreparedStatement update = conn.prepareStatement(query);
			update.clearParameters();
			update.setString(1, xfileDirectory+"/"+fileName);
			update.execute();
			
		} catch(SQLException ex) {
			throw new SQLException("FileManipulator.insertCustomMetaData error: " + ex.getMessage());
		} catch (Exception e) {
			throw new SQLException("FileManipulator.insertCustomMetaData error: " + e.getMessage());
		} finally {
			try { st.close(); } catch ( Exception x) { st = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	
	} // insertCustomMetaData
	
	
	public MultipartRequest uploadFile(HttpServletRequest request, HttpServletResponse res) throws ServletException, IOException {
	
		MultipartRequest mr = null;

		try {
			String fileDirectoryStr = ((request.getSession().getAttribute("tempUpload")==null)?"":request.getSession().getAttribute("tempUpload")).toString();
			request.getSession().removeAttribute("tempUpload");
			String tempId = "";
			boolean loggedIn = true;
			try {
				userid = Integer.parseInt((String)request.getSession().getAttribute("contactId"));
				companyId = Integer.parseInt((String)request.getSession().getAttribute("companyId"));
			} catch(Exception ex) {
				//The user is not yet logged in
				tempId = new Integer(Indexer.getNextId("temp_user")).toString();
				companyId = Integer.parseInt(tempId);
				userid = companyId;
				loggedIn = false;
			}

			ResourceBundle bundle = ResourceBundle.getBundle("com.marcomet.marcomet");
			String transfers = bundle.getString("transfers");
			String saveDirectory = transfers + companyId + File.separatorChar;
			String tempDirectory = saveDirectory + File.separatorChar + "temp";
			if (!(fileDirectoryStr.equals(""))){
				String transfersPrefix = bundle.getString("transfersPrefix");
				saveDirectory = transfersPrefix + fileDirectoryStr + File.separatorChar;
				tempDirectory = saveDirectory + File.separatorChar + "temp";			
			}

			// Save the dir
			File dir = new File(saveDirectory);
			File tempDir = new File(tempDirectory);

			if (!dir.isDirectory()) {
				dir.mkdir();
			}
			if (!tempDir.isDirectory()) {
				tempDir.mkdir();
			}

			if (!tempDir.canWrite())
			  throw new IllegalArgumentException("Not writable: " + tempDir.toString());

			//Upload the file to the temp folder
			mr = new MultipartRequest(request, 10 * 1024 * 1024, tempDir);
			//Move the file to th ereal directory as needed
			this.moveCommerceFiles(request, mr, dir, tempDir);

			int number = mr.getNumberOfFiles();

			if (!loggedIn && number > 0) {
				Vector companies = (Vector)request.getSession().getAttribute("tempCompanyVector");
				if (companies == null) 
					companies = new Vector();
					
				companies.addElement(tempId);
				request.getSession().setAttribute("tempCompanyVector", companies);
			}
			
			Vector fileVector = new Vector();
			
			int groupId = this.getNextGroupId();			
			mr.setParameter("groupId", (new Integer(groupId)).toString());

			for (int i=0; i<number; i++) {
				FileMetaDataContainer container = this.extractAttributes(mr, userid, i, groupId);
				if (container != null) {
					String action = "";
					String queryType = "insert";
					try {
						action = mr.getParameter("write");
						if (action.equals("replace")) {
							queryType = "update";
						} else {
							queryType = "insert";
						}
					} catch(Exception ex) {}
					if (mr.getParameter("customMetadata")==null){
						this.insertMetaData(container, queryType);
					}else{
							String tableName = mr.getParameter("tableName");
							String idField = mr.getParameter("idField");
							String idFieldValue = mr.getParameter("idFieldValue");
							String fileNameField = mr.getParameter("fileNameField");	
							String fileDirectory = mr.getParameter("fileDirectory");
						this.insertCustomMetaData(container, tableName,idField,idFieldValue,fileNameField,fileDirectory);
					}
					fileVector.add(container);

				}

			}

			String email = mr.getParameter("email");
			if (email == null) {
				email = "";
			}

			if (!email.equals("")) {

				String path = "transfers/" + companyId + File.separatorChar;
				this.processEmail(request, mr, path, fileVector);

			}

		} catch(Exception ex) {
			throw new ServletException("FileManipulator uploadFile exception: " + ex.getMessage());
		}

		return mr;
		
	} // uploadFile
} // FileManipulator
