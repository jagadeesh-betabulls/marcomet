package com.marcomet.files;

/**********************************************************************
Description:	This object is intended to help manage handling meta
				data for files.  See constructors for specifics.

History:
	Date		Author			Description
	----		------			-----------
	8/31/2001	EKC				Reworked to only deal with generic file data

**********************************************************************/

public class FileGenericMetaDataContainer {

	int locationTypeId,relatedId,roleId,statusId,companyId;
	double fileSize;
	String fileName, fileType, filePath, oldFileName, oldPath, fileLocationURL,serverName, fileExtension,description, relatedTable,relatedField,fileCategory;
	

	public FileGenericMetaDataContainer () {
	}
	// This constructor is used when replacing files
	public FileGenericMetaDataContainer (String fileName, String oldFileName, String oldPath, String fileType, double fileSize, String filePath, String serverName,int locationTypeId, String fileLocationURL,String description, String relatedField, int relatedId,String relatedTable,int roleId,String fileCategory, int statusId,int companyId) {

		this.fileName = fileName;
		this.oldFileName = oldFileName;
		this.oldPath = oldPath;		
		this.fileType = fileType;
		this.fileSize = fileSize;
		this.filePath = filePath;
		this.serverName=serverName;
		this.locationTypeId=locationTypeId;
		this.fileLocationURL = fileLocationURL;
		this.fileExtension=fileExtension;
		this.description=description;
		this.relatedField=relatedField;
		this.relatedId=relatedId;
		this.relatedTable=relatedTable;
		this.roleId=roleId;
		this.fileCategory=fileCategory;
		this.statusId=statusId;
		this.companyId=companyId;		
		
	}
	public int getCompanyId() {
		return companyId;
	}
	public String getDescription() {
		return description;
	}
	public String getFileCategory(){
	return fileCategory;
	}
	public String getFileExtension() {
		return fileType;
	}
	public String getFileLocationURL() {
		return fileLocationURL;
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
	public int getLocationTypeId() {
		return locationTypeId;
	}
	public String getOldFileName() {
		return oldFileName;
	}
	public String getRelatedField() {
		return relatedField;
	}
	public int getRelatedId() {
		return relatedId;
	}
	public String getRelatedTable() {
		return relatedTable;
	}
	public int getRoleId() {
		return roleId;
	}
	public String getServerName() {
		return serverName;
	}
	public int getStatusId() {
		return statusId;
	}
}
