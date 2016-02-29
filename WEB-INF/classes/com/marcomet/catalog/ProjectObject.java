package com.marcomet.catalog;

/**********************************************************************
Description:	This class contains all the meta data for projects during
the order process
 **********************************************************************/
import java.util.*;

public class ProjectObject {

  private int id,  sequence;
  private String projectName;
  private Vector jobs;
  public boolean uploadComplete = false;

  public ProjectObject() {
    jobs = new Vector();
  }

  public ProjectObject(int id, int sequence, String projectName) {
    this.id = id;
    this.sequence = sequence;
    this.projectName = projectName;

    jobs = new Vector();
  }

  public void addJob(JobObject jo) {
    if (jobs == null) {
      jobs = new Vector();
    }
    jobs.addElement(jo);
  }

  public JobObject getCurrentJob() {
    if (jobs.size() > 0) {
      return (JobObject) jobs.lastElement();
    }
    else {
      return null;
    }
  }

  public int getId() {
    return id;
  }

  public JobObject getJob(int id) {
    for (int x = 0; x < jobs.size(); x++) {
      JobObject tempJob = (JobObject) jobs.lastElement();
      if (tempJob.getId() == id) {
        return tempJob;
      }
    }
    return null;
  }

  // Jobs vector manipulation methods
  public Vector getJobs() {
    return (Vector) jobs.clone();
  }

  public Hashtable getJobSpecs() {
    Hashtable jobSpecs = new Hashtable();

    for (Enumeration e0 = jobs.elements(); e0.hasMoreElements();) {
      JobObject jo = (JobObject) e0.nextElement();
      Hashtable specs = jo.getJobSpecs();
      for (Enumeration e1 = specs.keys(); e1.hasMoreElements();) {
        String key = (String) e1.nextElement();
        jobSpecs.put(key, specs.get(key));
      }
    }
    return jobSpecs;
  }

  public String getProjectName() {
    return projectName;
  }

  public Integer getProjectSequence() {
    return new Integer(sequence);
  }

  public void removeJob(int index) {
    jobs.removeElementAt(index);
  }

  public void setId(int id) {
    this.id = id;
  }

  public void setProjectName(String projectName) {
    this.projectName = projectName;
  }

  public void setProjectSequence(int sequence) {
    this.sequence = sequence;
  }
}
