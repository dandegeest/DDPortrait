class PhotoInfo {
  //,id,productUrl,baseUrl,mimeType,filename,description,creationTime,width,height,video,cameraMake,cameraModel,focalLength,apertureFNumber,isoEquivalent,exposureTime,0
  String creationTime;
  float apertureFNumber;
  
  PhotoInfo(String dt, float ap) {
    creationTime = dt;
    apertureFNumber = ap;
  }
  
  @Override
  public String toString() {
      return "Photoinfo[" + creationTime + " F:" + apertureFNumber + "]";
  }
}
