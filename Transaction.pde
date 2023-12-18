class Transaction {
  String date;
  String description;
  String category;
  float amount;
  
  Transaction(String dt, String desc, String cat, String amt) {
    date = dt;
    description = desc;
    category = cat;
    
    try
    {
      amount = Float.valueOf(amt);
      //println("Category:", category, abs(amount));
    }
    catch (Exception e)
    {
      println("No Amount for " + desc, cat);
      amount = 0.0;
    }
  }
  
  @Override
  public String toString() {
      return "Transaction[" + description + " category=" + category + ": $" + amount + "]";
  }
}
