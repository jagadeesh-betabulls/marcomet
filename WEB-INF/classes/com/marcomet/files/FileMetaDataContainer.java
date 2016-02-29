package com.marcomet.files;

/**********************************************************************
Description:	This object is intended to help manage handling meta
				data for files.  See constructors for specifics.

**********************************************************************/

public class FileMetaDataContainer {

	int companyId, jobid, userid, projectid, groupId;
	double fileSize;
	String fileName, fileType, filePath, description, oldFileName, status, category, comments, source;
	

	// Use this constructor if you're dealing with multiple files and the companyId and/or jobid varies.

	public FileMetaDataContainer(int userid, int companyId, int jobid, int projectid, String fileName, String fileType, double fileSize, String filePath, String description, String comments, String status, String category, int groupId) {

		this.userid = userid;
		this.companyId = companyId;
		this.jobid = jobid;
		this.projectid = projectid;
		this.fileName = fileName;
		this.fileType = fileType;
		this.fileSize = fileSize;
		this.filePath = filePath;
		this.description = description;		
		this.comments = comments;
		this.status = status;
		this.category = category;
		this.groupId = groupId;
		
	}
	
	public FileMetaDataContainer(int userid, int companyId, int jobid, int projectid, String fileName, String fileType, double fileSize, String filePath, String description, String comments, String status, String category, int groupId,String source) {

		this.userid = userid;
		this.companyId = companyId;
		this.jobid = jobid;
		this.projectid = projectid;
		this.fileName = fileName;
		this.fileType = fileType;
		this.fileSize = fileSize;
		this.filePath = filePath;
		this.description = description;		
		this.comments = comments;
		this.status = status;
		this.category = category;
		this.groupId = groupId;
		this.source=source;
		
	}
	
	
	// This constructor is used when replacing files
	public FileMetaDataContainer(int userid, int companyId, int jobid, String fileName, String oldFileName, String fileType, double fileSize, String filePath, String description) {

		this.userid = userid;
		this.companyId = companyId;
		this.jobid = jobid;
		this.fileName = fileName;
		this.oldFileName = oldFileName;
		this.fileType = fileType;
		this.fileSize = fileSize;
		this.filePath = filePath;
		this.description = description;
		this.status = "Replaced";
		
	}
	// Use this constructor in situations where the companyId and jobid are always the same.
	public FileMetaDataContainer(String fileName, String fileType, double fileSize, String filePath) {

		this.fileName = fileName;
		this.fileType = fileType;
		this.fileSize = fileSize;
		this.filePath = filePath;
		
	}
	public String getCategory() {
		return category;
	}
	public String getComments() {
		return comments;
	}
	public int getCompanyid() {
		return companyId;
	}
	public String getDescription() {
		return description;
	}
	public String getFileExtension() {
		return fileType;
	}
	public String getFileName() {
		return fileName;
	}
	public String getFilePath() {
		return filePath;
	}
	public double getFileSize() {
		return fileSize;
	}
	public int getGroupid() {
		return groupId;
	}
	public int getJobid() {
		return jobid;
	}
	public String getOldFileName() {
		return oldFileName;
	}
	public int getProjectid() {
		return projectid;
	}
	public String getStatus() {
		return status;
	}
	public int getUserid() {
		return userid;
	}
	public void setCompanyid(int companyId) {
		this.companyId = companyId;
	}
	public void setJobid(int companyId) {
		this.companyId = companyId;
	}
	public String getSource() {
		return source;
	}
	public void setSource(String source) {
		this.source = source;
	}
}
