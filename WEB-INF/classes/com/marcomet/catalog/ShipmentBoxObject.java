package com.marcomet.catalog;

public class ShipmentBoxObject {

  private int id, shipmentId,  boxNumber;
  private double weight,  height,  width,  length, volume, paddingPercent;
  private String contents;

  public ShipmentBoxObject() {
    //
  }

  public ShipmentBoxObject(int shipmentId, int boxNumber, double weight, double height, double width, double length, String contents) {
    this.shipmentId = shipmentId;
    this.boxNumber = boxNumber;
    this.weight = weight;
    this.height = height;
    this.width = width;
    this.length = length;
    this.contents = contents;
  }

  public int getBoxNumber() {
    return boxNumber;
  }

  public String getContents() {
    return contents;
  }

  public double getHeight() {
    return height;
  }

  public int getId() {
    return id;
  }

  public double getLength() {
    return length;
  }

  public double getPaddingPercent() {
    return paddingPercent;
  }

  public int getShipmentId() {
    return shipmentId;
  }

  public double getVolume() {
    return volume;
  }

  public double getWeight() {
    return weight;
  }

  public double getWidth() {
    return width;
  }

  public void setBoxNumber(int boxNumber) {
    this.boxNumber = boxNumber;
  }

  public void setContents(String contents) {
    this.contents = contents;
  }

  public void setHeight(double height) {
    this.height = height;
  }

  public void setId(int id) {
    this.id = id;
  }

  public void setLength(double length) {
    this.length = length;
  }

  public void setPaddingPercent(double paddingPercent) {
    this.paddingPercent = paddingPercent;
  }

  public void setShipmentId(int shipmentId) {
    this.shipmentId = shipmentId;
  }

  public void setVolume(double volume) {
    this.volume = volume;
  }

  public void setWeight(double weight) {
    this.weight = weight;
  }

  public void setWidth(double width) {
    this.width = width;
  }
}
