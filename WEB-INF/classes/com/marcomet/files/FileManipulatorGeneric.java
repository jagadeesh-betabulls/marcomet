package com.marcomet.files;

/**********************************************************************
Description:	This class contains all the methods needed by the file 
				manager.
**********************************************************************/

import java.io.File;
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ResourceBundle;
import java.util.StringTokenizer;
import java.util.Vector;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.marcomet.jdbc.DBConnect;


public class FileManipulatorGeneric {
	public FileManipulatorGeneric() {
		//Open the resource bundle file to get the default transfer directory, where the file will be uploaded to if no path is passed
		ResourceBundle bundle = ResourceBundle.getBundle("com.marcomet.marcomet");
		String transfers = bundle.getString("transfers");
	}
	public void associateFiles(HttpServletRequest request, HttpServletResponse response, MultipartRequest mr) throws ServletException {

	} // associateFiles
	public void downloadArchive(String filePath, String[] fileIds, HttpServletRequest req, HttpServletResponse res) throws ServletException, Exception {
		
		Connection conn = DBConnect.getConnection();
			
		try {

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

				ResultSet rs = st.executeQuery("select file_name from file_meta_data where id = " + fileIds[i]);
				while (rs.next()) {
					fileName = rs.getString("file_name");
				}	

				File file = new File(filePath + File.separatorChar + fileName);
				FileInputStream in = new FileInputStream(file);
				ZipEntry entry = new ZipEntry(fileName);
				zos.putNextEntry(entry);

				while((bytes_read = in.read(buffer))!=-1)zos.write(buffer,0,bytes_read);
				in.close();
			}
			
			zos.close();

		} catch(Exception ex) {
			throw new ServletException("FileManipulatorGeneric downloadArchive exception: " + ex.getMessage());
		} finally {
			try { conn.close(); } catch (Exception e) {}
		}

	} // downloadArchive
	public void downloadFile(String filePath, String[] fileNames, HttpServletRequest req, HttpServletResponse res) throws ServletException {		

		try {		
			String fileName = fileNames[0];
			File file = new File(filePath + File.separatorChar + fileName);

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
			throw new ServletException("FileManipulatorGeneric downloadFile exception: " + ex.getMessage());
		}

	} // downloadFile
	public FileGenericMetaDataContainer extractAttributes(MultipartRequest mr, int fileNumber) throws Exception {
//Extract the metadata for the file only here, will call another method to handle the item-specific metadata
		FileGenericMetaDataContainer container = null;
		try {
			String filePath = (String)mr.getParameter("filePath");
			String serverName = (String)mr.getParameter("serverName");
			String description = (String)mr.getParameter("description");						
			File fileObject = mr.getFile("file" + fileNumber);
			String fileName = fileObject.getName();
			String oldFileName = fileObject.getName();
			String oldPath = fileObject.getPath();
			String fileType = "";
			String relatedTable=((mr.getParameter("relatedTable")!=null)?mr.getParameter("relatedTable"):"");
			String relatedField=((mr.getParameter("relatedField")!=null)?mr.getParameter("relatedField"):"");
			String fileCategory=((mr.getParameter("fileCategory")!=null)?mr.getParameter("fileCategory"):"");															
			try {
				if (((String)mr.getParameter("write")).equals("rename"))
					fileName = mr.getParameter("newFileName");
			} catch(Exception ex) {}
			double fileSize = fileObject.length();
			
			StringTokenizer st = new StringTokenizer(fileName, ".");
			while ( st.hasMoreElements() ) {
				fileType = (String)st.nextElement();
			}	
			int locationTypeId=( (mr.getParameter("locationTypeId")==null)?1:Integer.parseInt(mr.getParameter("locationTypeId")) );
			int relatedId=( (mr.getParameter("relatedId")==null)?0:Integer.parseInt(mr.getParameter("relatedId")) );
			int roleId=( (mr.getParameter("roleId")==null)?0:Integer.parseInt(mr.getParameter("roleId")) );			
			int statusId=( (mr.getParameter("statusId")==null)?1:Integer.parseInt(mr.getParameter("statusId")) );			
			int companyId=( (mr.getParameter("companyId")==null)?1:Integer.parseInt(mr.getParameter("companyId")) );						
			String fileLocationURL=( (mr.getParameter("fileLocationURL")==null)?"":mr.getParameter("fileLocationURL") );
			container = new FileGenericMetaDataContainer();// ( fileName,  oldFileName,  oldPath,  fileType,  fileSize,  filePath,  serverName, locationTypeId,  fileLocationURL);
			container.fileName=fileName;
			container.oldFileName=oldFileName;
			container.oldPath=oldPath;
			container.fileExtension=fileType; 
			container.fileType=fileType; 			
			container.fileSize=fileSize;
			container.filePath=filePath;
			container.serverName=serverName;
			container.locationTypeId=locationTypeId;
			container.fileLocationURL=fileLocationURL;
			container.description=description;	
			container.relatedTable=relatedTable;
			container.relatedId=relatedId;
			container.relatedField=relatedField;
			container.roleId=roleId;
			container.statusId=statusId;
			container.companyId=companyId;						
			container.fileCategory=fileCategory;			
											
//if this file needs to update a field in the related table perform the update					

		} catch (Exception ex) {
			throw new Exception("FileManipulatorGeneric.extractAttributes error: " + ex.getMessage());
		}
		return container;
	
	}

	public int insertMetaData(FileGenericMetaDataContainer container, String queryType) throws SQLException {
		
		int fileId=0;		
		Statement st = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			st = conn.createStatement();
			String fileName = container.getFileName();
			String oldFileName = container.getFileName();			
			String fileExtension = container.getFileExtension();
			double fileSize = container.getFileSize();
			String oldPath = container.getFilePath();
			String filePath = container.getFilePath();			;
			String serverName = container.getServerName();			
			int locationTypeId=container.getLocationTypeId();
			int statusId=container.getStatusId();			
			String fileLocationURL= container.getFileLocationURL()+"/"+container.getFileName();
			String description= container.getDescription();			
			
			String idQuery = "select  (IF( max(id) IS NULL, 0, max(id))+1) as id from file_metadata";
			String query0 = "insert into file_metadata (id,server_name,file_name, file_type, file_size, path,location_type_id,file_location_url,description ) values (?,?, ?, ?, ?, ?, ?, ?,?)";
			String query1 = "update file_metadata set server_name=?,file_name=?, file_type=?, file_size=?, path=?,location_type_id=?,file_location_url=?  where path = ? and file_name = ?";
			String updateIdQuery = "select id from file_metadata  where path = ? and file_name = ?";
			String insertBridgeRecord="insert into file_bridge (file_id,related_id,related_table,role_id,file_category,status_id,company_id) values (?,?,?,?,?,?,?)";
			PreparedStatement insert = conn.prepareStatement(query0);
			PreparedStatement update = conn.prepareStatement(query1);
			PreparedStatement insertFileBridge = conn.prepareStatement(insertBridgeRecord);			

			if (queryType.equals("insert")) {
				PreparedStatement getId = conn.prepareStatement(idQuery);
				ResultSet rsId=getId.executeQuery();

				if (rsId.next()){
					fileId=rsId.getInt("id"); 
				}
				String query = "";				
				insert.clearParameters();
				insert.setInt(1,fileId);
				insert.setString(2, serverName);
				insert.setString(3, fileName);
				insert.setString(4, fileExtension);
				insert.setDouble(5, fileSize);
				insert.setString(6, filePath);
				insert.setInt(7, locationTypeId);
				insert.setString(8, fileLocationURL);
				insert.setString(9, description);								
				insert.execute();		
//insert the bridge record
				insertFileBridge.setInt(1,fileId);
				insertFileBridge.setInt(2,container.getRelatedId());
				insertFileBridge.setString(3,container.getRelatedTable());	
				insertFileBridge.setInt(4,container.getRoleId());
				insertFileBridge.setString(5,container.getFileCategory());
				insertFileBridge.setInt(6,container.getStatusId());	
				insertFileBridge.setInt(7,container.getCompanyId());													
				insertFileBridge.execute();
//Update the related table with the new information if necessary
				if (container.getRelatedId() !=0 && container.getRelatedField()!=null && !container.getRelatedField().equals("na")){
					String updateRelatedTable="update "+container.getRelatedTable()+" set "+container.getRelatedField()+" = ? where id= ?";
					PreparedStatement updateRelated = conn.prepareStatement(updateRelatedTable);
					updateRelated.setString(1,container.getFileName());	
					updateRelated.setInt(2,container.getRelatedId());							
					updateRelated.execute();			
				}
			} else {
				PreparedStatement getId = conn.prepareStatement(updateIdQuery);
				update.setString(1, filePath);
				update.setString(2, fileName);
				ResultSet rsId=getId.executeQuery();
				if (rsId.next()){
					fileId=rsId.getInt("id"); 
				}
				update.clearParameters();
				update.setString(1, serverName);
				update.setString(2, fileName);
				update.setString(3, fileExtension);
				update.setDouble(4, fileSize);
				update.setString(5, filePath);
				update.setInt(6, locationTypeId);
				update.setString(7, fileLocationURL);
				update.setString(8, oldPath);
				update.setString(9, oldFileName);								
				update.execute();
			}
			
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { st.close(); } catch ( Exception x) { st = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
		
		return fileId;
	
	} // insertMetaData

	public void moveCommerceFiles(HttpServletRequest request, MultipartRequest mr, File dir, File tempDir) 
			throws IOException {

	}

	public MultipartRequest uploadFile(HttpServletRequest request, HttpServletResponse res) throws ServletException, IOException {
	
		MultipartRequest mr = null;

		try {
			
			String tempId = "";
			boolean loggedIn = true;

			ResourceBundle bundle = ResourceBundle.getBundle("com.marcomet.marcomet");	
			String transfers = "";
			String saveDirectory = "";
			String tempDirectory = "";					
			transfers = ((request.getParameter("filePath")!=null)?request.getParameter("filePath"):"/usr/local/etc/httpd/sites/marcomet.com/htdocs/salestrack/sitehosts/fileuploads");//bundle.getString("transfers");							
			saveDirectory = transfers + File.separatorChar;
			tempDirectory = saveDirectory;// + File.separatorChar + "temp";			

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
		    mr = new MultipartRequest(request, 5 * 1024 * 1024, tempDir);
			//Move the file to th ereal directory as needed
			//this.moveCommerceFiles(request, mr, dir, tempDir);

			int number = mr.getNumberOfFiles();
		
			Vector fileVector = new Vector();
			
			for (int i=0; i<number; i++) {
				FileGenericMetaDataContainer container = this.extractAttributes(mr, i);
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

					this.insertMetaData(container, queryType);
					fileVector.add(container);
				}
			}

//			String email = mr.getParameter("email");
//			if (email == null) {
//				email = "";
//			}
//			if (!email.equals("")) {
//				String path = "transfers/" + companyId + File.separatorChar;
//				this.processEmail(request, mr, path, fileVector);
//			}

		} catch(Exception ex) {
			throw new ServletException("FileManipulatorGeneric uploadFile exception: " + ex.getMessage());
		}

		return mr;
		
	} // uploadFile
} // FileManipulator
